import 'package:surpraise_core/surpraise_core.dart';

abstract class CommunityMapper {
  static Map<String, dynamic> createMapFromInput(CreateCommunityInput input) =>
      {
        "id": input.id,
        "owner_id": input.ownerId,
        "description": input.description,
        "title": input.title,
        "plan_member_limit": input.planMemberLimit,
        "members": [
          {
            "member_id": input.ownerId,
          }
        ]
      };

  static CreateCommunityOutput createOutputFromMap(Map<String, dynamic> map) =>
      CreateCommunityOutput(
        id: map["id"],
        description: map["description"],
        title: map["title"],
        members: map["members"],
        ownerId: map["owner_id"],
      );
}
