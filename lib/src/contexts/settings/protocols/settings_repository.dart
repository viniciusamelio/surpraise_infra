import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';

import '../boundaries/boundaries.dart';

abstract class SettingsRepository {
  Future<Either<Exception, GetSettingsOutput>> get({
    required String userId,
  });

  Future<Either<Exception, SaveSettingsOutput>> save({
    required SaveSettingsInput input,
  });
}
