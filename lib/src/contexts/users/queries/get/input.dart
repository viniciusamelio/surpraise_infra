import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';
import 'package:surpraise_infra/src/query/query.dart';

class GetUserQueryInput implements QueryInput {
  GetUserQueryInput({
    required this.id,
  });
  final String id;
}

class GetUserByTagQueryInput extends Equatable implements QueryInput {
  GetUserByTagQueryInput({
    required this.tag,
  });
  final String tag;

  @override
  List<Object?> get props => [tag];
}
