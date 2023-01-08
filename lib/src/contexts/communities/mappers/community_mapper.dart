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
            "community_id": input.id,
            "role": "owner",
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

  static FindCommunityMemberDto memberFromMap(Map<String, dynamic> map) =>
      FindCommunityMemberDto(
        id: map["member_id"],
        communityId: map["community_id"],
        role: map["role"],
      );

  static FindCommunityOutput findOutputFromMap(Map<String, dynamic> map) =>
      FindCommunityOutput(
        id: map["id"],
        ownerId: map["owner_id"],
        description: map["description"],
        title: map["title"],
        members: (map["members"] as List).map((e) {
          if (!e.containsKey("community_id")) {
            e["community_id"] = map["id"];
          }

          return CommunityMapper.memberFromMap(e);
        }).toList(),
      );

  static Map<String, dynamic> addMemberFromInput(MemberToAdd input) => {
        "member_id": input.idMember,
        "role": input.role,
      };
}
