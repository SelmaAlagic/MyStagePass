import '../models/Country/country.dart';
import 'base_provider.dart';

class CountryProvider extends BaseProvider<Country> {
  CountryProvider() : super("api/Country");

  @override
  Country fromJson(data) => Country.fromJson(data);
}
