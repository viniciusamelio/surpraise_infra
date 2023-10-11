import 'package:faker/faker.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/collections.dart';
import 'package:surpraise_infra/surpraise_infra.dart';
import 'package:test/test.dart';

import '../../../../test_settings.dart';

void main() {
  late PraiseRepository sut;
  late DatabaseDatasource datasource;
  late String id;
  late PraiseInput input;

  setUpAll(() async {
    id = await supabaseClient().then((value) => value.auth.currentUser!.id);
    datasource = SupabaseDatasource(
      supabase: await supabaseClient(),
    );

    final praisedId = "c80630d6-8c97-48b0-8c2e-524a191b887b";

    final CreateUserRepository userRepository = UserRepository(
      databaseDatasource: datasource,
    );

    final CommunityRepository communityRepository = CommunityRepository(
      databaseDatasource: datasource,
    );

    final newUser = await userRepository.create(
      CreateUserInput(
        tag: "@testingUser${faker.randomGenerator.integer(20)}",
        name: faker.lorem.word(),
        email: faker.internet.email(),
        id: praisedId,
      ),
    );

    final community = await communityRepository.createCommunity(
      CreateCommunityInput(
        description: faker.lorem.words(5).toString(),
        ownerId: id,
        title: faker.lorem.word(),
        id: faker.guid.guid(),
        imageUrl: faker.internet.httpsUrl(),
      ),
    );

    await supabaseClient().then(
      (client) async => client.from(communityMembersCollection).insert(
        {
          "community_id": community.fold((left) => null, (right) => right)!.id,
          "active": true,
          "role": "member",
          "member_id": newUser.fold((left) => null, (right) => right)!.id,
        },
      ),
    );

    input = PraiseInput(
      commmunityId: community.fold((left) => "", (right) => right.id),
      message: faker.lorem.words(6).toString(),
      praisedId: praisedId,
      praiserId: id,
      topic: "#test",
    );
    input.id = id;
    sut = PraiseRepository(datasource: datasource);
  });

  tearDownAll(() async {
    datasource.delete(
      GetQuery(
        sourceName: praisesCollection,
        value: id,
        fieldName: "id",
      ),
    );
  });

  group("Praise Repository: ", () {
    test('Should create a praise', () async {
      final result = await sut.create(input);

      expect(result.isRight(), isTrue);
    });
  });
}
