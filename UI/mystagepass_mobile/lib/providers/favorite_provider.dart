import 'package:http/http.dart' as http;
import 'base_provider.dart';
import '../models/CustomerFavoriteEvents/favorites.dart';

class FavoriteProvider extends BaseProvider<Favorites> {
  FavoriteProvider() : super("api/CustomerFavoriteEvent");

  List<Favorites> favorites = [];
  bool isLoading = false;

  @override
  Favorites fromJson(data) {
    return Favorites.fromJson(data);
  }

  Future<void> fetchFavorites() async {
    isLoading = true;
    notifyListeners();

    var result = await get();
    favorites = result.result;

    isLoading = false;
    notifyListeners();
  }

  Future<void> addFavorite(int eventId) async {
    var url = "${getBaseUrl()}api/CustomerFavoriteEvent/toggle/$eventId";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var response = await http.post(uri, headers: headers);
    if (isValidResponse(response)) {
      await fetchFavorites();
    } else {
      throw Exception("Failed to add favorite");
    }
  }

  Future<void> removeFavorite(int favoriteId) async {
    await delete(favoriteId);
    favorites.removeWhere((f) => f.customerFavoriteEventID == favoriteId);
    notifyListeners();
  }
}
