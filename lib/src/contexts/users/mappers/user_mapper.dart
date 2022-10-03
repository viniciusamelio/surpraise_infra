import 'package:surpraise_core/surpraise_core.dart';

abstract class UserMapper {
  static Map<String, dynamic> createUserInputToMap(CreateUserInput input) => {
        "tag": input.tag,
        "name": input.name,
        "email": input.email,
        "id": input.id
      };

  static CreateUserOutput createUserOutputFromMap(Map<String, dynamic> map) =>
      CreateUserOutput(
        tag: map['tag'],
        name: map['name'],
        email: map['email'],
        id: map['id'],
      );

  static Map<String, dynamic> editUserInputToMap(EditUserInput input) => {
        "id": input.id,
        "name": input.name,
        "email": input.email,
        "tag": input.tag,
      };

  static EditUserOutput editUserOutputFromMap(Map<String, dynamic> map) =>
      EditUserOutput(
        tag: map["tag"],
        name: map["name"],
        email: map["email"],
        id: map["id"],
      );
}
