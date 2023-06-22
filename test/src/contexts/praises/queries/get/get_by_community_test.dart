import 'package:faker/faker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/praises/queries/queries.dart';
import 'package:surpraise_infra/src/contexts/praises/repositories/praise_repository.dart';
import 'package:surpraise_infra/src/datasources/mongo/mongo_datasource.dart';
import 'package:surpraise_infra/src/external/mongo/mongo.dart';
import 'package:test/test.dart';

import '../../../../../test_settings.dart';

void main() {
  late GetPraisesByCommunityQuery sut;

  late Db db;
  late CreatePraiseRepository repository;

  final String communityId = faker.guid.guid();

  group("GetPraisesByCommunityQuery: ", () {
    setUp(() async {
      db = await Db.create(TestSettings.dbConnection);
      final mongo = Mongo(db);
      await db.open();
      sut = GetPraisesByCommunityQuery(
        databaseDatasource: MongoDatasource(mongo, TestSettings.dbConnection),
      );
      repository = PraiseRepository(
        datasource: MongoDatasource(mongo, TestSettings.dbConnection),
      );
    });

    tearDownAll(() async {
      await db.collection("praises").drop();
    });

    test("sut should retrieve all praises from a given community", () async {
      await createPraise(repository, communityId);
      await createPraise(repository, communityId);
      await createPraise(repository, faker.guid.guid());

      final praisesOrError = await sut(
        GetPraisesByCommunityInput(
          id: communityId,
        ),
      );

      expect(praisesOrError.isRight(), isTrue);
      praisesOrError.fold((l) => null, (r) {
        expect(r.value.length, equals(2));
      });
    });

    test("sut should retrieve no praises from a dataless community ", () async {
      final praisesOrError = await sut(
        GetPraisesByCommunityInput(
          id: "aRandomNotUsedId",
        ),
      );

      expect(praisesOrError.isRight(), isTrue);
      praisesOrError.fold((l) => null, (r) {
        expect(r.value, isEmpty);
      });
    });
  });
}

Future<void> createPraise(
  CreatePraiseRepository repository,
  String communityId,
) async {
  await repository.create(
    PraiseInput(
      commmunityId: communityId,
      message: faker.lorem.words(7).toString(),
      praisedId: faker.guid.guid(),
      praiserId: faker.guid.guid(),
      topic: "#kind",
    )..id = faker.guid.guid(),
  );
}
