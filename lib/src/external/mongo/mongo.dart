import 'package:mongo_dart/mongo_dart.dart';

class Mongo {
  Mongo(
    this._db,
  );
  final Db _db;

  Db get db => _db;

  SelectorBuilder get selector => where;
}
