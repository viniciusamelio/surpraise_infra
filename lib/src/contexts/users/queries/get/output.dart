import 'package:surpraise_infra/src/query/query.dart';

class GetUserQueryOutput implements QueryOutput<Map<String, dynamic>> {
  GetUserQueryOutput({
    required this.value,
  });

  @override
  final Map<String, dynamic> value;
}
