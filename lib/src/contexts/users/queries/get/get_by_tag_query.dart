// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ez_either/ez_either.dart';
import 'package:surpraise_infra/src/contexts/collections.dart';

import '../../../../../surpraise_infra.dart';

class GetUserByTagQuery implements DataQuery<GetUserByTagQueryInput> {
  const GetUserByTagQuery({
    required this.databaseDatasource,
  });

  final DatabaseDatasource databaseDatasource;

  @override
  Future<Either<QueryError, QueryOutput<GetUserDto>>> call(
    GetUserByTagQueryInput input,
  ) async {
    final result = await databaseDatasource.get(
      GetQuery(
        sourceName: profilesCollection,
        operator: FilterOperator.equalsTo,
        value: input.tag,
        fieldName: "tag",
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
      GetUserQueryOutput(
        value: GetUserDto(
          id: result.multiData![0]["id"],
          tag: result.multiData![0]["tag"],
          name: result.multiData![0]["name"],
          email: result.multiData![0]["email"],
        ),
      ),
    );
  }
}
