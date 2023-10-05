import 'package:ez_either/ez_either.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/collections.dart';

import '../../../datasources/datasources.dart';
import '../notifications.dart';

class DefaultReadNotificationsRepository
    implements ReadNotificationsRepository {
  const DefaultReadNotificationsRepository({
    required DatabaseDatasource databaseDatasource,
  }) : _datasource = databaseDatasource;

  final DatabaseDatasource _datasource;

  @override
  Future<Either<Exception, String>> read(String userId) async {
    final readResultOrError = await _datasource.get(
      GetQuery(
        sourceName: notificationsCollection,
        value: userId,
        fieldName: "user_id",
        orderBy: OrderFilter(field: "sent_at"),
        limit: 20,
      ),
    );

    if (readResultOrError.failure) {
      return Left(
        ApplicationException(
          message: "Something went wrong reading your notifications",
        ),
      );
    }

    final notifications = readResultOrError.multiData!
        .where((element) => element["viewed"] == false)
        .map((e) {
      e["viewed"] = true;
      return e;
    });

    for (final notification in notifications) {
      await _datasource.save(
        SaveQuery(
          sourceName: notificationsCollection,
          value: notification,
          id: notification["id"],
        ),
      );
    }

    return Right("Ok");
  }
}
