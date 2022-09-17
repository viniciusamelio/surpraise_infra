import 'package:faker/faker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';
import 'package:surpraise_infra/src/datasources/mongo/mongo_datasource.dart';
import 'package:surpraise_infra/src/external/mongo/mongo.dart';
import 'package:test/test.dart';

void main() {
  late DatabaseDatasource sut;

  final String collectionName = "testing";

  final Map<String, dynamic> data = {
    "foo": "bar",
    "age": faker.randomGenerator.integer(80),
    "name": faker.person.firstName(),
    "id": faker.guid.guid(),
  };

  setUp(() async {
    final db = await Db.create("mongodb://127.0.0.1:27017/surpraise");
    await db.open();
    sut = MongoDatasource(
      Mongo(
        db,
      ),
    );
  });

  group("Mongo Datasource: ", () {
    test("Should insert data into $collectionName", () async {
      final result = await sut.save(
        SaveQuery(
          sourceName: collectionName,
          value: data,
        ),
      );

      expect(result.success, isTrue);
      expect(result.registersAffected, equals(1));
      expect(result.data!["id"], data["id"]);
    });

    test("Should get previous inserted data", () async {
      final result = await sut.get(
        GetQuery<String>(
          sourceName: collectionName,
          operator: FilterOperator.equalsTo,
          value: data["id"],
          fieldName: "id",
        ),
      );

      expect(result.success, isTrue);
      expect(result.data!.isNotEmpty, isTrue);
      expect(result.data!["id"], equals(data["id"]));
    });

    test("Should update already existing data", () async {
      final result = await sut.save(
        SaveQuery(
          sourceName: collectionName,
          value: {
            ...data,
            "updated_at": DateTime.now().toIso8601String(),
          },
          id: data["id"],
        ),
      );

      expect(result.success, isTrue);
      expect(result.data!.containsKey("updated_at"), isTrue);
    });

    test("Should get all data from $collectionName", () async {
      final newDocId = faker.guid.guid();
      await sut.save(
        SaveQuery(
          sourceName: collectionName,
          value: {
            "id": newDocId,
            "name": faker.person.firstName(),
          },
        ),
      );

      final result = await sut.getAll(collectionName);

      expect(result.success, isTrue);
      expect(result.multiData!.length, equals(2));

      await sut.delete(collectionName, newDocId);
    });

    test("Should remove data from $collectionName", () async {
      final result = await sut.delete(collectionName, data["id"]);

      expect(result.success, isTrue);
    });
  });
}
