import 'package:faker/faker.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/collections.dart';
import 'package:surpraise_infra/surpraise_infra.dart';
import 'package:test/test.dart';

import '../../../../../test_settings.dart';

void main() {
  late final GetReceivedPraisesQuery sut;
  late final CreatePraiseRepository repository;
  late final CommunityRepository communityRepository;

  late String userId;
  late String anotherPraisingUserId;
  group("GetReceivedPraisesQuery: ", () {
    setUp(() async {});

    setUpAll(() async {
      final CreateUserRepository userRepository = UserRepository(
        databaseDatasource: await supabaseDatasource(),
      );

      final praisedId = await supabaseClient().then(
        (value) => value.auth.currentUser!.id,
      );
      anotherPraisingUserId = fakeUserId;
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

      sut = GetReceivedPraisesQuery(
        databaseDatasource: await supabaseDatasource(),
      );
      repository = PraiseRepository(
        datasource: await supabaseDatasource(),
      );
      communityRepository = CommunityRepository(
        databaseDatasource: await supabaseDatasource(),
      );
    });

    tearDownAll(() async {
      await supabaseClient().then(
        (value) => value.from(praisesCollection).delete().neq(
              "id",
              faker.guid.guid(),
            ),
      );
    });

    test(
      "Sut should return received praises",
      () async {
        await createPraiseAsPraised(
          repository,
          communityRepository,
          userId,
        );
        await createPraiseAsPraised(
          repository,
          communityRepository,
          userId,
        );

        final result = await sut(
          GetPraisesByUserInput(
            id: userId,
          ),
        );

        expect(result.isRight(), isTrue);
        result.fold((l) => null, (r) {
          expect(
            r.value.length,
            equals(2),
          );
        });
      },
    );

    test(
      "Sut should return not found error when member has received no praises",
      () async {
        await createPraiseAsPraised(
          repository,
          communityRepository,
          userId,
        );
        await createPraiseAsPraised(
          repository,
          communityRepository,
          userId,
        );

        final result = await sut(
          GetPraisesByUserInput(
            id: anotherPraisingUserId,
          ),
        );

        expect(result.isRight(), isFalse);
        expect(result.fold((left) => left, (right) => null), isA<QueryError>());
        expect(result.fold((left) => left.code, (right) => null), equals(404));
      },
    );

    test(
      "Sut should return not found error when querying unexisting member",
      () async {
        final result = await sut(
          GetPraisesByUserInput(
            id: faker.guid.guid(),
          ),
        );

        expect(result.isRight(), isFalse);
        expect(result.fold((left) => left, (right) => null), isA<QueryError>());
        expect(result.fold((left) => left.code, (right) => null), equals(404));
      },
    );
  });
}

Future<void> createPraiseAsPraised(
  CreatePraiseRepository repository,
  CreateCommunityRepository communityRepository,
  String userId,
) async {
  final communityId = faker.guid.guid();
  await communityRepository.createCommunity(
    CreateCommunityInput(
      description: faker.lorem.words(2).join(""),
      ownerId: fakeUserId,
      title: faker.lorem.word(),
      imageUrl: faker.internet.httpsUrl(),
      id: communityId,
    ),
  );
  await repository.create(
    PraiseInput(
      commmunityId: communityId,
      message: faker.lorem.words(7).toString(),
      praisedId: userId,
      praiserId: fakeUserId,
      topic: "#kind",
    )..id = faker.guid.guid(),
  );
}
