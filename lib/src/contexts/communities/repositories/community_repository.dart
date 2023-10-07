import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/collections.dart';
import 'package:surpraise_infra/src/contexts/communities/mappers/community_mapper.dart';
import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/filter.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';

class CommunityRepository
    implements
        CreateCommunityRepository,
        FindCommunityRepository,
        AddMembersRepository,
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
      final result = await _databaseDatasource.save(
        SaveQuery(
          sourceName: sourceName,
          value: CommunityMapper.createMapFromInput(input),
        ),
      );
      await _databaseDatasource.save(
        SaveQuery(
          sourceName: communityMembersCollection,
          value: {
            "member_id": input.ownerId,
            "community_id": result.multiData![0]["id"],
            "role": "owner",
          },
        ),
      );
      if (result.failure) {
        return Left(Exception(result.errorMessage));
      }
      return Right(
        CreateCommunityOutput(
          id: result.multiData![0]["id"],
          description: result.multiData![0]["description"],
          title: result.multiData![0]["title"],
          members: [
            {
              "member_id": input.ownerId,
              "community_id": result.multiData![0]["id"],
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
          Exception("Could not find community through given id"),
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
  Future<Either<Exception, AddMembersOutput>> addMembers(
    AddMembersInput input,
  ) async {
    try {
      final result = await _databaseDatasource.push(
        PushQuery(
          sourceName: sourceName,
          value: input.members
              .map(
                (e) => CommunityMapper.addMemberFromInput(e),
              )
              .toList(),
          id: input.idCommunity,
          field: "members",
        ),
      );
      for (final member in input.members) {
        await _databaseDatasource.push(
          PushQuery(
            sourceName: "users",
            value: input.idCommunity,
            id: member.idMember,
            field: "communities",
          ),
        );
      }

      if (result.failure) {
        return Left(Exception(result.errorMessage));
      }
      return Right(
        AddMembersOutput(),
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
      final result = await _databaseDatasource.delete(
        GetQuery(
          sourceName: communityMembersCollection,
          value: input.members.map((e) => e.id).toList(),
          operator: FilterOperator.inValues,
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
}
