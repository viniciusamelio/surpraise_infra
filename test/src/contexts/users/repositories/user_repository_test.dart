import 'package:faker/faker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/users/repositories/user_repository.dart';
import 'package:surpraise_infra/src/datasources/mongo/mongo_datasource.dart';
import 'package:surpraise_infra/src/external/mongo/mongo.dart';
import 'package:test/test.dart';

void main() {
  late final UserRepository sut;

  late final Db db;

  group("User Repository: ", () {
    final input = CreateUserInput(
      email: faker.internet.email(),
      name: faker.person.firstName(),
      tag: "@test_user",
      id: faker.guid.guid(),
    );

    setUp(() async {
      db = await Db.create("mongodb://127.0.0.1:27017/surpraise");
      await db.open();
      sut = UserRepository(
        databaseDatasource: MongoDatasource(
          Mongo(db),
        ),
      );
    });

    test("sut should return saved user data", () async {
      final result = await sut.create(input);

      expect(result.isRight(), isTrue);
      result.fold((l) => l, (r) {
        expect(r.email, equals(input.email));
        expect(r.name, equals(input.name));
        expect(r.tag, equals(input.tag));
        expect(r.id, isNotNull);
        expect(r.id, equals(input.id));
      });

      await db.collection(sut.sourceName).drop();
    });
  });
}
