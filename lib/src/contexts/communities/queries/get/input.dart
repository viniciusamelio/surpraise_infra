import 'package:surpraise_infra/src/query/query.dart';

class GetCommunitiesByUserInput implements QueryInput {
  GetCommunitiesByUserInput({
    required this.id,
    this.asOwner,
  });

  final String id;
  final bool? asOwner;
}
