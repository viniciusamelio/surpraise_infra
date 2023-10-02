import 'dart:convert';

import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/praises/mappers/praise_mapper.dart';

import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';
import 'package:surpraise_infra/src/datasources/database/result.dart';

import "package:http/http.dart" as http;

import '../../collections.dart';

class PraiseRepository
    implements CreatePraiseRepository, FindPraiseUsersRepository {
  PraiseRepository({
    required DatabaseDatasource datasource,
  }) : _datasource = datasource;

  final DatabaseDatasource _datasource;

  String get sourceName => praisesCollection;

  @override
  Future<Either<Exception, PraiseOutput>> create(PraiseInput input) async {
    try {
      final rawPraiseData = PraiseMapper.inputToMap(input);
      final praised = await _getUserData(input.praisedId);
      final praiser = await _getUserData(input.praiserId);
      final community = await _datasource.get(
        GetQuery(
          sourceName: communitiesCollection,
          operator: FilterOperator.equalsTo,
          value: input.commmunityId,
          fieldName: "id",
        ),
      );

      if (praised.failure || praised.multiData!.isEmpty) {
        return Left(
          Exception("Praised user not found"),
        );
      } else if (community.failure || community.multiData!.isEmpty) {
        return Left(
          Exception("Community not found"),
        );
      } else if (praiser.failure || praiser.multiData!.isEmpty) {
        return Left(
          Exception("Praiser user not found"),
        );
      }

      final result = await _datasource.save(
        SaveQuery(
          sourceName: sourceName,
          value: rawPraiseData,
        ),
      );
      if (result.failure) {
        return Left(
          Exception(result.errorMessage),
        );
      }
      final url = String.fromEnvironment("NOTIFICATOR_URL");
      http.post(
        Uri.parse(url),
        body: jsonEncode(
          {
            "praise": {
              "praised": praised.multiData![0],
              "message": input.message,
              "topic": input.topic,
            },
          },
        ),
      );
      return Right(
        PraiseOutput(),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<QueryResult> _getUserData(String userId) {
    return _datasource.get(
      GetQuery(
        sourceName: profilesCollection,
        operator: FilterOperator.equalsTo,
        value: userId,
        fieldName: "id",
      ),
    );
  }

  @override
  Future<Either<Exception, FindPraiseUsersDto>> find({
    required String praiserId,
    required String praisedId,
  }) async {
    try {
      final praised = await _datasource.get(
        GetQuery(
          sourceName: profilesCollection,
          operator: FilterOperator.equalsTo,
          value: praisedId,
          fieldName: "id",
          select: "id, tag, $communityMembersCollection(community_id)",
        ),
      );

      final praiser = await _datasource.get(
        GetQuery(
          sourceName: profilesCollection,
          operator: FilterOperator.equalsTo,
          value: praiserId,
          fieldName: "id",
          select: "id, tag, $communityMembersCollection(community_id)",
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
            tag: praised.multiData![0]["tag"],
            communities: (praised.multiData![0][communityMembersCollection]
                    .map(
                      (e) => e["community_id"],
                    )
                    .toList() as List)
                .cast<String>(),
          ),
          praiserDto: PraiserDto(
            tag: praiser.multiData![0]["tag"],
            communities: (praiser.multiData![0][communityMembersCollection]
                    .map(
                      (e) => e["community_id"],
                    )
                    .toList() as List)
                .cast<String>(),
          ),
        ),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
