import 'package:ez_either/ez_either.dart';
import '../../../../../surpraise_infra.dart';
import '../../../collections.dart';

export 'input.dart';
export 'output.dart';

class GetMembersQuery implements DataQuery<GetMembersInput> {
  GetMembersQuery({
    required this.databaseDatasource,
  });

  final DatabaseDatasource databaseDatasource;

  @override
  Future<Either<QueryError, QueryOutput>> call(GetMembersInput input) async {
    try {
      final communities = await databaseDatasource.get(
        GetQuery(
          sourceName: communityMembersCollection,
          value: input.communityId,
          fieldName: "community_id",
          select: "role, member_id, profile(tag, name, id)",
        ),
      );
      if (communities.failure) {
        return Left(
          QueryError(
            "Something went wrong querying community members",
          ),
        );
      }
      return Right(
        GetMembersOutput(
          value: communities.multiData!
              .map(
                (e) => FindCommunityMemberOutput(
                  id: e["member_id"],
                  communityId: input.communityId,
                  role: e["role"],
                  name: e["profile"]["name"],
                  tag: e["profile"]["tag"],
                ),
              )
              .toList(),
        ),
      );
    } on Exception catch (e) {
      return Left(
        QueryError(
          e.toString(),
        ),
      );
    }
  }
}
