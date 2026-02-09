import '../models/City/city.dart';
import 'base_provider.dart';

class CityProvider extends BaseProvider<City> {
  CityProvider() : super("api/City");

  @override
  City fromJson(data) {
    return City.fromJson(data);
  }
}
