import 'package:faker/faker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/communities/queries/queries.dart';
import 'package:surpraise_infra/src/contexts/communities/repositories/community_repository.dart';
import 'package:surpraise_infra/src/contexts/users/repositories/user_repository.dart';
import 'package:surpraise_infra/src/datasources/mongo/mongo_datasource.dart';
import 'package:surpraise_infra/src/external/mongo/mongo.dart';
import 'package:test/test.dart';

import '../../../../../test_settings.dart';

void main() {
  late GetCommunitiesByUserQuery sut;
  late CreateUserRepository userRepository;
  late Db db;
  late CreateCommunityRepository repository;

  final String userId = faker.guid.guid();

  group("GetCommunitiesByUserQuery: ", () {
    setUp(() async {
      db = await Db.create(TestSettings.dbConnection);
      final mongo = Mongo(db);
      await db.open();
      sut = GetCommunitiesByUserQuery(
        databaseDatasource: MongoDatasource(
          mongo,
        ),
      );
      repository = CommunityRepository(
        databaseDatasource: MongoDatasource(
          mongo,
        ),
      );
      userRepository = UserRepository(
        databaseDatasource: MongoDatasource(
          mongo,
        ),
      );

      await userRepository.create(
        CreateUserInput(
          tag: "@testing-user",
          name: "testing user",
          email: faker.internet.email(),
          id: userId,
        ),
      );
    });

    tearDownAll(() async {
      await db.collection("communities").drop();
      await db.collection("users").drop();
    });

    test("sut should return all communities that given user is owner of",
        () async {
      await createCommunity(repository, userId);
      await createCommunity(repository, userId);
      await createCommunity(repository, faker.guid.guid());

      final communitiesOrError = await sut(
        GetCommunitiesByUserInput(id: userId, asOwner: true),
      );

      expect(communitiesOrError.isRight(), isTrue);
      communitiesOrError.fold((l) => null, (r) {
        expect(
          r.value.length,
          equals(2),
        );
      });
    });

    test("sut should return all communities that given user is member of",
        () async {
      await createAndAddMember(repository, faker.guid.guid(), userId);
      await createAndAddMember(repository, faker.guid.guid(), userId);
      await createAndAddMember(repository, faker.guid.guid(), userId);

      final communitiesOrError = await sut(
        GetCommunitiesByUserInput(id: userId, asOwner: false),
      );

      expect(communitiesOrError.isRight(), isTrue);
      communitiesOrError.fold((l) => null, (r) {
        expect(
          r.value.length,
          equals(3),
        );
      });
    });
  });
}

Future<String> createCommunity(
  CreateCommunityRepository repository,
  String ownerId,
) async {
  final String id = faker.guid.guid();
  await repository.createCommunity(
    CreateCommunityInput(
      description: faker.lorem.words(2).toString(),
      ownerId: ownerId,
      title: "A random testing community",
      id: id,
    ),
  );
  return id;
}

Future<void> createAndAddMember(
  CreateCommunityRepository repository,
  String ownerId,
  String memberId,
) async {
  final id = await createCommunity(repository, ownerId);
  await (repository as CommunityRepository).addMembers(
    AddMembersInput(
      idCommunity: id,
      members: [
        MemberToAdd(
          idMember: memberId,
          role: "member",
        ),
      ],
    ),
  );
}
