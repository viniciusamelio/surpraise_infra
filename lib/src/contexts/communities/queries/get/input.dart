// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:surpraise_infra/src/query/query.dart';

class GetCommunitiesByUserInput implements QueryInput {
  GetCommunitiesByUserInput({
    required this.id,
    this.asOwner,
  });

  final String id;
  final bool? asOwner;
}

class GetCommunityInput implements QueryInput {
  GetCommunityInput({
    required this.id,
  });

  final String id;
}
