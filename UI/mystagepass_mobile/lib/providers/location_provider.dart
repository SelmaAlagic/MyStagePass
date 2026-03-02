import '../models/Location/location.dart';
import 'base_provider.dart';

class LocationProvider extends BaseProvider<Location> {
  LocationProvider() : super("api/Location");

  @override
  Location fromJson(data) {
    return Location.fromJson(data);
  }
}
