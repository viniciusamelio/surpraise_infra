import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/collections.dart';
import 'package:surpraise_infra/src/contexts/communities/mappers/community_mapper.dart';
import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/filter.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';

class CommunityRepository
    implements
        LeaveCommunityRepository,
        CreateCommunityRepository,
        FindCommunityRepository,
        RemoveMembersRepository,
        DeleteCommunityRepository {
  CommunityRepository({required DatabaseDatasource databaseDatasource})
      : _databaseDatasource = databaseDatasource;

  final DatabaseDatasource _databaseDatasource;

  String get sourceName => communitiesCollection;

  @override
  Future<Either<Exception, CreateCommunityOutput>> createCommunity(
    CreateCommunityInput input,
  ) async {
    try {
      final community = await _databaseDatasource.save(
        SaveQuery(
          sourceName: communitiesCollection,
          value: {
            "owner_id": input.ownerId,
            "imageUrl": input.imageUrl,
            "description": input.description,
            "title": input.title,
          },
        ),
      );

      await _databaseDatasource.save(
        SaveQuery(
          sourceName: communityMembersCollection,
          value: {
            "member_id": input.ownerId,
            "community_id": community.multiData![0]["id"],
            "role": "owner",
          },
        ),
      );

      return Right(
        CreateCommunityOutput(
          id: community.multiData![0]["id"],
          description: community.multiData![0]["description"],
          title: community.multiData![0]["title"],
          members: [
            {
              "member_id": input.ownerId,
              "community_id": community.multiData![0]["id"],
              "role": "owner",
            },
          ],
          ownerId: input.ownerId,
        ),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, FindCommunityOutput>> find(
    FindCommunityInput input,
  ) async {
    try {
      final result = await _databaseDatasource.get(
        GetQuery(
          sourceName: sourceName,
          operator: FilterOperator.equalsTo,
          value: input.id,
          fieldName: "id",
          select:
              "id, title, description, owner_id, $communityMembersCollection(member_id, community_id, role)",
        ),
      );
      if (result.failure) {
        return Left(Exception(result.errorMessage));
      } else if (result.data == null || result.multiData == null) {
        return Left(
          Exception("Could not find community with given id"),
        );
      }
      return Right(
        CommunityMapper.findOutputFromMap(result.data!),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, RemoveMembersOutput>> removeMembers(
    RemoveMembersInput input,
  ) async {
    try {
      // For now it will only remove one member at once
      final result = await _databaseDatasource.delete(
        GetQuery(
          sourceName: communityMembersCollection,
          value: input.members.first.id,
          fieldName: "member_id",
          filters: [
            AndFilter(
              fieldName: "community_id",
              operator: FilterOperator.equalsTo,
              value: input.communityId,
            ),
          ],
        ),
      );

      if (result.failure) {
        return Left(Exception(result.errorMessage));
      }
      return Right(
        RemoveMembersOutput(),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, DeleteCommunityOutput>> delete(
    DeleteCommunityInput input,
  ) async {
    try {
      final result = await _databaseDatasource.delete(
        GetQuery(
          sourceName: sourceName,
          value: input.id,
          fieldName: "id",
        ),
      );
      if (result.failure) {
        return Left(Exception(result.errorMessage));
      }
      return Right(
        DeleteCommunityOutput(
          communityId: input.id,
        ),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, CommunityDetailsOutput>> getCommunityDetails(
    String communityId,
  ) async {
    try {
      final communityOrError = await _databaseDatasource.get(
        GetQuery(
          sourceName: communityMembersCollection,
          value: communityId,
          fieldName: "community_id",
          select: "member_id, $communitiesCollection(owner_id)",
        ),
      );
      if (communityOrError.failure) {
        return Left(Exception("Something went wrong querying this community"));
      } else if (communityOrError.data == null &&
          (communityOrError.multiData == null ||
              communityOrError.multiData!.isEmpty)) {
        return Left(Exception("Community not found"));
      }
      return Right(
        CommunityDetailsOutput(
          membersCount: communityOrError.multiData!.length,
          ownerId: communityOrError.multiData![0][communitiesCollection]
              ["owner_id"],
        ),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, LeaveCommunityOutput>> leave(
    LeaveCommunityInput input,
  ) async {
    try {
      final leaveCommunityResponseOrError = await _databaseDatasource.delete(
        GetQuery(
          sourceName: communityMembersCollection,
          value: input.communityId,
          fieldName: "community_id",
          filters: [
            AggregateFilter.and(
              operator: FilterOperator.equalsTo,
              value: input.memberId,
              fieldName: "member_id",
            ),
          ],
        ),
      );
      if (leaveCommunityResponseOrError.failure) {
        return Left(Exception("Something went wrong leaving community"));
      }
      return Right(LeaveCommunityOutput(input.communityId));
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
