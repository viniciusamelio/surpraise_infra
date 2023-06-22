import 'package:faker/faker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/praises/repositories/praise_repository.dart';
import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/mongo/mongo_datasource.dart';
import 'package:surpraise_infra/src/external/mongo/mongo.dart';
import 'package:test/test.dart';

import '../../../../test_settings.dart';

void main() {
  late PraiseRepository sut;
  late DatabaseDatasource datasource;
  late String id;
  late PraiseInput input;

  setUpAll(() async {
    id = faker.guid.guid();
    input = PraiseInput(
      commmunityId: faker.guid.guid(),
      message: faker.lorem.words(6).toString(),
      praisedId: faker.guid.guid(),
      praiserId: faker.guid.guid(),
      topic: "#test",
    );
    input.id = id;
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
    sut = PraiseRepository(datasource: datasource);
  });

  tearDownAll(() async {
    datasource.delete(
      sut.sourceName,
      id,
    );
  });

  group("Praise Repository: ", () {
    test('Should create a praise', () async {
      final result = await sut.create(input);

      expect(result.isRight(), isTrue);
    });
  });
}
