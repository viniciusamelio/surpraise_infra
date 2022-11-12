import 'package:surpraise_infra/src/query/query_output.dart';

class GetPraisesByUserOutput implements QueryOutput {
  GetPraisesByUserOutput({
    required this.value,
  });

  @override
  final List<Map<String, dynamic>> value;
}
