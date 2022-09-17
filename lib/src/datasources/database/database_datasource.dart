import 'package:surpraise_infra/src/datasources/database/result.dart';

import 'query.dart';

abstract class DatabaseDatasource {
  Future<QueryResult> get(GetQuery query);
  Future<QueryResult> save(SaveQuery query);
  Future<QueryResult> delete(String sourceName, String id);
  Future<QueryResult> getAll(String sourceName);
}
