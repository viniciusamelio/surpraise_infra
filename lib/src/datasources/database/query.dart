abstract class Query {
  Query({
    required this.sourceName,
  });

  final String sourceName;
}

class GetQuery<T> implements Query {
  GetQuery({
    required this.sourceName,
    required this.operator,
    required this.value,
  });

  @override
  final String sourceName;

  final String operator;
  final T value;
}

class SaveQuery implements Query {
  SaveQuery({
    required this.sourceName,
    required this.value,
    this.id,
  });

  @override
  final String sourceName;
  final Map<String, dynamic> value;
  final String? id;
}
