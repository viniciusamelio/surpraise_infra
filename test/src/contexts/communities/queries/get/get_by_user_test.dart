import 'package:faker/faker.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/collections.dart';
import 'package:surpraise_infra/src/contexts/communities/queries/queries.dart';
import 'package:surpraise_infra/src/contexts/communities/repositories/community_repository.dart';
import 'package:surpraise_infra/src/contexts/users/repositories/user_repository.dart';
import 'package:test/test.dart';

import '../../../../../test_settings.dart';

void main() {
  late GetCommunitiesByUserQuery sut;
  late CreateUserRepository userRepository;
  late CreateCommunityRepository repository;

  late final String userId;

  group("GetCommunitiesByUserQuery: ", () {
    setUpAll(() async {
      sut = GetCommunitiesByUserQuery(
        databaseDatasource: await supabaseDatasource(),
      );
      repository = CommunityRepository(
        databaseDatasource: await supabaseDatasource(),
      );
      userRepository = UserRepository(
        databaseDatasource: await supabaseDatasource(),
      );
      userId = (await supabaseClient()).auth.currentUser!.id;
      await userRepository.create(
        CreateUserInput(
          tag: "@testing-user",
          name: "testing user",
          email: faker.internet.email(),
          id: userId,
        ),
      );
    });

    tearDown(() async {
      await supabaseClient().then(
        (client) async => client.from(communitiesCollection).delete().neq(
              "id",
              faker.guid.guid(),
            ),
      );
    });

    test("sut should return all communities that given user is owner of",
        () async {
      await createCommunity(repository, userId);
      await createCommunity(repository, userId);
      await createCommunity(repository, fakeUserId);

      final communitiesOrError = await sut(
        GetCommunitiesByUserInput(id: userId),
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
      await createAndAddMember(repository, fakeUserId, userId);
      await createAndAddMember(repository, fakeUserId, userId);
      await createAndAddMember(repository, fakeUserId, userId);

      final communitiesOrError = await sut(
        GetCommunitiesByUserInput(id: userId),
      );

      expect(communitiesOrError.isRight(), isTrue);
      communitiesOrError.fold((l) => null, (r) {
        expect(
          r.value.length,
          equals(3),
        );
      });
    });

    test(
        "sut should return all communities that given user is either member or owner of",
        () async {
      await createAndAddMember(repository, fakeUserId, userId);
      await createAndAddMember(repository, fakeUserId, userId);
      await createCommunity(repository, userId);
      await createCommunity(repository, userId);

      final communitiesOrError = await sut(
        GetCommunitiesByUserInput(
          id: userId,
        ),
      );

      expect(communitiesOrError.isRight(), isTrue);
      communitiesOrError.fold((l) => null, (r) {
        expect(
          r.value.length,
          equals(4),
        );
      });
    });
  });
}

Future<CreateCommunityOutput> createCommunity(
  CreateCommunityRepository repository,
  String ownerId,
) async {
  final String id = faker.guid.guid();
  final community = await repository.createCommunity(
    CreateCommunityInput(
      description: faker.lorem.words(2).toString(),
      ownerId: ownerId,
      title: "A random testing community",
      id: id,
      imageUrl: faker.lorem.word(),
    ),
  );
  return community.fold((left) => null, (right) => right)!;
}

Future<void> createAndAddMember(
  CreateCommunityRepository repository,
  String ownerId,
  String memberId,
) async {
  final community = await createCommunity(repository, ownerId);
  await supabaseClient().then(
    (client) async => client.from(communityMembersCollection).insert(
      {
        "community_id": community.id,
        "active": true,
        "role": "member",
        "member_id": memberId,
      },
    ),
  );
}
