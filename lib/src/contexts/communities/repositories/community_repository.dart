// ignore_for_file: implementation_imports

import 'package:fpdart/src/either.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/communities/mappers/community_mapper.dart';
import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
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

  String get sourceName => "communities";

  @override
  Future<Either<Exception, CreateCommunityOutput>> createCommunity(
    CreateCommunityInput input,
  ) async {
    try {
      final result = await _databaseDatasource.save(SaveQuery(
        sourceName: sourceName,
        value: CommunityMapper.createMapFromInput(input),
      ));
      await _databaseDatasource.push(
        PushQuery(
          sourceName: "users",
          value: input.id,
          id: input.ownerId,
          field: "owned_communities",
        ),
      );
      if (result.failure) {
        return Left(Exception(result.errorMessage));
      }
      return Right(
        CommunityMapper.createOutputFromMap(
          result.data!,
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
        ),
      );
      if (result.failure) {
        return Left(Exception(result.errorMessage));
      } else if (result.data == null) {
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
      final members = input.memberIds
          .map((e) => {
                "member_id": e,
                "role": "member",
              })
          .toList();
      final result = await _databaseDatasource.pop(
        PopQuery(
          sourceName: sourceName,
          value: members,
          id: input.communityId,
          field: "members",
        ),
      );
      for (final memberId in input.memberIds) {
        await _databaseDatasource.pop(
          PopQuery(
            sourceName: "users",
            value: input.communityId,
            id: memberId,
            field: "communities",
          ),
        );
      }

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
      final result = await _databaseDatasource.delete(sourceName, input.id);
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
