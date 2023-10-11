class GetUserDto {
  const GetUserDto({
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
