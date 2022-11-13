import 'package:faker/faker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/praises/queries/queries.dart';
import 'package:surpraise_infra/src/contexts/praises/repositories/praise_repository.dart';
import 'package:surpraise_infra/src/datasources/mongo/mongo_datasource.dart';
import 'package:surpraise_infra/src/external/mongo/mongo.dart';
import 'package:surpraise_infra/src/query/query.dart';
import 'package:test/test.dart';

import '../../../../../test_settings.dart';

void main() {
  late GetPraiseQuery sut;
  late CreatePraiseRepository praiseRepository;
  late Db db;

  final String praiseId = faker.guid.guid();

  group("CreatePraiseRepository: ", () {
    setUp(() async {
      db = Db(TestSettings.dbConnection);
      await db.open();

      final mongo = Mongo(db);

      sut = GetPraiseQuery(
        databaseDatasource: MongoDatasource(
          mongo,
        ),
      );
      praiseRepository = PraiseRepository(
        datasource: MongoDatasource(
          mongo,
        ),
      );
    });

    Future<void> createPraise(String praiseId) async {
      await praiseRepository.create(
        PraiseInput(
          commmunityId: faker.guid.guid(),
          message: faker.lorem.word(),
          praisedId: faker.guid.guid(),
          praiserId: faker.guid.guid(),
          topic: "#tech",
        )..id = praiseId,
      );
    }

    tearDownAll(() async {
      await db.collection("praises").drop();
    });

    test("sut should return found praise", () async {
      await createPraise(praiseId);

      final praiseOrError = await sut(
        GetPraiseInput(
          id: praiseId,
        ),
      );

      expect(praiseOrError.isRight(), isTrue);
      praiseOrError.fold((l) => null, (r) {
        expect(
          r.value["id"],
          equals(praiseId),
        );
      });
    });

    test("sut should return error when praise isnt found", () async {
      await createPraise(praiseId);

      final praiseOrError = await sut(
        GetPraiseInput(
          id: faker.guid.guid(),
        ),
      );

      expect(praiseOrError.isLeft(), isTrue);
      expect(
        (praiseOrError.fold((l) => l, (r) => null) as QueryError).code,
        equals(404),
      );
    });
  });
}
