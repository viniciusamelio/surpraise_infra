import 'package:faker/faker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/surpraise_infra.dart';
import 'package:test/test.dart';

import '../../../../test_settings.dart';

void main() {
  late PraiseRepository sut;
  late DatabaseDatasource datasource;
  late String id;
  late PraiseInput input;

  setUpAll(() async {
    id = faker.guid.guid();

    final db = Db(
      TestSettings.dbConnection,
    );
    await db.open();
    final mongo = Mongo(
      db,
    );
    datasource = MongoDatasource(
      mongo,
      TestSettings.dbConnection,
    );

    final praisedId = faker.guid.guid();

    final CreateUserRepository userRepository = UserRepository(
      databaseDatasource: MongoDatasource(
        mongo,
        TestSettings.dbConnection,
      ),
    );

    await userRepository.create(
      CreateUserInput(
        tag: "@testingUser${faker.randomGenerator.integer(20)}",
        name: faker.lorem.word(),
        email: faker.internet.email(),
        id: praisedId,
      ),
    );

    input = PraiseInput(
      commmunityId: faker.guid.guid(),
      message: faker.lorem.words(6).toString(),
      praisedId: praisedId,
      praiserId: faker.guid.guid(),
      topic: "#test",
    );
    input.id = id;
    sut = PraiseRepository(datasource: datasource);
  });

  tearDownAll(() async {
    datasource.delete(
      GetQuery(
        sourceName: "praises",
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
