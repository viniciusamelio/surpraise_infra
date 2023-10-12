// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:surpraise_infra/src/query/query.dart';

class GetCommunitiesByUserInput implements QueryInput {
  const GetCommunitiesByUserInput({
    required this.id,
    this.limit = 20,
    this.offset = 0,
  });

  final String id;
  final int limit;
  final int offset;
}

class GetCommunityInput implements QueryInput {
  const GetCommunityInput({
    required this.id,
  });

  final String id;
}

class GetMembersInput extends QueryInput {
  final String communityId;
  const GetMembersInput({
    required this.communityId,
  });
}
