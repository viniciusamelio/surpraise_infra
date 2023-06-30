import 'package:surpraise_infra/src/query/query.dart';

class GetUserQueryInput implements QueryInput {
  GetUserQueryInput({
    required this.id,
  });
  final String id;
}

class GetUserByTagQueryInput implements QueryInput {
  GetUserByTagQueryInput({
    required this.tag,
  });
  final String tag;
}
