import '../models/Ticket/ticket.dart';
import 'base_provider.dart';

class TicketProvider extends BaseProvider<Ticket> {
  TicketProvider() : super("api/Ticket");

  @override
  Ticket fromJson(data) {
    return Ticket.fromJson(data);
  }
}
