import 'package:faker/faker.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/collections.dart';
import 'package:surpraise_infra/src/surpraise_infra_base.dart';
import 'package:test/test.dart';

import '../../../../test_settings.dart';
import '../../../../test_utils.dart';

void main() {
  late CommunityRepository sut;
  group("Community Repository: ", () {
    late final String userId;
    late final CreateCommunityInput createCommunityInput;
    late final String communityId;

    final newMembers = [
      MemberToAdd(
        idMember: faker.guid.guid(),
        role: "member",
      ),
      MemberToAdd(
        idMember: faker.guid.guid(),
        role: "member",
      ),
    ];

    setUpAll(() async {
      userId = (await supabaseClient()).auth.currentUser!.id;
      createCommunityInput = CreateCommunityInput(
        description: faker.lorem.words(3).toString(),
        ownerId: userId,
        title: faker.lorem.word(),
        id: faker.guid.guid(),
        imageUrl: faker.internet.httpsUrl(),
      );
      sut = CommunityRepository(
        databaseDatasource: SupabaseDatasource(
          supabase: await supabaseClient(),
        ),
      );
    });

    tearDownAll(() async {
      await supabaseClient().then((client) async =>
          client.from(invitesCollection).delete().neq("id", faker.guid.guid()));
      await supabaseClient().then((client) async => client
          .from(communitiesCollection)
          .delete()
          .neq("id", faker.guid.guid()));
    });

    test('Sut should create a community', () async {
      final result = await sut.createCommunity(createCommunityInput);

      expect(result.isRight(), isTrue);
      result.fold((l) => null, (r) {
        communityId = r.id;
        expect(r.ownerId, equals(createCommunityInput.ownerId));
        expect(r.title, equals(createCommunityInput.title));
        expect(r.description, equals(createCommunityInput.description));
      });
    });

    test(
      "Sut should find created community",
      () async {
        final result = await sut.find(
          FindCommunityInput(id: communityId),
        );

        expect(result.isRight(), isTrue);
        result.fold((l) => null, (r) {
          expect(r.ownerId, equals(createCommunityInput.ownerId));
          expect(r.title, equals(createCommunityInput.title));
          expect(r.description, equals(createCommunityInput.description));
          expect(r.members, isNotEmpty);
          expect(r.members.length, equals(1));
        });
      },
      retry: 3,
    );

    test("Sut should remove members", () async {
      final result = await sut.removeMembers(
        RemoveMembersInput(
          communityId: createCommunityInput.id!,
          reason: "'Cause i wanted",
          moderator: MemberDto(
            id: faker.guid.guid(),
            role: "moderator",
          ),
          members: newMembers
              .map(
                (e) => MemberDto(
                  id: e.idMember,
                  role: "member",
                ),
              )
              .toList(),
        ),
      );
      final getResult = await sut.find(FindCommunityInput(
        id: createCommunityInput.id!,
      ));

      expect(result.isRight(), isTrue);
      getResult.fold((l) => null, (r) {
        expect(
          r.members.length,
          equals(1),
        );
      });
    });

    test("Sut should delete community", () async {
      final result =
          await sut.delete(DeleteCommunityInput(id: createCommunityInput.id!));
      final getResult = await sut.find(
        FindCommunityInput(
          id: createCommunityInput.id!,
        ),
      );

      expect(result.isRight(), isTrue);
      expect(getResult.isRight(), isFalse);
      expect(getResult.fold((l) => l, (r) => r), isA<Exception>());
    });

    test(
      "Sut should return community with pending invites",
      () async {
        final communityOrError = await sut.createCommunity(
          CreateCommunityInput(
            description: faker.lorem.words(2).toString(),
            ownerId: userId,
            title: faker.lorem.sentence(),
            imageUrl: faker.internet.httpsUrl(),
          ),
        );
        final communityId =
            communityOrError.fold((left) => null, (right) => right.id)!;

        expect(communityOrError.isRight(), isTrue);
        await inviteMember(
          communityId: communityId,
          memberId: fakeUserId,
          role: Role.member.value,
        );

        final result = await sut.find(
          FindCommunityInput(
            id: communityId,
            withInvites: true,
          ),
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (left) => null,
          (right) {
            expect(right.members.length, equals(1));
            expect(right.invites.length, equals(1));
          },
        );
      },
    );
  });
}
