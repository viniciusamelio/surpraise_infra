import 'query.dart';

abstract class DatabaseDatasource {
  get(GetQuery query);
  save(SaveQuery query);
  delete(String id);
}
