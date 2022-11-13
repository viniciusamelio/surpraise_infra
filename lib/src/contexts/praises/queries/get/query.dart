import 'input.dart';
import 'output.dart';

import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';

import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';
import 'package:surpraise_infra/src/query/query.dart';

export 'input.dart';
export 'output.dart';

class GetPraiseQuery implements DataQuery<GetPraiseInput> {
  GetPraiseQuery({
    required this.databaseDatasource,
  });

  final DatabaseDatasource databaseDatasource;

  @override
  Future<Either<QueryError, QueryOutput>> call(GetPraiseInput input) async {
    final praiseOrError = await databaseDatasource.get(
      GetQuery(
        sourceName: "praises",
        operator: FilterOperator.equalsTo,
        value: input.id,
        fieldName: "id",
      ),
    );

    if (praiseOrError.failure) {
      if (praiseOrError.errorMessage!.contains("No element")) {
        return Left(
          QueryError(
            "User not found",
            404,
          ),
        );
      }
      return Left(
        QueryError(praiseOrError.errorMessage!),
      );
    }

    return Right(
      GetPraiseOutput(
        value: praiseOrError.data!,
      ),
    );
  }
}
