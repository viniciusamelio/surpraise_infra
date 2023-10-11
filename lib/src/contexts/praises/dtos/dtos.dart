class PraiseDto {
  const PraiseDto({
    required this.id,
    required this.communityId,
    required this.message,
    required this.praiser,
    required this.topic,
    required this.communityTitle,
  });
  final String id;
  final String communityId;
  final String communityTitle;
  final String message;
  final UserDto praiser;
  final String topic;
}

class UserDto {
  const UserDto({
    required this.id,
    required this.tag,
    required this.name,
    required this.email,
  });
  final String id;
  final String tag;
  final String name;
  final String email;
}
