import 'package:faker/faker.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';
import 'package:surpraise_infra/src/datasources/mongo/mongo_datasource.dart';
import 'package:surpraise_infra/src/external/mongo/mongo.dart';
import 'package:test/test.dart';

import '../../../test_settings.dart';

void main() {
  late DatabaseDatasource sut;

  final String collectionName = "testing";

  final Map<String, dynamic> data = {
    "foo": "bar",
    "age": faker.randomGenerator.integer(80),
    "name": faker.person.firstName(),
    "id": faker.guid.guid(),
    "array": [
      {"bar": "foo"},
    ]
  };

  setUp(() async {
    final db = await Db.create(TestSettings.dbConnection);
    await db.open();
    sut = MongoDatasource(
      Mongo(
        db,
      ),
      TestSettings.dbConnection,
    );
  });

  tearDownAll(() async {
    await sut.delete(
      GetQuery(
        sourceName: collectionName,
        value: data["id"],
        fieldName: "id",
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

      await sut.delete(
        GetQuery(
          sourceName: collectionName,
          value: newDocId,
          fieldName: "id",
        ),
      );
    });

    test("Should push and merge list data to $collectionName array field",
        () async {
      final result = await sut.push(
        PushQuery(
          sourceName: collectionName,
          value: [
            {
              "name": "Ana",
            },
            {
              "name": "Larissa",
            },
          ],
          id: data["id"],
          field: "array",
        ),
      );

      expect(result.success, isTrue);
      expect(result.data!["array"].length, equals(3));
      expect(
        (result.data!["array"] as List)
            .where((element) => element["name"] == "Ana")
            .isNotEmpty,
        isTrue,
      );
      expect(
        (result.data!["array"] as List)
            .where((element) => element["name"] == "Larissa")
            .isNotEmpty,
        isTrue,
      );
      expect(
        (result.data!["array"] as List)
            .where((element) => element["bar"] == "foo")
            .isNotEmpty,
        isTrue,
      );
    });

    test("Should push single element data to $collectionName array field",
        () async {
      final result = await sut.push(
        PushQuery(
          sourceName: collectionName,
          value: {
            "name": "Camila",
          },
          id: data["id"],
          field: "array",
        ),
      );

      expect(result.success, isTrue);
      expect(result.data!["array"].length, equals(4));
      expect(
        (result.data!["array"] as List)
            .where((element) => element["name"] == "Camila")
            .isNotEmpty,
        isTrue,
      );
    });

    test("Should pop value from array", () async {
      final result = await sut.pop(
        PopQuery(
          sourceName: collectionName,
          value: {
            "name": "Camila",
          },
          id: data["id"],
          field: "array",
        ),
      );

      expect(result.success, isTrue);
      expect(result.data!["array"].length, equals(3));
      expect(
        (result.data!["array"] as List)
            .where((element) => element["name"] == "Camila")
            .isNotEmpty,
        isFalse,
      );
    });

    test("Should pop list of values from array", () async {
      final result = await sut.pop(
        PopQuery(
          sourceName: collectionName,
          value: [
            {
              "name": "Larissa",
            }
          ],
          id: data["id"],
          field: "array",
        ),
      );

      expect(result.success, isTrue);
      expect(result.data!["array"].length, equals(2));
      expect(
        (result.data!["array"] as List)
            .where((element) => element["name"] == "Larissa")
            .isNotEmpty,
        isFalse,
      );
    });

    test("Should remove data from $collectionName", () async {
      final result = await sut.delete(
        GetQuery(
          sourceName: collectionName,
          value: data["id"],
          fieldName: "id",
        ),
      );

      expect(result.success, isTrue);
    });
  });
}
