import 'package:surpraise_infra/src/query/query.dart';

typedef JsonList = List<Map<String, dynamic>>;

class GetCommunitiesByUserOutput implements QueryOutput<JsonList> {
  GetCommunitiesByUserOutput({
    required this.value,
  });

  @override
  final JsonList value;
}

class GetCommunityOutput implements QueryOutput<Map<String, dynamic>> {
  @override
  final Map<String, dynamic> value;
  GetCommunityOutput({
    required this.value,
  });
}
