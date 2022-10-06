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
        AddMembersRepository {
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
}
