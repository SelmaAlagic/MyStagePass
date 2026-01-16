import '../models/Performer/performer.dart';
import 'base_provider.dart';

class PerformerProvider extends BaseProvider<Performer> {
  PerformerProvider() : super("api/Performer");

  @override
  Performer fromJson(data) {
    return Performer.fromJson(data);
  }
}
