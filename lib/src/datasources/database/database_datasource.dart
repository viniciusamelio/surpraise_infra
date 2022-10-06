import 'package:surpraise_infra/src/datasources/database/result.dart';

import 'query.dart';

abstract class DatabaseDatasource {
  /// Retrieves a saved element from the database through [GetQuery] options
  Future<QueryResult> get(GetQuery query);

  /// Saves or updates an element to the database through [SaveQuery] options
  Future<QueryResult> save(SaveQuery query);

  /// Add a single element or a list elements to an array field in a previous existing register.
  Future<QueryResult> push(PushQuery query);

  /// Removes an element from the database
  Future<QueryResult> delete(String sourceName, String id);

  /// Retrieves all elements through the datasource name (collection, table, etc)
  Future<QueryResult> getAll(String sourceName);
}
