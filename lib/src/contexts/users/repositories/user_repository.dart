// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';
import 'package:surpraise_core/surpraise_core.dart';

import 'package:surpraise_infra/src/contexts/users/mappers/user_mapper.dart';
import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';

class UserRepository
    implements
        CreateUserRepository,
        EditUserRepository,
        InactivateUserRepository {
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
          id: input.id,
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

  @override
  Future<Either<Exception, InactivateUserOutput>> inactivate(
    InactivateUserInput input,
  ) async {
    try {
      final result = await _datasource.save(SaveQuery(
        sourceName: sourceName,
        value: {
          "id": input.id,
          "active": false,
        },
      ));
      if (result.failure) {
        return Left(
          Exception(
            result.errorMessage,
          ),
        );
      }
      return Right(
        InactivateUserOutput(),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<GetUserOutput?> getById(String id) async {
    try {
      final result = await _datasource.get(
        GetQuery(
          sourceName: sourceName,
          operator: FilterOperator.equalsTo,
          value: id,
          fieldName: "id",
        ),
      );
      if (result.failure) {
        return null;
      }
      return GetUserOutput(
        tag: result.data!["tag"],
        name: result.data!["name"],
        email: result.data!["email"],
        id: result.data!["id"],
      );
    } catch (_) {
      return null;
    }
  }
}

class GetUserOutput {
  GetUserOutput({
    required this.tag,
    required this.name,
    required this.email,
    required this.id,
  });

  final String tag;
  final String name;
  final String email;
  final String id;
}
