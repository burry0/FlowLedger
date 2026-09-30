typedef DatabaseRow = Map<String, Object?>;

String isoDate(DateTime value) => value.toUtc().toIso8601String();

DateTime dateFromDatabase(Object? value) =>
    DateTime.parse(value! as String).toLocal();

DateTime? nullableDateFromDatabase(Object? value) {
  return value == null ? null : dateFromDatabase(value);
}

bool boolFromDatabase(Object? value) => value == 1;
