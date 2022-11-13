import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';
import 'package:surpraise_infra/src/datasources/database/filter.dart';

import '../../../../datasources/database/result.dart';
import 'input.dart';
import 'output.dart';

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
      communitiesOrError =
          await _handleCommunitiesAccordingToOwning(fieldName, input);
    } else {
      final ownerCommunities =
          await _handleCommunitiesAsOwner(input, "owner_id");
      final memberCommunities =
          await _handleCommunitiesAsMember(input, "member_id");
      communitiesOrError = QueryResult(
        success: ownerCommunities.success && memberCommunities.success,
        failure: ownerCommunities.failure && memberCommunities.failure,
        errorMessage:
            ownerCommunities.errorMessage ?? memberCommunities.errorMessage,
        multiData: ownerCommunities.multiData
          ?..addAll(
            memberCommunities.multiData ?? [],
          ),
      );
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

  Future<QueryResult> _handleCommunitiesAccordingToOwning(
    String fieldName,
    GetCommunitiesByUserInput input,
  ) async {
    if (input.asOwner!) {
      return await _handleCommunitiesAsOwner(input, fieldName);
    }
    return await _handleCommunitiesAsMember(input, fieldName);
  }

  Future<QueryResult> _handleCommunitiesAsOwner(
      GetCommunitiesByUserInput input, String fieldName) async {
    return await databaseDatasource.get(
      GetQuery(
        sourceName: "communities",
        operator: FilterOperator.equalsTo,
        value: input.id,
        fieldName: fieldName,
        singleResult: false,
      ),
    );
  }

  Future<QueryResult> _handleCommunitiesAsMember(
    GetCommunitiesByUserInput input,
    String fieldName,
  ) async {
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

    return await databaseDatasource.get(
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
