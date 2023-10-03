import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';
import 'package:surpraise_infra/src/contexts/notifications/boundaries/get_notifications.dart';

abstract class GetNotificationsRepository {
  Future<Either<Exception, List<GetNotificationOutput>>> get({
    required String userId,
    int limit = 20,
    int offset = 0,
  });
}
