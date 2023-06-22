import 'package:faker/faker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/communities/repositories/community_repository.dart';
import 'package:surpraise_infra/src/datasources/mongo/mongo_datasource.dart';
import 'package:surpraise_infra/src/external/mongo/mongo.dart';
import 'package:test/test.dart';

import '../../../../test_settings.dart';

void main() {
  late CommunityRepository sut;
  late Db db;
  group("Community Repository: ", () {
    final CreateCommunityInput createCommunityInput = CreateCommunityInput(
      description: faker.lorem.words(3).toString(),
      ownerId: faker.guid.guid(),
      title: faker.lorem.word(),
      id: faker.guid.guid(),
    );

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
      db = await Db.create(TestSettings.dbConnection);
      await db.open();
      sut = CommunityRepository(
        databaseDatasource: MongoDatasource(
          Mongo(
            db,
          ),
          TestSettings.dbConnection,
        ),
      );
    });

    tearDownAll(() async {
      await db.collection(sut.sourceName).drop();
    });

    test('Sut should create a community', () async {
      final result = await sut.createCommunity(createCommunityInput);

      expect(result.isRight(), isTrue);
      result.fold((l) => null, (r) {
        expect(r.id, equals(createCommunityInput.id));
        expect(r.ownerId, equals(createCommunityInput.ownerId));
        expect(r.title, equals(createCommunityInput.title));
        expect(r.description, equals(createCommunityInput.description));
      });
    });

    test("Sut should find created community", () async {
      final result = await sut.find(
        FindCommunityInput(id: createCommunityInput.id!),
      );

      expect(result.isRight(), isTrue);
      result.fold((l) => null, (r) {
        expect(r.id, equals(createCommunityInput.id));
        expect(r.ownerId, equals(createCommunityInput.ownerId));
        expect(r.title, equals(createCommunityInput.title));
        expect(r.description, equals(createCommunityInput.description));
        expect(r.members, isNotEmpty);
        expect(r.members.length, equals(1));
      });
    });
    test("Sut should add new members to the community", () async {
      final result = await sut.addMembers(
        AddMembersInput(
          idCommunity: createCommunityInput.id!,
          members: newMembers,
        ),
      );

      expect(result.isRight(), isTrue);
      expect(
        result.fold((l) => null, (r) => r),
        isA<AddMembersOutput>(),
      );
    });

    test("Sut should remove members", () async {
      final result = await sut.removeMembers(
        RemoveMembersInput(
          communityId: createCommunityInput.id!,
          memberIds: newMembers.map((e) => e.idMember).toList(),
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
  });
}
