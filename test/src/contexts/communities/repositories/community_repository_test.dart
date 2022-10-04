import 'package:faker/faker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/communities/repositories/community_repository.dart';
import 'package:surpraise_infra/src/datasources/mongo/mongo_datasource.dart';
import 'package:surpraise_infra/src/external/mongo/mongo.dart';
import 'package:test/test.dart';

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

    setUpAll(() async {
      db = await Db.create("mongodb://127.0.0.1:27017/surpraise");
      await db.open();
      sut = CommunityRepository(
        databaseDatasource: MongoDatasource(
          Mongo(
            db,
          ),
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
  });
}
