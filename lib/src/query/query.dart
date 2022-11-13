import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';
import 'package:surpraise_infra/src/query/query_error.dart';
import 'package:surpraise_infra/src/query/query_input.dart';
import 'package:surpraise_infra/src/query/query_output.dart';

export "query_input.dart";
export "query_output.dart";
export "query_error.dart";

abstract class DataQuery<T extends QueryInput> {
  Future<Either<QueryError, QueryOutput>> call(T input);
}
