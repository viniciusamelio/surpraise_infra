import 'package:surpraise_infra/src/contexts/users/dtos/dtos.dart';
import 'package:surpraise_infra/src/query/query.dart';

class GetUserQueryOutput implements QueryOutput<GetUserDto> {
  GetUserQueryOutput({
    required this.value,
  });

  @override
  final GetUserDto value;
}
