import 'package:surpraise_core/surpraise_core.dart';

import 'package:uuid/uuid.dart';

class UuidService implements IdService {
  @override
  Future<String> generate() async {
    final uuid = Uuid();
    return uuid.v4();
  }
}
