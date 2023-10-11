import 'package:surpraise_infra/src/contexts/praises/dtos/dtos.dart';
import 'package:surpraise_infra/src/query/query_output.dart';

class GetPraisesByUserOutput implements QueryOutput {
  GetPraisesByUserOutput({
    required this.value,
  });

  @override
  final List<Map<String, dynamic>> value;
}

class GetPraisesByCommunityOutput implements QueryOutput {
  GetPraisesByCommunityOutput({
    required this.value,
  });

  @override
  final List<Map<String, dynamic>> value;
}

class GetPraiseOutput implements QueryOutput<PraiseDto> {
  GetPraiseOutput({
    required this.value,
  });

  @override
  final PraiseDto value;
}
