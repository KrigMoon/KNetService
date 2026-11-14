import 'package:k_net_service/k_net_service.dart';

//region Metrics

class LenCap {
  const LenCap({required this.len, required this.cap});

  final int len;
  final int cap;

  factory LenCap.fromMap(Map<String, dynamic> map) =>
      LenCap(len: asInt(map['Len']), cap: asInt(map['Cap']));

  Map<String, dynamic> toMap() => {'Len': len, 'Cap': cap};
}

class ReaderMetrics {
  const ReaderMetrics({required this.id, required this.len, required this.cap});

  final String id;
  final int len;
  final int cap;

  factory ReaderMetrics.fromMap(Map<String, dynamic> map) => ReaderMetrics(
    id: (map['ID'] as String?) ?? '',
    len: asInt(map['Len']),
    cap: asInt(map['Cap']),
  );

  Map<String, dynamic> toMap() => {'ID': id, 'Len': len, 'Cap': cap};
}

class CursorInfo {
  const CursorInfo({
    required this.id,
    required this.executer,
    required this.lenLoc,
    required this.lenExt,
  });

  final String id;
  final String executer;
  final int lenLoc;
  final int lenExt;

  factory CursorInfo.fromMap(Map<String, dynamic> map) => CursorInfo(
    id: (map['ID'] as String?) ?? '',
    executer: (map['Executer'] as String?) ?? '',
    lenLoc: asInt(map['LenLoc']),
    lenExt: asInt(map['LenExt']),
  );

  Map<String, dynamic> toMap() => {
    'ID': id,
    'Executer': executer,
    'LenLoc': lenLoc,
    'LenExt': lenExt,
  };
}

class CursorMetrics {
  const CursorMetrics({
    required this.cursor,
    required this.len,
    required this.cap,
  });

  final CursorInfo cursor;
  final int len;
  final int cap;

  factory CursorMetrics.fromMap(Map<String, dynamic> map) => CursorMetrics(
    cursor: CursorInfo.fromMap(
      (map['Cursor'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    len: asInt(map['Len']),
    cap: asInt(map['Cap']),
  );

  Map<String, dynamic> toMap() => {
    'Cursor': cursor.toMap(),
    'Len': len,
    'Cap': cap,
  };
}

class KNetCoreMetrics {
  const KNetCoreMetrics({
    required this.status,
    required this.entry,
    required this.exit,
    required this.peersCount,
  });

  final Status status;
  final LenCap entry;
  final LenCap exit;
  final int peersCount;

  factory KNetCoreMetrics.fromMap(Map<String, dynamic> map) => KNetCoreMetrics(
    status: Status.fromAny(map['Status']),
    entry: LenCap.fromMap(
      (map['Entry'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    exit: LenCap.fromMap(
      (map['Exit'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    peersCount: asInt(map['PeersCount']),
  );

  Map<String, dynamic> toMap() => {
    'Status': status.value,
    'Entry': entry.toMap(),
    'Exit': exit.toMap(),
    'PeersCount': peersCount,
  };
}

class KNetMetrics {
  const KNetMetrics({
    required this.status,
    required this.cursor,
    required this.responses,
    required this.core,
    required this.readersCount,
    required this.readers,
  });

  final Status status;
  final CursorMetrics cursor;
  final LenCap responses;
  final KNetCoreMetrics core;
  final int readersCount;
  final List<ReaderMetrics> readers;

  factory KNetMetrics.fromMap(Map<String, dynamic> map) => KNetMetrics(
    status: Status.fromAny(map['Status']),
    cursor: CursorMetrics.fromMap(
      (map['Cursor'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    responses: LenCap.fromMap(
      (map['Responses'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    core: KNetCoreMetrics.fromMap(
      (map['Core'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    readersCount: asInt(map['ReadersCount']),
    readers: ((map['Readers'] as List?) ?? const [])
        .map((e) => ReaderMetrics.fromMap((e as Map).cast<String, dynamic>()))
        .toList(),
  );

  Map<String, dynamic> toMap() => {
    'Status': status.value,
    'Cursor': cursor.toMap(),
    'Responses': responses.toMap(),
    'Core': core.toMap(),
    'ReadersCount': readersCount,
    'Readers': readers.map((e) => e.toMap()).toList(),
  };
}

class KJMetrics {
  const KJMetrics({
    required this.status,
    required this.writers,
    required this.readers,
    required this.readersFill,
  });

  final Status status;
  final int writers;
  final int readers;
  final Map<String, LenCap> readersFill;

  factory KJMetrics.fromMap(Map<String, dynamic> map) => KJMetrics(
    status: Status.fromAny(map['Status']),
    writers: asInt(map['Writers']),
    readers: asInt(map['Readers']),
    readersFill: ((map['ReadersFill'] as Map?) ?? const {}).map(
      (k, v) => MapEntry(
        k as String,
        LenCap.fromMap((v as Map).cast<String, dynamic>()),
      ),
    ),
  );

  Map<String, dynamic> toMap() => {
    'Status': status.value,
    'Writers': writers,
    'Readers': readers,
    'ReadersFill': readersFill.map((k, v) => MapEntry(k, v.toMap())),
  };
}

class Metrics {
  const Metrics({required this.kjournal, required this.knet});

  final KJMetrics kjournal;
  final KNetMetrics knet;

  factory Metrics.fromMap(Map<String, dynamic> map) => Metrics(
    kjournal: KJMetrics.fromMap(
      (map['KJournal'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    knet: KNetMetrics.fromMap(
      (map['KNet'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
  );

  Map<String, dynamic> toMap() => {
    'KJournal': kjournal.toMap(),
    'KNet': knet.toMap(),
  };
}


//endregion
