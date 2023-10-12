import '../../../enums/enums.dart';

class CommunityOutput {
  const CommunityOutput({
    required this.id,
    required this.ownerId,
    required this.description,
    required this.title,
    required this.image,
    required this.role,
  });

  final String id;
  final String ownerId;
  final String description;
  final String title;
  final String image;
  final Role role;
}

CommunityOutput communityOutputFromMap(Map<String, dynamic> json) =>
    CommunityOutput(
      id: json["id"],
      ownerId: json["owner_id"],
      description: json["description"],
      title: json["title"],
      image: json["imageUrl"],
      role: Role.fromString(json["role"]),
    );