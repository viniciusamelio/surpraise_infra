import 'package:faker/faker.dart';
import 'package:supabase/supabase.dart';
import 'package:surpraise_core/surpraise_core.dart';
import 'package:surpraise_infra/src/contexts/users/repositories/user_repository.dart';
import 'package:surpraise_infra/src/datasources/datasources.dart';
import 'package:test/test.dart';

import '../../../../test_settings.dart';

void main() {
  late final UserRepository sut;
  late final SupabaseClient client;

  group("User Repository: ", () {
    late final CreateUserInput input;

    setUpAll(() async {
      client = await supabaseClient();
      input = CreateUserInput(
        email: faker.internet.email(),
        name: faker.person.firstName(),
        tag: "@${faker.internet.userName()}",
        id: client.auth.currentSession!.user.id,
      );
      sut = UserRepository(
          databaseDatasource: SupabaseDatasource(
        supabase: client,
      ));
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
    });

    test("sut should return previous created user", () async {
      final result = await sut.getById(input.id!);

      expect(result, isNotNull);
      expect(result!.email, equals(input.email));
      expect(result.name, equals(input.name));
      expect(result.tag, equals(input.tag));
    });

    test("sut should return updated user data", () async {
      final newName = faker.person.firstName();
      final editInput = EditUserInput(
        tag: input.tag,
        name: newName,
        email: input.email,
        id: input.id!,
      );

      final result = await sut.edit(editInput);

      expect(result.isRight(), isTrue);
      result.fold((l) => null, (r) {
        expect(
          r.id,
          equals(input.id),
        );
        expect(
          r.name,
          equals(newName),
        );
      });
    });
  });
}
