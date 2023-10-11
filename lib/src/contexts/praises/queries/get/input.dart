import 'package:surpraise_infra/src/query/query.dart';

class GetPraisesByUserInput implements QueryInput {
  GetPraisesByUserInput({
    required this.id,
    this.limit = 20,
    this.offset = 0,
  });

  final String id;
  final int limit;
  final int offset;
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
    this.limit = 10,
    this.offset = 0,
  });

  final String id;
  final int limit;
  final int offset;
}
