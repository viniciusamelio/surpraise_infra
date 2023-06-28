import 'package:faker/faker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/surpraise_infra.dart';
import 'package:test/test.dart';

import '../../../../../test_settings.dart';

void main() {
  late GetPraisesByUserQuery sut;
  late Db db;
  late CreatePraiseRepository repository;

  late String userId;
  late String anotherPraisingUserId;
  group("GetPraisesByUserQuery: ", () {
    setUp(() async {
      db = await Db.create(TestSettings.dbConnection);
      final mongo = Mongo(db);
      await db.open();
      sut = GetPraisesByUserQuery(
        databaseDatasource: MongoDatasource(mongo, TestSettings.dbConnection),
      );
      repository = PraiseRepository(
        datasource: MongoDatasource(mongo, TestSettings.dbConnection),
      );
    });

    setUpAll(() async {
      db = await Db.create(TestSettings.dbConnection);
      final mongo = Mongo(db);
      await db.open();

      final CreateUserRepository userRepository = UserRepository(
        databaseDatasource: MongoDatasource(
          mongo,
          TestSettings.dbConnection,
        ),
      );

      final praisedId = faker.guid.guid();
      anotherPraisingUserId = faker.guid.guid();
      await userRepository.create(
        CreateUserInput(
          id: praisedId,
          tag: "@testingUser${faker.randomGenerator.integer(20)}",
          name: faker.lorem.word(),
          email: faker.internet.email(),
        ),
      );
      await userRepository.create(
        CreateUserInput(
          id: anotherPraisingUserId,
          tag: "@testingUser${faker.randomGenerator.integer(20)}",
          name: faker.lorem.word(),
          email: faker.internet.email(),
        ),
      );

      userId = praisedId;
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
          await createPraiseAsPraiser(
            repository,
            userId,
            anotherPraisingUserId,
          );
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
      },
    );

    test("sut should retrieve only sent praises when input.asPraiser is true",
        () async {
      await createPraiseAsPraiser(
        repository,
        userId,
        anotherPraisingUserId,
      );

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
  CreatePraiseRepository repository,
  String userId,
  String anotherPraisingUserId,
) async {
  await repository.create(
    PraiseInput(
      commmunityId: faker.guid.guid(),
      message: faker.lorem.words(7).toString(),
      praisedId: anotherPraisingUserId,
      praiserId: userId,
      topic: "#kind",
    )..id = faker.guid.guid(),
  );
}

Future<void> createPraiseAsPraised(
  CreatePraiseRepository repository,
  String userId,
) async {
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
