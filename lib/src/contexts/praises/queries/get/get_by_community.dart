import 'input.dart';
import 'output.dart';

import 'package:fpdart/fpdart.dart';
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
        sourceName: "praises",
        operator: FilterOperator.equalsTo,
        value: input.id,
        fieldName: "community_id",
        singleResult: false,
      ),
    );

    if (praisesOrError.failure) {
      if (praisesOrError.errorMessage!.contains("No element")) {
        return Left(
          QueryError(
            "User not found",
            404,
          ),
        );
      }
      return Left(
        QueryError(praisesOrError.errorMessage!),
      );
    }

    return Right(
      GetPraisesByCommunityOutput(
        value: praisesOrError.multiData ?? [praisesOrError.data!],
      ),
    );
  }
}
