import 'package:faker/faker.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/collections.dart';
import 'package:surpraise_infra/src/contexts/communities/queries/queries.dart';
import 'package:surpraise_infra/src/contexts/communities/repositories/community_repository.dart';
import 'package:surpraise_infra/src/query/query.dart';
import 'package:test/test.dart';

import '../../../../../test_settings.dart';

void main() {
  late GetCommunityQuery sut;
  late CreateCommunityRepository communityRepository;

  final String communityId = faker.guid.guid();

  Future<void> createCommunity(final String id) async {
    await communityRepository.createCommunity(
      CreateCommunityInput(
        description: faker.lorem.words(3).toString(),
        ownerId: await supabaseClient().then(
          (client) => client.auth.currentUser!.id,
        ),
        title: faker.lorem.word(),
        id: id,
        imageUrl: faker.lorem.word(),
      ),
    );
  }

  group("GetCommunityQuery: ", () {
    setUpAll(() async {
      sut = GetCommunityQuery(
        databaseDatasource: await supabaseDatasource(),
      );
      communityRepository = CommunityRepository(
        databaseDatasource: await supabaseDatasource(),
      );
    });

    tearDownAll(() async {
      await supabaseClient().then(
        (client) async => client.from(communitiesCollection).delete().neq(
              "id",
              faker.guid.guid(),
            ),
      );
    });

    test("sut should retrieve found community", () async {
      await createCommunity(communityId);

      final communityOrError = await sut(
        GetCommunityInput(
          id: communityId,
        ),
      );

      expect(communityOrError.isRight(), isTrue);
      communityOrError.fold((l) => null, (r) {
        expect(
          r.value.id,
          equals(communityId),
        );
      });
    });

    test("sut should return an error when community is not found", () async {
      await createCommunity(faker.guid.guid());

      final communityOrError = await sut(
        GetCommunityInput(
          id: faker.guid.guid(),
        ),
      );

      expect(communityOrError.isLeft(), isTrue);
      expect(
        (communityOrError.fold((l) => l, (r) => null) as QueryError).code,
        equals(
          404,
        ),
      );
    });
  });
}
