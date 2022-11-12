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
