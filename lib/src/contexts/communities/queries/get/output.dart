import 'package:surpraise_infra/src/contexts/communities/dtos/dtos.dart';
import 'package:surpraise_infra/src/query/query.dart';

typedef JsonList = List<Map<String, dynamic>>;

class GetCommunitiesByUserOutput implements QueryOutput<List<CommunityOutput>> {
  GetCommunitiesByUserOutput({
    required this.value,
  });

  @override
  final List<CommunityOutput> value;
}

class GetCommunityOutput implements QueryOutput<CommunityOutput> {
  @override
  final CommunityOutput value;
  GetCommunityOutput({
    required this.value,
  });
}
