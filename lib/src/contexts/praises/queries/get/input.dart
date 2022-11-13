// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:surpraise_infra/src/query/query.dart';

class GetPraisesByUserInput implements QueryInput {
  GetPraisesByUserInput({
    required this.id,
    required this.asPraiser,
  });

  final String id;
  final bool? asPraiser;
}

class GetPraisesByCommunityInput implements QueryInput {
  GetPraisesByCommunityInput({
    required this.id,
  });

  final String id;
}

class GetPraiseInput implements QueryInput {
  GetPraiseInput({
    required this.id,
  });

  final String id;
}
