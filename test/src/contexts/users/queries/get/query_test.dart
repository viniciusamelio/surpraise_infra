import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/users/queries/get/query.dart';
import 'package:surpraise_infra/src/contexts/users/repositories/user_repository.dart';
import 'package:surpraise_infra/src/datasources/mongo/mongo_datasource.dart';
import 'package:surpraise_infra/src/external/mongo/mongo.dart';
import 'package:surpraise_infra/src/query/query.dart';
import 'package:test/test.dart';

import '../../../../../test_settings.dart';

class MockIdService extends Mock implements IdService {}

void main() {
  group("Get User Query: ", () {
    late GetUserQuery sut;
    late Db db;
    late CreateUserUsecase createUserUsecase;
    late MockIdService mockIdService;

    final String inputId = faker.guid.guid();

    setUp(() async {
      db = await Db.create(TestSettings.dbConnection);
      mockIdService = MockIdService();
      await db.open();
      final datasource = MongoDatasource(
        Mongo(
          db,
        ),
        TestSettings.dbConnection,
      );
      createUserUsecase = DbCreateUserUsecase(
        createUserRepository: UserRepository(
          databaseDatasource: datasource,
        ),
        idService: mockIdService,
        eventBus: StreamEventBus(),
      );
      sut = GetUserQuery(
        databaseDatasource: datasource,
      );

      when(
        () => mockIdService.generate(),
      ).thenAnswer(
        (_) async => inputId,
      );
      await createUserUsecase(
        CreateUserInput(
          tag: "@mock",
          name: faker.person.name(),
          email: faker.internet.email(),
        ),
      );
    });

    tearDown(() async {
      await db.collection("users").drop();
    });

    test("Sut should return found user", () async {
      final result = await sut(
        GetUserQueryInput(
          id: inputId,
        ),
      );

      expect(result.isRight(), isTrue);
      expect(
        result.fold(
          (l) => null,
          (r) => r.value["id"],
        ),
        equals(inputId),
      );
    });

    test("Sut should return not found error", () async {
      final result = await sut(
        GetUserQueryInput(
          id: "randomIdPass${faker.guid.guid()}",
        ),
      );

      expect(result.isLeft(), isTrue);
      expect(result.fold((l) => l, (r) => null), isA<QueryError>());
      expect(result.fold((l) => l.code, (r) => null), equals(404));
    });
  });
}
