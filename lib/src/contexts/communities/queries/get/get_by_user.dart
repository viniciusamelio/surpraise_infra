import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';

import '../../../../surpraise_infra_base.dart';
import '../../../collections.dart';
import '../../dtos/dtos.dart';

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
    final communities = await databaseDatasource.get(
      GetQuery(
        sourceName: communityMembersCollection,
        value: input.id,
        fieldName: "member_id",
        select: "$communitiesCollection(*), role",
      ),
    );

    if (communities.failure) {
      return Left(
        QueryError("Something went wrong querying your communities"),
      );
    }

    return Right(
      GetCommunitiesByUserOutput(
        value: (communities.multiData ?? [])
            .map<CommunityOutput>(
              (e) => communityOutputFromMap(
                {
                  ...e["community"],
                  "role": e["role"],
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
