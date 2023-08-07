import 'package:faker/faker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/communities/queries/queries.dart';
import 'package:surpraise_infra/src/contexts/communities/repositories/community_repository.dart';
import 'package:surpraise_infra/src/datasources/mongo/mongo_datasource.dart';
import 'package:surpraise_infra/src/external/mongo/mongo.dart';
import 'package:surpraise_infra/src/query/query.dart';
import 'package:test/test.dart';

import '../../../../../test_settings.dart';

void main() {
  late GetCommunityQuery sut;
  late Db db;
  late CreateCommunityRepository communityRepository;

  final String communityId = faker.guid.guid();

  Future<void> createCommunity(final String id) async {
    await communityRepository.createCommunity(
      CreateCommunityInput(
        description: faker.lorem.words(3).toString(),
        ownerId: faker.guid.guid(),
        title: faker.lorem.word(),
        id: id,
        imageUrl: faker.lorem.word(),
      ),
    );
  }

  group("GetCommunityQuery: ", () {
    setUp(() async {
      db = Db(TestSettings.dbConnection);
      await db.open();
      final mongo = Mongo(db);
      sut = GetCommunityQuery(
        databaseDatasource: MongoDatasource(mongo, TestSettings.dbConnection),
      );
      communityRepository = CommunityRepository(
        databaseDatasource: MongoDatasource(mongo, TestSettings.dbConnection),
      );
    });

    tearDownAll(() async {
      await db.collection("communities").drop();
    });

    test("sut should retrieve found community", () async {
      await createCommunity(communityId);

      final communityOrError = await sut(
        GetCommunityInput(
          id: communityId,
        ),
      );

      expect(communityOrError.isRight(), isTrue);
      communityOrError.fold((l) => null, (r) {
        expect(
          r.value["id"],
          equals(communityId),
        );
      });
    });

    test("sut should returns an error when community is not found", () async {
      await createCommunity(faker.guid.guid());

      final communityOrError = await sut(
        GetCommunityInput(
          id: faker.guid.guid(),
        ),
      );

      expect(communityOrError.isLeft(), isTrue);
      expect(
        (communityOrError.fold((l) => l, (r) => null) as QueryError).code,
        equals(
          404,
        ),
      );
    });
  });
}
