import 'package:surpraise_backend_dependencies/surpraise_backend_dependencies.dart';
import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/filter.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';
import 'package:surpraise_infra/src/datasources/database/result.dart';
import 'package:surpraise_infra/src/datasources/mongo/filter_mapper.dart';
import 'package:surpraise_infra/src/external/mongo/mongo.dart';

class MongoDatasource implements DatabaseDatasource {
  MongoDatasource(
    this._mongo,
    this.uriString,
  );

  final Mongo _mongo;
  final String uriString;

  @override
  delete(GetQuery query) async {
    await Db(uriString).open();
    final result = await _mongo.db.collection(query.sourceName).deleteOne(
      {
        query.fieldName: query.value,
      },
    );

    await Db(uriString).close();
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
      await Db(uriString).open();
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
        data: query.singleResult ? result.first : null,
        multiData: !query.singleResult ? result : null,
      );
    } catch (e) {
      return QueryResult(
        success: false,
        failure: true,
        errorMessage: e.toString(),
        registersAffected: 0,
      );
    } finally {
      await Db(uriString).close();
    }
  }

  @override
  save(SaveQuery query) async {
    try {
      await Db(uriString).open();

      if (query.id != null) {
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
    } finally {
      await Db(uriString).close();
    }
  }

  @override
  getAll(String sourceName) async {
    try {
      await Db(uriString).open();

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
    } finally {
      await Db(uriString).close();
    }
  }

  @override
  Future<QueryResult> push(PushQuery query) async {
    try {
      await Db(uriString).open();

      await _mongo.db.collection(query.sourceName).updateOne(
            MongoFilterMapper.buildFrom(
              GetQuery(
                sourceName: query.sourceName,
                operator: FilterOperator.equalsTo,
                value: query.id,
                fieldName: "id",
              ),
            ),
            MongoFilterMapper.push(query),
          );
      final result = await get(
        GetQuery(
          sourceName: query.sourceName,
          operator: FilterOperator.equalsTo,
          value: query.id,
          fieldName: "id",
        ),
      );
      return QueryResult(
        success: true,
        failure: false,
        data: result.data,
        registersAffected: query.value is List ? query.value.length : 1,
      );
    } catch (e) {
      return QueryResult(
        success: false,
        errorMessage: e.toString(),
        failure: true,
      );
    } finally {
      await Db(uriString).close();
    }
  }

  @override
  Future<QueryResult> pop(PopQuery query) async {
    try {
      await Db(uriString).open();

      await _mongo.db.collection(query.sourceName).updateOne(
            MongoFilterMapper.buildFrom(
              GetQuery(
                sourceName: query.sourceName,
                operator: FilterOperator.equalsTo,
                value: query.id,
                fieldName: "id",
              ),
            ),
            MongoFilterMapper.pull(query),
          );
      final result = await get(
        GetQuery(
          sourceName: query.sourceName,
          operator: FilterOperator.equalsTo,
          value: query.id,
          fieldName: "id",
        ),
      );
      return QueryResult(
        success: true,
        failure: false,
        data: result.data,
        registersAffected: query.value is List ? query.value.length : 1,
      );
    } catch (e) {
      return QueryResult(
        success: false,
        errorMessage: e.toString(),
        failure: true,
      );
    } finally {
      await Db(uriString).close();
    }
  }
}
