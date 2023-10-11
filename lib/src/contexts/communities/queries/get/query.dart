import 'package:surpraise_infra/src/contexts/communities/dtos/dtos.dart';

import '../../../collections.dart';
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
    final communities = await databaseDatasource.get(
      GetQuery(
        sourceName: communityMembersCollection,
        value: input.id,
        fieldName: "community_id",
        select: "$communitiesCollection(*), role",
      ),
    );
    if (communities.failure) {
      return Left(
        QueryError(
          "Something went wrong querying community with id ${input.id}",
        ),
      );
    } else if (communities.data == null &&
        (communities.multiData == null || communities.multiData!.isEmpty)) {
      return Left(
        QueryError(
          "Community with id ${input.id} not found",
          404,
        ),
      );
    }

    return Right(
      GetCommunityOutput(
        value: communityOutputFromMap(communities.multiData![0]),
      ),
    );
  }
}
