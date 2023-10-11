import 'package:surpraise_infra/src/contexts/collections.dart';

import 'input.dart';
import 'output.dart';

import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';
import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';
import 'package:surpraise_infra/src/query/query.dart';

export './input.dart';
export './output.dart';

class GetPraisesByCommunityQuery
    implements DataQuery<GetPraisesByCommunityInput> {
  GetPraisesByCommunityQuery({required this.databaseDatasource});

  final DatabaseDatasource databaseDatasource;

  @override
  Future<Either<QueryError, QueryOutput>> call(
    GetPraisesByCommunityInput input,
  ) async {
    final praisesOrError = await databaseDatasource.get(
      GetQuery(
        sourceName: praisesCollection,
        operator: FilterOperator.equalsTo,
        value: input.id,
        fieldName: "community_id",
        limit: input.limit,
        offset: input.offset,
      ),
    );

    if (praisesOrError.failure) {
      return Left(
        QueryError(praisesOrError.errorMessage!),
      );
    } else if (praisesOrError.data == null &&
        (praisesOrError.multiData == null ||
            praisesOrError.multiData!.isEmpty)) {
      return Left(
        QueryError(
          "User not found",
          404,
        ),
      );
    }

    return Right(
      GetPraisesByCommunityOutput(
        value: praisesOrError.multiData ?? [praisesOrError.data!],
      ),
    );
  }
}
