import 'package:fpdart/fpdart.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/users/mappers/user_mapper.dart';
import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';

class UserRepository implements CreateUserRepository, EditUserRepository {
  UserRepository({
    required DatabaseDatasource databaseDatasource,
  }) : _datasource = databaseDatasource;

  final DatabaseDatasource _datasource;

  final String sourceName = "users";

  @override
  Future<Either<Exception, CreateUserOutput>> create(
    CreateUserInput input,
  ) async {
    try {
      final result = await _datasource.save(
        SaveQuery(
          sourceName: sourceName,
          value: UserMapper.createUserInputToMap(input),
        ),
      );
      if (result.failure) {
        return Left(
          Exception(
            result.errorMessage,
          ),
        );
      }
      return Right(
        UserMapper.createUserOutputFromMap(result.data!),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, EditUserOutput>> edit(EditUserInput input) async {
    try {
      final result = await _datasource.save(
        SaveQuery(
          sourceName: sourceName,
          value: UserMapper.editUserInputToMap(input),
        ),
      );
      if (result.failure) {
        return Left(
          Exception(
            result.errorMessage,
          ),
        );
      }
      return Right(
        UserMapper.editUserOutputFromMap(result.data!),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
