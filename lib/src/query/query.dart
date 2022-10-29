import 'package:surpraise_infra/src/query/query_output.dart';

export "query_input.dart";
export "query_output.dart";

abstract class Query<T extends QueryOutput> {
  Future<T> call();
}
