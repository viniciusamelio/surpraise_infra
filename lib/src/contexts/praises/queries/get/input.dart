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
    this.limit = 20,
    this.offset = 0,
  });

  final String id;
  final int limit;
  final int offset;
}

class GetPraiseInput implements QueryInput {
  GetPraiseInput({
    required this.id,
  });

  final String id;
}
