import 'package:fpdart/fpdart.dart';
import 'package:surpraise_infra/src/contexts/users/queries/get/input.dart';
import 'package:surpraise_infra/src/contexts/users/queries/get/output.dart';
import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';
import 'package:surpraise_infra/src/query/query.dart';

export "./input.dart";
export "./output.dart";

class GetUserQuery implements DataQuery<GetUserQueryInput> {
  GetUserQuery({
    required this.databaseDatasource,
  });

  final DatabaseDatasource databaseDatasource;

  @override
  Future<Either<QueryError, QueryOutput>> call(GetUserQueryInput input) async {
    final result = await databaseDatasource.get(
      GetQuery(
        sourceName: "users",
        operator: FilterOperator.equalsTo,
        value: input.id,
        fieldName: "id",
      ),
    );

    if (result.failure) {
      if (result.errorMessage!.contains("No element")) {
        return Left(
          QueryError(
            "User not found",
            404,
          ),
        );
      }
      return Left(
        QueryError(result.errorMessage!),
      );
    }

    return Right(
      GetUserQueryOutput(
        value: result.data!,
      ),
    );
  }
}
