import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/filter.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';
import 'package:surpraise_infra/src/datasources/database/result.dart';
import 'package:surpraise_infra/src/datasources/mongo/filter_mapper.dart';
import 'package:surpraise_infra/src/external/mongo/mongo.dart';

class MongoDatasource implements DatabaseDatasource {
  MongoDatasource(this._mongo);

  final Mongo _mongo;

  @override
  delete(String sourceName, String id) async {
    final result = await _mongo.db.collection(sourceName).deleteOne(
      {
        "id": id,
      },
    );

    return QueryResult(
      success: result.isSuccess,
      failure: result.isFailure,
      data: result.document,
      errorMessage: result.errmsg,
      registersAffected: result.nRemoved,
    );
  }

  @override
  get(GetQuery query) async {
    try {
      var mongoQuery = MongoFilterMapper.buildFrom(query);
      query.filters?.forEach((filter) {
        if (filter is AndFilter) {
          mongoQuery = mongoQuery.and(
            MongoFilterMapper.buildFrom(
              GetQuery(
                sourceName: query.sourceName,
                operator: filter.operator,
                value: filter.value,
                fieldName: filter.fieldName,
              ),
            ),
          );
        } else if (filter is OrFilter) {
          mongoQuery = mongoQuery.or(
            MongoFilterMapper.buildFrom(
              GetQuery(
                sourceName: query.sourceName,
                operator: filter.operator,
                value: filter.value,
                fieldName: filter.fieldName,
              ),
            ),
          );
        }
      });

      final result = await _mongo.db
          .collection(query.sourceName)
          .find(mongoQuery)
          .toList();

      return QueryResult(
        success: true,
        failure: false,
        data: result.first,
      );
    } catch (e) {
      return QueryResult(
        success: false,
        failure: true,
        errorMessage: e.toString(),
        registersAffected: 0,
      );
    }
  }

  @override
  save(SaveQuery query) async {
    try {
      if (query.id != null) {
        final updateResult =
            await _mongo.db.collection(query.sourceName).update(
                  MongoFilterMapper.buildFrom(
                    GetQuery(
                      sourceName: query.sourceName,
                      operator: FilterOperator.equalsTo,
                      value: query.id,
                      fieldName: "id",
                    ),
                  ),
                  query.value,
                );
        return QueryResult(
          success: true,
          failure: false,
          data: query.value,
          registersAffected: 1,
        );
      }

      await _mongo.db.collection(query.sourceName).insert(query.value);
      return QueryResult(
        success: true,
        failure: false,
        data: query.value,
        registersAffected: 1,
      );
    } catch (e) {
      return QueryResult(
        success: false,
        failure: true,
        errorMessage: e.toString(),
        data: query.value,
        registersAffected: 0,
      );
    }
  }

  @override
  getAll(String sourceName) async {
    try {
      final result = await _mongo.db.collection(sourceName).find().toList();
      return QueryResult(
        success: true,
        failure: false,
        multiData: result,
      );
    } catch (e) {
      return QueryResult(
        success: false,
        failure: true,
      );
    }
  }
}
