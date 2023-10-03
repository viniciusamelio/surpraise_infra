import 'package:ez_either/ez_either.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/datasources/database/filter.dart';

import '../../../datasources/database/database_datasource.dart';
import '../../../datasources/database/query.dart';
import '../../collections.dart';
import '../boundaries/get_notifications.dart';
import '../protocols/get_notifications_repository.dart';

class DefaultGetNotificationsRepository implements GetNotificationsRepository {
  const DefaultGetNotificationsRepository({
    required DatabaseDatasource databaseDatasource,
  }) : _datasource = databaseDatasource;
  final DatabaseDatasource _datasource;
  @override
  Future<Either<Exception, List<GetNotificationOutput>>> get({
    required String userId,
    int limit = 2,
    int offset = 0,
  }) async {
    final notificationsOrError = await _datasource.get(
      GetQuery(
        sourceName: notificationsCollection,
        value: userId,
        orderBy: OrderFilter(
          field: "sent_at",
        ),
        offset: offset,
        limit: limit,
        fieldName: "user_id",
      ),
    );

    if (notificationsOrError.failure) {
      return Left(
        ApplicationException(
            message: "Something went wrong getting your notifications"),
      );
    }

    return Right(
      notificationsOrError.multiData!
          .map(
            (e) => GetNotificationOutput(
              id: e["id"],
              userId: e["user_id"],
              message: e["message"],
              sentAt: DateTime.parse(e["sent_at"]),
              topic: e["topic"],
              viewed: e["viewed"],
            ),
          )
          .toList(),
    );
  }
}
