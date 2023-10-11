import 'package:faker/faker.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/collections.dart';
import 'package:surpraise_infra/surpraise_infra.dart';

import 'test_settings.dart';

Future<void> addCommunityMember({
  required String communityId,
  required String userId,
}) async {
  await supabaseClient().then(
    (client) async => client.from(communityMembersCollection).insert(
      {
        "community_id": communityId,
        "active": true,
        "role": "member",
        "member_id": userId,
      },
    ),
  );
}

Future<void> createPraise(
  CreatePraiseRepository repository,
  String communityId,
) async {
  final CreateUserRepository userRepository = UserRepository(
    databaseDatasource: SupabaseDatasource(
      supabase: await supabaseClient(),
    ),
  );

  final praisedId = fakeUserId;
  await userRepository.create(
    CreateUserInput(
      id: praisedId,
      tag: "@testingUser${faker.randomGenerator.integer(20)}",
      name: faker.lorem.word(),
      email: faker.internet.email(),
    ),
  );

  await repository.create(
    PraiseInput(
      commmunityId: communityId,
      message: faker.lorem.words(7).toString(),
      praisedId: praisedId,
      praiserId:
          await supabaseClient().then((value) => value.auth.currentUser!.id),
      topic: "#kind",
    )..id = faker.guid.guid(),
  );
}
