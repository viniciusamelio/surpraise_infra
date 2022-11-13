// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';

import 'package:surpraise_infra/src/contexts/praises/queries/get/input.dart';
import 'package:surpraise_infra/src/contexts/praises/queries/get/output.dart';
import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';
import 'package:surpraise_infra/src/query/query.dart';

export "./input.dart";
export "./output.dart";

class GetPraisesByUserQuery implements DataQuery<GetPraisesByUserInput> {
  GetPraisesByUserQuery({
    required this.databaseDatasource,
  });

  final DatabaseDatasource databaseDatasource;

  @override
  Future<Either<QueryError, QueryOutput>> call(
    GetPraisesByUserInput input,
  ) async {
    if (input.asPraiser != null) {
      final String fieldName =
          input.asPraiser == true ? "praiser_id" : "praised_id";
      final result = await databaseDatasource.get(
        GetQuery(
          sourceName: "praises",
          operator: FilterOperator.equalsTo,
          value: input.id,
          fieldName: fieldName,
          singleResult: false,
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
        GetPraisesByUserOutput(
          value: result.multiData ?? [result.data!],
        ),
      );
    }
    GetQuery query = GetQuery(
      sourceName: "praises",
      operator: FilterOperator.equalsTo,
      value: input.id,
      fieldName: "praised_id",
      singleResult: false,
    );
    final receivedPraises = await databaseDatasource.get(
      query,
    );

    final sentPraises = await databaseDatasource.get(
      query.copyWith(fieldName: "praiser_id"),
    );

    if (receivedPraises.failure || sentPraises.failure) {
      if (receivedPraises.errorMessage!.contains("No element") ||
          sentPraises.errorMessage!.contains("No element")) {
        return Left(
          QueryError(
            "User not found",
            404,
          ),
        );
      }

      return Left(
        QueryError(
          receivedPraises.errorMessage ?? sentPraises.errorMessage!,
        ),
      );
    }

    return Right(
      GetPraisesByUserOutput(
        value: [
          ...(receivedPraises.multiData ?? [receivedPraises.data!]),
          ...(sentPraises.multiData ?? [sentPraises.data!]),
        ],
      ),
    );
  }
}
