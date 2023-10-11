import 'package:faker/faker.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/collections.dart';
import 'package:surpraise_infra/surpraise_infra.dart';
import 'package:test/test.dart';

import '../../../../../test_settings.dart';
import '../../../../../test_utils.dart';

void main() {
  late GetPraiseQuery sut;
  late CreatePraiseRepository praiseRepository;
  late CreateCommunityRepository communityRepository;

  late final String communityId;

  group("GetPraiseQuery: ", () {
    setUpAll(() async {
      final datasource = await supabaseDatasource();

      sut = GetPraiseQuery(
        databaseDatasource: datasource,
      );
      communityRepository = CommunityRepository(
        databaseDatasource: datasource,
      );
      final community = await communityRepository.createCommunity(
        CreateCommunityInput(
          id: faker.guid.guid(),
          description: faker.lorem.words(5).toString(),
          ownerId: await supabaseClient().then(
            (client) => client.auth.currentUser!.id,
          ),
          title: faker.lorem.word(),
          imageUrl: faker.lorem.word(),
        ),
      );
      communityId = community.fold((left) => "", (right) => right.id);

      praiseRepository = PraiseRepository(
        datasource: datasource,
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
      "sut should return found praise",
      () async {
        final id = await createPraise(
          praiseRepository,
          communityId,
        );

        final praiseOrError = await sut(
          GetPraiseInput(
            id: id,
          ),
        );

        expect(praiseOrError.isRight(), isTrue);
        praiseOrError.fold((l) => null, (r) {
          expect(
            r.value.id,
            equals(id),
          );
        });
      },
    );

    test("sut should return error when praise isnt found", () async {
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
