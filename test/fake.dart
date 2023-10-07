import 'package:surpraise_infra/src/datasources/database/database_datasource.dart';
import 'package:surpraise_infra/src/datasources/database/query.dart';
import 'package:surpraise_infra/src/datasources/database/result.dart';

class FakeDatasource implements DatabaseDatasource {
  final Map<String, List<Map<String, dynamic>>> _data = {};

  @override
  Future<QueryResult> delete(GetQuery query) async {
    final data = await get(query);
    if (data.multiData != null) {
      for (var item in data.multiData!) {
        _data[query.sourceName]!.removeWhere(
          (element) => element["id"] == item["id"],
        );
      }
    } else if (data.data != null) {
      _data[query.sourceName]!.removeWhere(
        (element) => element["id"] == data.data!["id"],
      );
    }

    return QueryResult(
      success: true,
      failure: false,
    );
  }

  @override
  Future<QueryResult> get(GetQuery query) async {
    final source = _data[query.sourceName];
    if (source == null) {
      return QueryResult(success: false, failure: true);
    }
    Iterable initialQuery =
        source.where((element) => element[query.fieldName] == query.value);
    final result = _applyFilters(query, initialQuery);
    return QueryResult(
      success: true,
      failure: false,
      registersAffected: result.length,
      multiData: result.toList().cast<Map<String, dynamic>>(),
      data: result.length > 1 ? null : result.first,
    );
  }

  Iterable _applyFilters(
    GetQuery<dynamic> query,
    Iterable<dynamic> initialQuery,
  ) {
    if (query.filters != null) {
      for (final filter in query.filters!) {
        initialQuery = initialQuery.where(
          (element) => element[filter.fieldName] == filter.value,
        );
      }
    }

    return initialQuery;
  }

  @override
  Future<QueryResult> getAll(String sourceName) async {
    return QueryResult(
      success: true,
      failure: false,
      multiData: _data[sourceName],
    );
  }

  @override
  Future<QueryResult> pop(PopQuery query) {
    throw UnimplementedError();
  }

  @override
  Future<QueryResult> push(PushQuery query) {
    throw UnimplementedError();
  }

  @override
  Future<QueryResult> save(SaveQuery query) async {
    _data[query.sourceName] ??= [];
    if (query.id != null) {
      _data[query.sourceName]!.removeWhere(
        (element) => element["id"] == query.id,
      );
    }
    _data[query.sourceName]!.add({
      ...query.value,
    });
    return QueryResult(
      success: true,
      failure: false,
      data: query.value,
      multiData: [query.value],
    );
  }

  @override
  Stream<QueryResult> watch(GetQuery query) {
    throw UnimplementedError();
  }
}
