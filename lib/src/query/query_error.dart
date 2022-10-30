class QueryError implements Exception {
  QueryError(this.message, [this.code]);
  final String message;
  final int? code;
}
