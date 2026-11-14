import 'dart:convert';
import 'dart:typed_data';

import 'package:k_net_service/k_net_service.dart';

//region Record

class KJRecord {
  const KJRecord({
    required this.author,
    required this.level,
    required this.code,
    required this.time,
    required this.message,
  });

  final String author;
  final String level;
  final String code;
  final DataTime time;
  final String message;

  factory KJRecord.fromMap(Map<String, dynamic> map) => KJRecord(
    author: (map['Author'] as String?) ?? '',
    level: (map['Level'] as String?) ?? '',
    code: (map['Code'] as String?) ?? '',
    time: DataTime.fromMap(
      (map['Time'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    message: (map['Message'] as String?) ?? '',
  );

  Map<String, dynamic> toMap() => {
    'Author': author,
    'Level': level,
    'Code': code,
    'Time': time.toMap(),
    'Message': message,
  };
}

//endregion

//region Package

enum PackageType {
  message(0),
  json(1),
  command(2),
  file(3);

  const PackageType(this.value);
  final int value;

  static PackageType fromInt(int v) =>
      PackageType.values.firstWhere((e) => e.value == v, orElse: () => message);

  static PackageType fromAny(Object? any) {
    if (any is int) return fromInt(any);
    if (any is String) {
      final byName = PackageType.values
          .where((e) => e.name.toUpperCase() == any.toUpperCase())
          .firstOrNull;
      if (byName != null) return byName;
      final asInt = int.tryParse(any);
      if (asInt != null) return fromInt(asInt);
    }
    return message;
  }
}

enum DataType {
  bytes(0),
  string(1);

  const DataType(this.value);
  final int value;

  static DataType fromInt(int v) =>
      DataType.values.firstWhere((e) => e.value == v, orElse: () => bytes);

  static DataType fromAny(Object? any) {
    if (any is int) return fromInt(any);
    if (any is String) {
      final byName = DataType.values
          .where((e) => e.name.toUpperCase() == any.toUpperCase())
          .firstOrNull;
      if (byName != null) return byName;
      final asInt = int.tryParse(any);
      if (asInt != null) return fromInt(asInt);
    }
    return bytes;
  }
}

class Package {
  const Package({
    required this.from,
    required this.to,
    required this.type,
    required this.dataType,
    required this.metadata,
    this.text,
    this.blob,
  });

  final String from;
  final String to;
  final PackageType type;
  final DataType dataType;
  final String metadata;

  /// oneof payload { string text = 6; bytes blob = 7; }
  /// Ровно одно из полей должно быть не null (или оба null, если payload пуст).
  final String? text;
  final Uint8List? blob;

  bool get hasText => text != null;
  bool get hasBlob => blob != null;

  factory Package.fromMap(Map<String, dynamic> map) {
    final rawType = PackageType.fromAny(map['type'] ?? map['Type']);
    final rawDataType = DataType.fromAny(map['data_type'] ?? map['DataType']);

    final rawText = map['text'] ?? map['Text'];
    final rawBlob = map['blob'] ?? map['Blob'];

    Uint8List? blob;
    if (rawBlob is Uint8List) {
      blob = rawBlob;
    } else if (rawBlob is List) {
      blob = Uint8List.fromList(rawBlob.cast<int>());
    } else if (rawBlob is String) {
      blob = base64Decode(rawBlob);
    }

    return Package(
      from: (map['from'] ?? map['From'] as String?) ?? '',
      to: (map['to'] ?? map['To'] as String?) ?? '',
      type: rawType,
      dataType: rawDataType,
      metadata: (map['metadata'] ?? map['Metadata'] as String?) ?? '',
      text: rawText is String ? rawText : null,
      blob: blob,
    );
  }

  Map<String, dynamic> toMap() => {
    'from': from,
    'to': to,
    'type': type.value,
    'data_type': dataType.value,
    'metadata': metadata,
    if (text != null) 'text': text,
    if (blob != null) 'blob': base64Encode(blob!),
  };
}

//endregion

//region Response

class Response {
  const Response({
    required this.commandID,
    required this.level,
    required this.time,
    required this.responseMessage,
  });

  final String commandID;
  final String level;
  final DataTime time;
  final String responseMessage;

  factory Response.fromMap(Map<String, dynamic> map) => Response(
    commandID: (map['CommandID'] as String?) ?? '',
    level: (map['Level'] as String?) ?? '',
    time: DataTime.fromMap(
      (map['Time'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    responseMessage: (map['ResponseMessage'] as String?) ?? '',
  );

  Map<String, dynamic> toMap() => {
    'CommandID': commandID,
    'Level': level,
    'Time': time.toMap(),
    'ResponseMessage': responseMessage,
  };
}

//endregion
