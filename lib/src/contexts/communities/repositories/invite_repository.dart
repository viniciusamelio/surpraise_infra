import 'package:ez_either/ez_either.dart';
import 'package:surpraise_core/surpraise_core.dart';

import '../../../surpraise_infra_base.dart';
import '../../collections.dart';

class InvitationRepository implements InviteRepository {
  const InvitationRepository({
    required DatabaseDatasource databaseDatasource,
  }) : _datasource = databaseDatasource;
  final DatabaseDatasource _datasource;

  @override
  Future<Either<Exception, InviteMemberOutput>> invite(
    InviteMemberInput input,
  ) async {
    try {
      final invitedMemberOrError = await _datasource.save(
        SaveQuery(
          sourceName: invitesCollection,
          value: {
            "member_id": input.memberId,
            "community_id": input.communityId,
            "role": input.role,
          },
        ),
      );
      if (invitedMemberOrError.failure) {
        return Left(Exception("Something went wrong inviting member"));
      }
      return Right(InviteMemberOutput());
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
