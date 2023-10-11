import 'package:surpraise_infra/src/contexts/praises/dtos/dtos.dart';
import 'package:surpraise_infra/src/query/query_output.dart';

class GetPraisesByUserOutput implements QueryOutput<List<PraiseDto>> {
  GetPraisesByUserOutput({
    required this.value,
  });

  @override
  final List<PraiseDto> value;
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
