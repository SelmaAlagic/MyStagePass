# 🎵 MyStagePass

> A smart concert ticketing platform with personalized event recommendations — built for music lovers, performers, and admins.

---

## 📖 About the Project

**MyStagePass** is a full-stack application developed as part of the *Software Development II* course at the Faculty of Information Technologies, University "Džemal Bijedić" in Mostar.

The platform connects **music fans**, **performers**, and **administrators** in one seamless experience — from discovering concerts and buying tickets, to managing events and tracking sales analytics.

---

## 🚀 Features

### 🖥️ Desktop (Admin)
- Dashboard with key metrics overview
- User management — view, edit, and deactivate customers and performers
- Performer verification — approve or reject performer registration requests
- Event management — review, edit, and approve pending events
- Ticket sales analytics with monthly breakdowns by performer and venue
- PDF report export
- In-app notifications (new performer requests, pending events)

### 📱 Mobile (Customer & Performer)
- Login & registration with role-based dashboards
- Browse upcoming concerts with filters (name, location, price, date)
- Personalized event recommendations via content-based recommender
- Ticket purchase via **Stripe** (sandbox)
- QR code digital tickets in *My Events*
- Venue navigation via **Google Maps** deep link
- Event ratings & reviews (enabled only after the event has passed)
- Performer profile management & event creation (subject to admin approval)
- Performer sales statistics with PDF export
- In-app notifications for both customers and performers

---

## 🧠 Recommendation System

MyStagePass uses a **Hybrid Recommendation System** combining Content-Based Filtering and Collaborative Filtering via Matrix Factorization.

### How it works

**Content-Based signals** (scored per candidate event):
- Genre match — weighted by interaction type (purchase = 3×, favorite = 1×)
- Performer match — bonus if user has interacted with the same performer before
- Rating score — higher-rated events get a boost, especially if above the user's average
- Price proximity — events priced similarly to what the user usually buys score higher
- Location — bonus if the event is in a city the user has attended events in before

**Collaborative Filtering** (Matrix Factorization via ML.NET):
- Trained on all purchases (weight 3) and favorites (weight 1)
- Predicts a score for each unseen event based on patterns from users with similar taste
- Model is cached on disk and retrained every hour

**Final score** = content score + collaborative score × 5

If the user has no interaction history yet, the system falls back to **popularity-based recommendations** (most tickets sold).

Every recommendation includes an **explanation**, for example:
> *"Recommended because this event matches your preferred Jazz genre and is popular among users with similar taste."*

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Backend API | C# / ASP.NET Core |
| Desktop | Flutter (Windows) |
| Mobile | Flutter (Android) |
| Database | SQL Server |
| Auth | JWT |
| Payments | Stripe |
| Messaging | RabbitMQ |
| Containerization | Docker / docker-compose |

---

## ⚙️ Running the Application

### Prerequisites
- Docker & Docker Compose installed
- Android emulator (AVD) for mobile testing
- `.env` file (see configuration section below)

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/SelmaAlagic/MyStagePass.git
   cd MyStagePass
   ```

2. **Set up environment variables**
   - Unzip `.env-tajne.zip` using the provided password
   - Place the `.env` file in the root API folder

3. **Start all services**
   ```bash
   docker-compose up --build
   ```

4. **Run the desktop app**
   ```bash
   cd desktop
   flutter run --dart-define=API_BASE_URL=http://localhost:5000
   ```

5. **Run the mobile app (Android emulator)**
   ```bash
   cd mobile
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
   ```

---

## 🔐 Credentials

### Desktop (Admin)
| Field | Value |
|---|---|
| Username | admin.adminovic |
| Password | Admin123! |

### Mobile (Customer)
| Field | Value |
|---|---|
| Username | senad.alagic |
| Password | Senad123! |

### Mobile (Performer)
| Field | Value |
|---|---|
| Username | mirza.selimovic |
| Password | Mirza123! |

---

## 💳 Stripe Test Card

| Field | Value |
|---|---|
| Card Number | 4242 4242 4242 4242 |
| Expiry Date | 12/26 |
| CVC | 123 |
| ZIP/Postal Code | 10000 |

---

## 👩‍💻 Author

**Selma Alagić** — IB220125  
Faculty of Information Technologies, University "Džemal Bijedić" in Mostar  
Course: Software Development II  
Mentors: prof.dr.sc. Elmir Babović, prof.dr.sc. Denis Mušić
