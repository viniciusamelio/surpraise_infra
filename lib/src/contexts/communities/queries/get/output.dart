import 'package:surpraise_infra/src/query/query.dart';

typedef JsonList = List<Map<String, dynamic>>;

class GetCommunitiesByUserOutput implements QueryOutput<JsonList> {
  GetCommunitiesByUserOutput({
    required this.value,
  });

  @override
  final JsonList value;
}
