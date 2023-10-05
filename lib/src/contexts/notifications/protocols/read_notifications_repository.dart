import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';

abstract class ReadNotificationsRepository {
  Future<Either<Exception, String>> read(String userId);
}
