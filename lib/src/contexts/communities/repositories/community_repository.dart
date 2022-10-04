// ignore_for_file: implementation_imports

import 'package:fpdart/src/either.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/communities/mappers/community_mapper.dart';
import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';

class CommunityRepository implements CreateCommunityRepository {
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
}
