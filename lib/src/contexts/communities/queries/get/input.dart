import 'package:surpraise_infra/src/query/query.dart';

class GetCommunitiesByUserInput implements QueryInput {
  GetCommunitiesByUserInput({
    required this.id,
    this.limit = 20,
    this.offset = 0,
  });

  final String id;
  final int limit;
  final int offset;
}

class GetCommunityInput implements QueryInput {
  GetCommunityInput({
    required this.id,
  });

  final String id;
}
