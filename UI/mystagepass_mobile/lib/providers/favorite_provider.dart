import '../models/CustomerFavoriteEvents/favorites.dart';
import 'base_provider.dart';

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

  Future<void> removeFavorite(int favoriteId) async {
    await delete(favoriteId);
    favorites.removeWhere((f) => f.customerFavoriteEventID == favoriteId);
    notifyListeners();
  }
}
