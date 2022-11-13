// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/praises/mappers/praise_mapper.dart';

import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';

class PraiseRepository implements CreatePraiseRepository {
  PraiseRepository({
    required DatabaseDatasource datasource,
  }) : _datasource = datasource;

  final DatabaseDatasource _datasource;

  String get sourceName => "praises";

  @override
  Future<Either<Exception, PraiseOutput>> create(PraiseInput input) async {
    try {
      final result = await _datasource.save(
        SaveQuery(
          sourceName: sourceName,
          value: PraiseMapper.inputToMap(input),
        ),
      );
      if (result.failure) {
        return Left(
          Exception(result.errorMessage),
        );
      }
      return Right(
        PraiseOutput(),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
