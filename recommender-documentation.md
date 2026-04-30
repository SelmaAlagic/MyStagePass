# Sistem preporuke — MyStagePass

## Uvod

MyStagePass je aplikacija za kupovinu karata za događaje (koncerti, festivali i sl.). Kako broj događaja i korisnika raste, postaje sve teže pronaći relevantne sadržaje. Umjesto jednostavnog sortiranja po popularnosti, implementiran je hibridni sistem koji kombinuje **content-based filtering** i **collaborative filtering (Matrix Factorization)** kako bi svaki korisnik dobio preporuke prilagođene njegovim navikama.

Oba pristupa se računaju odvojeno i spajaju u jedan finalni score po događaju.

---

## Struktura fajlova

| Komponenta | Putanja                                                      |
| ---------- | ------------------------------------------------------------ |
| Servis     | `MyStagePass.Services/Services/RecommendedService.cs`        |
| Controller | `MyStagePass.WebAPI/Controllers/RecommendationController.cs` |
| DTO        | `MyStagePass.Model/DTOs/EventRecommendation.cs`              |
| Interface  | `MyStagePass.Model/DTOs/IRecommendedService.cs`              |

---

## API

```http
GET /api/Recommendation?topN=10
Authorization: Bearer <JWT token>
```

Endpoint je dostupan samo korisnicima sa rolom `Customer`. Query parametar `topN` (default `10`) kontroliše koliko preporuka se vraća.

### Response primjer

```json
[
  {
    "eventName": "Rock Night 2026",
    "performerName": "The Rolling Band",
    "eventDate": "2026-06-15T20:00:00",
    "cityName": "Sarajevo",
    "ticketPrices": {
      "Regular": 30,
      "VIP": 60,
      "Premium": 100
    },
    "similarityScore": 47.85,
    "recommendationReason": "Recommended because this event matches your preferred Rock genre and has a strong rating of 4.5★."
  }
]
```

### DTO

```csharp
public class EventRecommendation
{
    public string EventName { get; set; } = string.Empty;
    public string PerformerName { get; set; } = string.Empty;
    public DateTime EventDate { get; set; }
    public string CityName { get; set; } = string.Empty;
    public Dictionary<string, int> TicketPrices { get; set; } = new();
    public double SimilarityScore { get; set; }
    public string RecommendationReason { get; set; } = string.Empty;
}
```

---

## Tok izvršavanja

Svaki poziv prolazi kroz isti slijed koraka:

```
GET /api/Recommendation
        │
        ▼
EnsureModelTrainedAsync()
  ├─ model u memoriji i svjež (< 1h)? ──→ koristi direktno
  ├─ postoji na disku i svjež?         ──→ učitaj s diska
  └─ inače                             ──→ treniraj novi → sačuvaj na disk
        │
        ▼
Dohvati interakcije korisnika (kupovine + favoriti)
        │
        ▼
Ima interakcija?
  ├─ NE ──→ GetPopularEvents() ──→ [Response]
  └─ DA
        │
        ▼
Dohvati dostupne događaje
(EventDate > sada, Status = Approved, nije već kupljen/favorit)
        │
        ▼
Za svaki događaj izračunaj:
  ├─ contentScore  (žanr, izvođač, rating, cijena, lokacija)
  ├─ collaborativeScore = _predEngine.Predict() × 5
  └─ totalScore = contentScore + collaborativeScore
        │
        ▼
Postoji li ijedan event sa totalScore > 0?
  ├─ NE ──→ GetPopularEvents() ──→ [Response]
  └─ DA
        │
        ▼
Sortiraj silazno → Take(topN) → generiši RecommendationReason
        │
        ▼
Vrati List<EventRecommendation>
```

---

## Collaborative Filtering

Koristi se `MatrixFactorizationTrainer` iz `Microsoft.ML.Recommender` biblioteke. Model uči na osnovu stvarnih korisničkih interakcija — kupovine i favoriti su dio normalnog toka aplikacije, ne posebno sakupljeni podaci.

### Interakcijski signali

| Signal               | Label vrijednost |
| -------------------- | ---------------- |
| Kupovina karte       | `3.0`            |
| Dodavanje u favorite | `1.0`            |

### Parametri treniranja

```csharp
new MatrixFactorizationTrainer.Options
{
    MatrixColumnIndexColumnName = "CustomerIdKey",
    MatrixRowIndexColumnName    = "EventIdKey",
    LabelColumnName             = "Label",
    NumberOfIterations          = 20,
    ApproximationRank           = 8
}
```

### Pipeline

```
CustomerId → MapValueToKey → CustomerIdKey ─┐
                                             ├─→ MatrixFactorizationTrainer → _model (ITransformer)
EventId    → MapValueToKey → EventIdKey    ─┘
```

### Caching modela

Model se čuva na disk (`recommender-model.ml`) kako bi se izbjeglo ponavljanje treniranja na svakom requestu. Logika osvježavanja:

| Situacija                            | Šta se dešava                                  |
| ------------------------------------ | ---------------------------------------------- |
| `_model != null` i mlađi od 1h       | Koristi se iz memorije, bez I/O                |
| Fajl postoji na disku i mlađi od 1h  | Učitava se s diska                             |
| Fajl ne postoji ili stariji od 1h    | Trenira se novi model, čuva na disk            |
| Manje od 5 interakcija ukupno u bazi | `_model = null`, collaborative dio se preskače |

