import 'package:ez_either/ez_either.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/collections.dart';

import '../../../surpraise_infra_base.dart';

class DefaultSettingsRepository implements SettingsRepository {
  DefaultSettingsRepository({
    required DatabaseDatasource databaseDatasource,
  }) : _databaseDatasource = databaseDatasource;

  final DatabaseDatasource _databaseDatasource;

  @override
  Future<Either<Exception, GetSettingsOutput>> get({
    required String userId,
  }) async {
    final settingsOrError = await _databaseDatasource.get(
      GetQuery(
        sourceName: settingsCollection,
        operator: FilterOperator.equalsTo,
        value: userId,
        fieldName: "user_id",
      ),
    );
    if (settingsOrError.failure) {
      return Left(
        ApplicationException(
          message: "Something went wrong getting your accont settings",
        ),
      );
    }

    if (settingsOrError.data == null &&
        (settingsOrError.multiData == null ||
            settingsOrError.multiData!.isEmpty)) {
      final newSettingsOrError = await save(
        input: SaveSettingsInput(
          pushNotificationsEnabled: false,
          userId: userId,
        ),
      );

      if (newSettingsOrError.isLeft()) {
        return Left(
          ApplicationException(
            message: "Something went wrong saving your accont settings",
          ),
        );
      }

      return Right(
        GetSettingsOutput(
          pushNotificationsEnabled: false,
        ),
      );
    }

    return Right(
      GetSettingsOutput(
        pushNotificationsEnabled: settingsOrError.multiData![0]
            ["push_notifications_enabled"],
      ),
    );
  }

  @override
  Future<Either<Exception, SaveSettingsOutput>> save({
    required SaveSettingsInput input,
  }) async {
    final settingsOrError = await _databaseDatasource.save(
      SaveQuery(
        sourceName: settingsCollection,
        value: {
          "user_id": input.userId,
          "push_notifications_enabled": input.pushNotificationsEnabled,
        },
      ),
    );

    if (settingsOrError.failure) {
      return Left(
        ApplicationException(
          message: "Something went wrong saving your accont settings",
        ),
      );
    }

    return Right(
      SaveSettingsOutput(
        pushNotificationsEnabled: settingsOrError.multiData![0]
            ["push_notifications_enabled"],
      ),
    );
  }
}
