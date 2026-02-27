import '../models/Event/event.dart';
import 'base_provider.dart';

class EventProvider extends BaseProvider<Event> {
  EventProvider() : super("api/Event");

  @override
  Event fromJson(data) => Event.fromJson(data);
}
