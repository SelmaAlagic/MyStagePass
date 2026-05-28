import '../models/Status/status.dart';
import 'base_provider.dart';

class StatusProvider extends BaseProvider<Status> {
  StatusProvider() : super("api/Status");

  @override
  Status fromJson(data) => Status.fromJson(data);
}
