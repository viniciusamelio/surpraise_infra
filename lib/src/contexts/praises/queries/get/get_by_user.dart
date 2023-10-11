// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';
import 'package:surpraise_infra/src/contexts/collections.dart';
import 'package:surpraise_infra/src/contexts/praises/dtos/dtos.dart';

import 'package:surpraise_infra/src/contexts/praises/queries/get/input.dart';
import 'package:surpraise_infra/src/contexts/praises/queries/get/output.dart';
import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/filter.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';
import 'package:surpraise_infra/src/query/query.dart';

export "./input.dart";
export "./output.dart";

class GetReceivedPraisesQuery implements DataQuery<GetPraisesByUserInput> {
  GetReceivedPraisesQuery({
    required this.databaseDatasource,
  });

  final DatabaseDatasource databaseDatasource;

  @override
  Future<Either<QueryError, QueryOutput<List<PraiseDto>>>> call(
    GetPraisesByUserInput input,
  ) async {
    final String fieldName = "praised_id";
    final result = await databaseDatasource.get(
      GetQuery(
        sourceName: praisesCollection,
        operator: FilterOperator.equalsTo,
        value: input.id,
        fieldName: fieldName,
        limit: input.limit,
        offset: input.offset,
        orderBy: OrderFilter(field: "created_at"),
        select:
            "*, $communitiesCollection(title), $profilesCollection!praise_praiser_id_fkey(name, tag, id, email)",
      ),
    );

    if (result.failure) {
      return Left(
        QueryError(result.errorMessage!),
      );
    } else if (result.data == null &&
        (result.multiData == null || result.multiData!.isEmpty)) {
      return Left(
        QueryError(
          "User not found",
          404,
        ),
      );
    }

    return Right(
      GetPraisesByUserOutput(
        value: result.multiData!
            .map(
              (praise) => PraiseDto(
                id: praise["id"],
                communityId: praise["community_id"],
                message: praise["message"],
                topic: praise["topic"],
                communityTitle: praise[communitiesCollection]["title"],
                praiser: UserDto(
                  tag: praise[profilesCollection]["tag"],
                  name: praise[profilesCollection]["name"],
                  email: praise[profilesCollection]["email"],
                  id: praise[profilesCollection]["id"],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
