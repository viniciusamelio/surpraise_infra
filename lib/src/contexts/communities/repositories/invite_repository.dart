import 'package:ez_either/ez_either.dart';
import 'package:surpraise_core/surpraise_core.dart';

import '../../../surpraise_infra_base.dart';
import '../../collections.dart';

class InvitationRepository implements InviteRepository, AnswerInviteRepository {
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

  @override
  Future<Either<Exception, AnswerInviteOutput>> answerInvite(
    AnswerInviteInput input,
  ) async {
    try {
      final answerOrError = await _datasource.save(
        SaveQuery(
          sourceName: invitesCollection,
          value: {
            "status": input.accepted ? "accepted" : "rejected",
            "updated_at": DateTime.now().toIso8601String(),
          },
          id: input.id,
        ),
      );
      if (answerOrError.failure) {
        return Left(Exception("Something went wrong answering invitation"));
      }

      if (input.accepted) {
        final addResultOrError = await addMember(inviteId: input.id);
        if (addResultOrError.isLeft()) {
          return Left(addResultOrError.fold((left) => left, (right) => null)!);
        }
      }

      return Right(const AnswerInviteOutput());
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, void>> addMember({
    required String inviteId,
  }) async {
    try {
      final inviteOrError = await findInvite(inviteId);
      if (inviteOrError.isLeft()) {
        return Left(inviteOrError.fold((left) => left, (right) => null)!);
      }

      final invite = inviteOrError.fold((left) => null, (right) => right)!;

      final communityMemberOrError = await _datasource.save(
        SaveQuery(
          sourceName: communityMembersCollection,
          value: {
            "member_id": invite.memberId,
            "community_id": invite.communityId,
            "role": invite.role,
            "active": true,
          },
        ),
      );

      if (communityMemberOrError.failure) {
        return Left(Exception("Something went wrong adding member"));
      }

      return Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, FindInviteOutput>> findInvite(
    String id,
  ) async {
    try {
      final inviteOrError = await _datasource.get(
        GetQuery(
          sourceName: invitesCollection,
          value: id,
          fieldName: "id",
        ),
      );
      if (inviteOrError.failure) {
        return Left(Exception("Something went wrong querying invite"));
      } else if (inviteOrError.data == null &&
          (inviteOrError.multiData == null ||
              inviteOrError.multiData!.isEmpty)) {
        return Left(Exception("Invite not found"));
      }

      return Right(
        FindInviteOutput(
          id: id,
          communityId: inviteOrError.multiData!.first["community_id"],
          status: inviteOrError.multiData!.first["status"],
          role: inviteOrError.multiData!.first["role"],
          memberId: inviteOrError.multiData!.first["member_di"],
        ),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
