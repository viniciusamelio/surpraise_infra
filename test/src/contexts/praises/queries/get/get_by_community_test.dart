import 'package:faker/faker.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/collections.dart';
import 'package:surpraise_infra/surpraise_infra.dart';
import 'package:test/test.dart';

import '../../../../../test_settings.dart';
import '../../../../../test_utils.dart';

void main() {
  late GetPraisesByCommunityQuery sut;
  late CreatePraiseRepository repository;
  late final String communityId;

  group("GetPraisesByCommunityQuery: ", () {
    setUpAll(() async {
      final communityRepository = CommunityRepository(
        databaseDatasource: SupabaseDatasource(
          supabase: await supabaseClient(),
        ),
      );
      final community = await communityRepository.createCommunity(
        CreateCommunityInput(
          description: faker.lorem.words(5).toString(),
          ownerId: await supabaseClient().then(
            (client) => client.auth.currentUser!.id,
          ),
          title: faker.lorem.word(),
          id: faker.guid.guid(),
          imageUrl: faker.lorem.word(),
        ),
      );
      communityId = community.fold((left) => "", (right) => right.id);
      await addCommunityMember(communityId: communityId, userId: fakeUserId);
    });
    setUp(() async {
      sut = GetPraisesByCommunityQuery(
        databaseDatasource: SupabaseDatasource(
          supabase: await supabaseClient(),
        ),
      );
      repository = PraiseRepository(
        datasource: SupabaseDatasource(
          supabase: await supabaseClient(),
        ),
      );
    });

    tearDownAll(() async {
      await supabaseClient().then(
        (client) async => await client.from(praisesCollection).delete().neq(
              "id",
              faker.guid.guid(),
            ),
      );
    });

    test("sut should retrieve all praises from a given community", () async {
      await createPraise(repository, communityId);
      await createPraise(repository, communityId);

      final praisesOrError = await sut(
        GetPraisesByCommunityInput(
          id: communityId,
        ),
      );

      expect(praisesOrError.isRight(), isTrue);
      praisesOrError.fold((l) => null, (r) {
        expect(r.value.length, equals(2));
      });
    });

    test("sut should retrieve limited praises from a given community",
        () async {
      await createPraise(repository, communityId);
      await createPraise(repository, communityId);

      final praisesOrError = await sut(
        GetPraisesByCommunityInput(
          id: communityId,
          limit: 2,
          offset: 2,
        ),
      );

      expect(praisesOrError.isRight(), isTrue);
      praisesOrError.fold((l) => null, (r) {
        expect(r.value.length, equals(2));
      });
    });

    test("sut should retrieve no praises from an unexisting community",
        () async {
      final praisesOrError = await sut(
        GetPraisesByCommunityInput(
          id: "aRandomNotUsedId",
        ),
      );

      expect(praisesOrError.isLeft(), isTrue);
    });
  });
}
