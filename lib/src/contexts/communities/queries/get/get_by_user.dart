import 'package:surpraise_infra/src/datasources/database/filter.dart';

import '../../../../datasources/database/result.dart';
import 'input.dart';
import 'output.dart';

import 'package:fpdart/fpdart.dart';

import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';
import 'package:surpraise_infra/src/query/query.dart';

export 'input.dart';
export 'output.dart';

class GetCommunitiesByUserQuery
    implements DataQuery<GetCommunitiesByUserInput> {
  GetCommunitiesByUserQuery({
    required this.databaseDatasource,
  });

  final DatabaseDatasource databaseDatasource;

  @override
  Future<Either<QueryError, GetCommunitiesByUserOutput>> call(
    GetCommunitiesByUserInput input,
  ) async {
    late QueryResult communitiesOrError;
    if (input.asOwner != null) {
      final fieldName = input.asOwner! ? "owner_id" : "member_id";
      if (input.asOwner!) {
        communitiesOrError = await databaseDatasource.get(
          GetQuery(
            sourceName: "communities",
            operator: FilterOperator.equalsTo,
            value: input.id,
            fieldName: fieldName,
            singleResult: false,
          ),
        );
      } else {
        final userOrError = await databaseDatasource.get(
          GetQuery(
            sourceName: "users",
            operator: FilterOperator.equalsTo,
            value: input.id,
            fieldName: "id",
          ),
        );
        final List<AggregateFilter> filters = userOrError.data?["communities"]
            .map<OrFilter>(
              (e) => OrFilter(
                fieldName: "id",
                operator: FilterOperator.equalsTo,
                value: e,
              ),
            )
            .toList();
        filters.removeAt(0);

        communitiesOrError = await databaseDatasource.get(
          GetQuery(
            sourceName: "communities",
            operator: FilterOperator.equalsTo,
            value: userOrError.data?["communities"].first,
            filters: filters,
            fieldName: "id",
            singleResult: false,
          ),
        );
      }
    }

    if (communitiesOrError.failure) {
      if (communitiesOrError.errorMessage!.contains("No element")) {
        return Left(
          QueryError(
            "User not found",
            404,
          ),
        );
      }
      return Left(
        QueryError(communitiesOrError.errorMessage!),
      );
    }

    return Right(
      GetCommunitiesByUserOutput(
        value: communitiesOrError.multiData ?? [communitiesOrError.data!],
      ),
    );
  }
}
