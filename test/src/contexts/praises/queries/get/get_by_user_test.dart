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
  late GetPraisesByUserQuery sut;
  late Db db;
  late CreatePraiseRepository repository;

  final String userId = faker.guid.guid();
  group("GetPraisesByUserQuery: ", () {
    setUp(() async {
      db = await Db.create(TestSettings.dbConnection);
      final mongo = Mongo(db);
      await db.open();
      sut = GetPraisesByUserQuery(
        databaseDatasource: MongoDatasource(
          mongo,
        ),
      );
      repository = PraiseRepository(
        datasource: MongoDatasource(
          mongo,
        ),
      );
    });

    tearDownAll(() async {
      await db.collection("praises").drop();
    });

    test(
        "Sut should retrieve all praises (sent and received) when input.asPraiser is null",
        () async {
      for (var i = 0; i < 3; i++) {
        await createPraiseAsPraised(repository, userId);
      }
      for (var i = 0; i < 3; i++) {
        await createPraiseAsPraiser(repository, userId);
      }

      final praisesOrError = await sut(
        GetPraisesByUserInput(
          id: userId,
          asPraiser: null,
        ),
      );

      expect(praisesOrError.fold((l) => l, (r) => r), isA<QueryOutput>());
      praisesOrError.fold((l) => null, (r) {
        expect(
          r.value.length,
          equals(6),
        );
      });
    });

    test("sut should retrieve only sent praises when input.asPraiser is true",
        () async {
      await createPraiseAsPraiser(repository, userId);

      final praisesOrError = await sut(
        GetPraisesByUserInput(
          id: userId,
          asPraiser: true,
        ),
      );

      expect(praisesOrError.fold((l) => l, (r) => r), isA<QueryOutput>());
      praisesOrError.fold((l) => null, (r) {
        expect(
          r.value.length,
          equals(4),
        );
      });
    });

    test(
        "sut should retrieve only received praises when input.asPraiser is false",
        () async {
      await createPraiseAsPraised(repository, userId);
      await createPraiseAsPraised(repository, userId);

      final praisesOrError = await sut(
        GetPraisesByUserInput(
          id: userId,
          asPraiser: false,
        ),
      );

      expect(praisesOrError.fold((l) => l, (r) => r), isA<QueryOutput>());
      praisesOrError.fold((l) => null, (r) {
        expect(
          r.value.length,
          equals(5),
        );
      });
    });
  });
}

Future<void> createPraiseAsPraiser(
    CreatePraiseRepository repository, String userId) async {
  await repository.create(
    PraiseInput(
      commmunityId: faker.guid.guid(),
      message: faker.lorem.words(7).toString(),
      praisedId: faker.guid.guid(),
      praiserId: userId,
      topic: "#kind",
    )..id = faker.guid.guid(),
  );
}

Future<void> createPraiseAsPraised(
    CreatePraiseRepository repository, String userId) async {
  await repository.create(
    PraiseInput(
      commmunityId: faker.guid.guid(),
      message: faker.lorem.words(7).toString(),
      praisedId: userId,
      praiserId: faker.guid.guid(),
      topic: "#kind",
    )..id = faker.guid.guid(),
  );
}
