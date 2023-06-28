import 'package:faker/faker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/surpraise_infra.dart';
import 'package:test/test.dart';

import '../../../../../test_settings.dart';

void main() {
  late GetPraiseQuery sut;
  late CreatePraiseRepository praiseRepository;
  late CreateUserRepository userRepository;
  late CreateCommunityRepository communityRepository;
  late Db db;

  final String praiseId = faker.guid.guid();

  group("CreatePraiseRepository: ", () {
    setUp(() async {
      db = Db(TestSettings.dbConnection);
      await db.open();

      final mongo = Mongo(db);

      sut = GetPraiseQuery(
        databaseDatasource: MongoDatasource(mongo, TestSettings.dbConnection),
      );
      communityRepository = CommunityRepository(
        databaseDatasource: MongoDatasource(mongo, TestSettings.dbConnection),
      );
      userRepository = UserRepository(
        databaseDatasource: MongoDatasource(mongo, TestSettings.dbConnection),
      );
      praiseRepository = PraiseRepository(
        datasource: MongoDatasource(mongo, TestSettings.dbConnection),
      );
    });

    Future<void> createPraise(String praiseId) async {
      final user = await userRepository.create(
        CreateUserInput(
          id: faker.guid.guid(),
          tag: "@testingUser${faker.randomGenerator.integer(20)}",
          name: faker.lorem.word(),
          email: faker.internet.email(),
        ),
      );
      await communityRepository.createCommunity(
        CreateCommunityInput(
          description: faker.lorem.words(5).toString(),
          ownerId: user.fold((left) => null, (right) => right)!.id,
          title: faker.lorem.word(),
          id: faker.guid.guid(),
        ),
      );

      await praiseRepository.create(
        PraiseInput(
          commmunityId: faker.guid.guid(),
          message: faker.lorem.word(),
          praisedId: user.fold((left) => null, (right) => right)!.id,
          praiserId: faker.guid.guid(),
          topic: "#tech",
        )..id = praiseId,
      );
    }

    tearDownAll(() async {
      await db.collection("praises").drop();
    });

    test(
      "sut should return found praise",
      () async {
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
      },
    );

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
