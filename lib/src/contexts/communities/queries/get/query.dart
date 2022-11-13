import 'input.dart';
import 'output.dart';

import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';

import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';
import 'package:surpraise_infra/src/query/query.dart';

export 'input.dart';
export 'output.dart';

class GetCommunityQuery implements DataQuery<GetCommunityInput> {
  GetCommunityQuery({
    required this.databaseDatasource,
  });

  final DatabaseDatasource databaseDatasource;

  @override
  Future<Either<QueryError, QueryOutput>> call(GetCommunityInput input) async {
    final communityOrError = await databaseDatasource.get(
      GetQuery(
        sourceName: "communities",
        operator: FilterOperator.equalsTo,
        value: input.id,
        fieldName: "id",
      ),
    );

    if (communityOrError.failure) {
      if (communityOrError.errorMessage!.contains("No element")) {
        return Left(
          QueryError(
            "User not found",
            404,
          ),
        );
      }
      return Left(
        QueryError(communityOrError.errorMessage!),
      );
    }

    return Right(
      GetCommunityOutput(
        value: communityOrError.data!,
      ),
    );
  }
}
