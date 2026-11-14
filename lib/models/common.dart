import 'dart:convert';

//region Conversion

/// Dart-объект → JSON-строка
String toJsonString(Object? value) => jsonEncode(value);

/// JSON-строка → типизированный объект
/// [parse] — функция, которая знает, как из Map сделать T
T fromJsonString<T>(String source, T Function(Map<String, dynamic>) parse) =>
    parse(jsonDecode(source) as Map<String, dynamic>);

/// JSON-строка → список типизированных объектов
List<T> fromJsonList<T>(
  String source,
  T Function(Map<String, dynamic>) parse,
) => (jsonDecode(source) as List)
    .map((e) => parse(e as Map<String, dynamic>))
    .toList();

int asInt(Object? v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

bool asBool(Object? v, [bool fallback = false]) {
  if (v == null) return fallback;
  if (v is bool) return v;
  if (v is String) return v.toLowerCase() == 'true';
  if (v is int) return v != 0;
  return fallback;
}

//endregion

//region FuncResponse

class FuncResponse {
  const FuncResponse({required this.level, required this.response});

  final String level;
  final String response;

  factory FuncResponse.fromMap(Map<String, dynamic> map) => FuncResponse(
    level: (map['Level'] as String?) ?? '',
    response: (map['Response'] as String?) ?? '',
  );
}

//endregion

//region Status

enum Status {
  off(0),
  running(1),
  on(2),
  stop(3);

  const Status(this.value);
  final int value;

  static Status fromValue(int v) =>
      Status.values.firstWhere((e) => e.value == v, orElse: () => Status.off);

  static Status fromAny(Object? v) {
    if (v is int) return fromValue(v);
    if (v is String) {
      final s = v.toLowerCase();
      for (final e in Status.values) {
        if (e.name == s) return e;
      }
      return fromValue(int.tryParse(v) ?? 0);
    }
    return Status.off;
  }
}

//endregion

//region DataTime

class DataTime {
  const DataTime({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.second,
    required this.miliseconds,
  });

  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final int second;
  final int miliseconds;

  Map<String, dynamic> toMap() => {
    'Year': year,
    'Month': month,
    'Day': day,
    'Hour': hour,
    'Minute': minute,
    'Second': second,
    'Miliseconds': miliseconds,
  };

  factory DataTime.fromMap(Map<String, dynamic> map) => DataTime(
    year: asInt(map['Year']),
    month: asInt(map['Month']),
    day: asInt(map['Day']),
    hour: asInt(map['Hour']),
    minute: asInt(map['Minute']),
    second: asInt(map['Second']),
    miliseconds: asInt(map['Miliseconds']),
  );
}

//endregion
