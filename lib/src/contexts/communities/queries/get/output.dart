// ignore_for_file: public_member_api_docs, sort_constructors_first
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

class GetMembersOutput implements QueryOutput<List<FindCommunityMemberOutput>> {
  @override
  final List<FindCommunityMemberOutput> value;
  const GetMembersOutput({
    required this.value,
  });
}
