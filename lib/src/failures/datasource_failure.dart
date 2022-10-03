class DatasourceFailure implements Exception {
  DatasourceFailure(this.message);

  final String message;
}
