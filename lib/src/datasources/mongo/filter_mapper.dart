import 'package:mongo_dart/mongo_dart.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';

abstract class MongoFilterMapper {
  static SelectorBuilder buildFrom(GetQuery query) {
    final fieldName = query.fieldName;
    final value = query.value;

    switch (query.operator) {
      case FilterOperator.equalsTo:
        return where.eq(fieldName, value);
      case FilterOperator.notEqualsTo:
        return where.ne(fieldName, value);
      case FilterOperator.greaterThan:
        return where.gt(fieldName, value);
      case FilterOperator.equalsOrGreaterThan:
        return where.gte(fieldName, value);
      case FilterOperator.equalsOrLesserThan:
        return where.lte(fieldName, value);
      case FilterOperator.lesserThan:
        return where.lt(fieldName, value);
      default:
        return where.eq(fieldName, value);
    }
  }
}
