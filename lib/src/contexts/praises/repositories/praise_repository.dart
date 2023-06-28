// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/praises/mappers/praise_mapper.dart';

import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';

class PraiseRepository
    implements CreatePraiseRepository, FindPraiseUsersRepository {
  PraiseRepository({
    required DatabaseDatasource datasource,
  }) : _datasource = datasource;

  final DatabaseDatasource _datasource;

  String get sourceName => "praises";

  @override
  Future<Either<Exception, PraiseOutput>> create(PraiseInput input) async {
    try {
      final rawPraiseData = PraiseMapper.inputToMap(input);
      final praised = await _datasource.get(
        GetQuery(
          sourceName: "users",
          operator: FilterOperator.equalsTo,
          value: input.praisedId,
          fieldName: "id",
        ),
      );

      if (praised.data == null || praised.failure) {
        return Left(
          Exception("Praised user not found"),
        );
      }

      final result = await _datasource.save(
        SaveQuery(
          sourceName: sourceName,
          value: {
            ...rawPraiseData,
            "praised": praised.data!,
          },
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

  @override
  Future<Either<Exception, FindPraiseUsersDto>> find({
    required String praiserId,
    required String praisedId,
  }) async {
    try {
      final praised = await _datasource.get(
        GetQuery(
          sourceName: "users",
          operator: FilterOperator.equalsTo,
          value: praisedId,
          fieldName: "id",
        ),
      );

      final praiser = await _datasource.get(
        GetQuery(
          sourceName: "users",
          operator: FilterOperator.equalsTo,
          value: praiserId,
          fieldName: "id",
        ),
      );

      if (praised.failure || praiser.failure) {
        return Left(
          Exception(praised.errorMessage ?? praiser.errorMessage),
        );
      }

      return Right(
        FindPraiseUsersDto(
          praisedDto: PraisedDto(
            tag: praised.data!["tag"],
            communities:
                ((praised.data!["communities"] ?? []) as List).cast<String>(),
          ),
          praiserDto: PraiserDto(
            tag: praiser.data!["tag"],
            communities:
                ((praiser.data!["communities"] ?? []) as List).cast<String>(),
          ),
        ),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