```csharp
// Rana provjera prije lock-a
if (_model != null && (DateTime.UtcNow - _lastTrained).TotalHours < 1)
    return;

// Unutar lock-a — pokušaj učitavanja s diska
if (_model == null && File.Exists(_modelPath))
{
    _model = _ml.Model.Load(_modelPath, out _);
    _predEngine = _ml.Model.CreatePredictionEngine<EventInteraction, EventPrediction>(_model);
    _lastTrained = File.GetLastWriteTimeUtc(_modelPath);

    if ((DateTime.UtcNow - _lastTrained).TotalHours < 1)
        return;
}
```

> `_model`, `_predEngine` i `_lastTrained` su `static` — dijele se između svih instanci servisa u procesu. Sav write pristup je zaštićen `lock (_lock)`. `PredictionEngine` nije thread-safe pa i predikcija ide kroz isti lock.

---

## Content-Based Filtering

Za svakog korisnika se iz njegovih interakcija grade preferencije (žanrovi, izvođači, prosječna cijena, prosječni rating, gradovi). Svaki dostupni događaj se tada scorira na osnovu koliko se poklapa s tim preferencijama.

### Signali

| Signal       | Max doprinos | Logika                                                                                                                     |
| ------------ | ------------ | -------------------------------------------------------------------------------------------------------------------------- |
| **Žanr**     | Varijabilno  | Sabira se težina po žanrovima interagovanih eventi: kupovina → `+3.0`, favorit → `+1.0`. Uzimaju se top 3 žanra korisnika. |
| **Izvođač**  | `+20.0`      | Flat bonus ako korisnik već ima interakciju s tim izvođačem.                                                               |
| **Rating**   | `+20.0`      | `RatingAverage × 3` (za rating 5.0 → `+15.0`), plus bonus `+5.0` ako je rating iznad korisnikovog prosjeka.                |
| **Cijena**   | `+5.0`       | `+5.0` ako razlika od korisnikovog prosjeka < 30%, `+2.0` ako < 60%, inače `0`.                                            |
| **Lokacija** | `+10.0`      | Flat bonus ako je događaj u gradu gdje korisnik ima prethodne interakcije.                                                 |

### Implementacija

```csharp
// Žanr score — akumulira se po svim interakcijama korisnika
float genreScore = eventGenreIds
    .Where(g => genreWeights.ContainsKey(g))
    .Sum(g => genreWeights[g]);

// Izvođač
float performerScore = preferredPerformerIds.Contains(ev.PerformerID) ? 20f : 0f;

// Rating
float ratingScore = ev.RatingAverage * 3f;
if (ev.RatingAverage > userAvgRating && userAvgRating > 0)
    ratingScore += 5f;

// Cijena
double priceDiff = Math.Abs(ev.RegularPrice - avgPrice) / avgPrice;
float priceScore = priceDiff < 0.3 ? 5f : priceDiff < 0.6 ? 2f : 0f;

// Lokacija
float locationScore = preferredCityIds.Contains(ev.Location?.CityID ?? -1) ? 10f : 0f;

float contentScore = genreScore + performerScore + ratingScore + priceScore + locationScore;
```

---

## Hibridni score

```
totalScore = contentScore + (collaborativeScore × 5)
```

Collaborative predikcija se množi sa `5` kako bi bila usporedive veličine s content scorom. Događaji se sortiraju silazno po `totalScore` i vraća se prvih `topN`.

---

## Fallback

Ako personalizacija nije moguća, sistem vraća popularne događaje umjesto da vrati prazan niz.

```csharp
private List<EventRecommendation> GetPopularEvents(List<Event> events, int topN)
{
    return events
        .OrderByDescending(e => e.TicketsSold)
        .Take(topN)
        .Select(e => MapToRecommendation(e, e.TicketsSold, null, 0, false))
        .ToList();
}
```

Fallback se aktivira u dva slučaja: korisnik nema nijednu interakciju, ili nijedan dostupni događaj nije dobio `totalScore > 0`.

---

## RecommendationReason

Svaka preporuka vraća tekstualno objašnjenje koje se gradi na osnovu toga koji su signali doprinijeli score-u. Nije statičan tekst — sastavlja se dinamički za svaki rezultat.

```csharp
var parts = new List<string>();

if (ev.Performer?.Genres?.Any() == true)
    parts.Add($"matches your preferred {topGenreName} genre");

if (ev.RatingAverage > userAvgRating && userAvgRating > 0)
    parts.Add($"is rated above your usual events ({ev.RatingAverage:F1}★)");
else if (ev.RatingAverage > 0)
    parts.Add($"has a strong rating of {ev.RatingAverage:F1}★");

if (hasCollaborativeBoost)
    parts.Add("is popular among users with similar taste");

reason = parts.Any()
    ? $"Recommended because this event {string.Join(" and ", parts)}."
    : $"Recommended based on your activity in {topGenreName} events.";
```

Za fallback eventi reason je uvijek: `"Trending — this event is among the most popular right now."`

---

## Napomene

**Cold start** — korisnik bez ikakvih interakcija uvijek dobija popularni fallback. Jedna kupovina ili favorit je dovoljna da se personalizacija uključi.

**Model refresh** — model se re-trenira automatski svakih sat vremena dok server radi, bez potrebe za redeploymentom. Novo trenirani model se odmah čuva na disk.

**Minimum za collaborative** — MatrixFactorization zahtijeva minimalno 5 interakcija ukupno u bazi. Ispod tog praga `_model` ostaje `null` i collaborative dio se tiho preskače; content-based i dalje funkcioniše normalno.
