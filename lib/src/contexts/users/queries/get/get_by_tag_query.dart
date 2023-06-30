// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ez_either/ez_either.dart';

import '../../../../../surpraise_infra.dart';

class GetUserByTagQuery implements DataQuery<GetUserByTagQueryInput> {
  const GetUserByTagQuery({
    required this.databaseDatasource,
  });

  final DatabaseDatasource databaseDatasource;

  @override
  Future<Either<QueryError, QueryOutput>> call(
    GetUserByTagQueryInput input,
  ) async {
    final result = await databaseDatasource.get(
      GetQuery(
        sourceName: "users",
        operator: FilterOperator.equalsTo,
        value: input.tag,
        fieldName: "tag",
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
