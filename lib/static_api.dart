import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:k_net_service/k_net_service.dart';

String _arg(String? s, String Function(Pointer<Utf8>) fn) {
  final p = (s ?? '').toNativeUtf8();
  try {
    return fn(p);
  } finally {
    calloc.free(p);
  }
}

Future<(String, String, String?)> runTask(
  String libPath,
  String kjJson,
  String knJson,
) {
  return Isolate.run(() {
    final n = KnetBindings(openKnetLibrary(libPath));
    final kjRaw = _arg(kjJson, (p) => takeString(n, n.runKJournal(p)));
    final kj = fromJsonString(kjRaw, FuncResponse.fromMap);
    if (kj.level == 'Error') {
      return (kj.level, kj.response, null as String?);
    }

    final nrRaw = _arg(
      'flutterReader',
      (p) => takeString(n, n.kjNewReader(p, 512)),
    );
    final nr = fromJsonString(nrRaw, FuncResponse.fromMap);

    final nwRaw = takeString(n, n.kjNewWriter());
    final nw = fromJsonString(nwRaw, FuncResponse.fromMap);
    if (nw.level == 'Error') {
      if (nr.level != 'Error') {
        _arg(nr.response, (p) => takeString(n, n.kjDelReader(p)));
      }
      return (nw.level, nw.response, null as String?);
    }

    final knRaw = _arg(knJson, (p) => takeString(n, n.runKNet(p)));
    final kn = fromJsonString(knRaw, FuncResponse.fromMap);
    _arg('flutterReader', (p) => takeString(n, n.knAddReaderPackages(p, 512)));

    return (kn.level, kn.response, nr.level == 'Error' ? null : nr.response);
  });
}

Future<void> endworkTask(String libPath, String? reader) {
  return Isolate.run(() {
    final n = KnetBindings(openKnetLibrary(libPath));
    if (reader != null && reader.isNotEmpty) {
      _arg(reader, (p) => takeString(n, n.knDelReaderPackages(p)));
    }
    takeString(n, n.endworkKNet());
    takeString(n, n.kjDelWriter());
    if (reader != null && reader.isNotEmpty) {
      _arg(reader, (p) => takeString(n, n.kjDelReader(p)));
    }
    takeString(n, n.endworkKJournal());
  });
}

Future<(Map<String, dynamic>?, Map<String, dynamic>?)> metricsTask(
  String libPath,
) {
  return Isolate.run(() {
    final n = KnetBindings(openKnetLibrary(libPath));
    final knRaw = takeString(n, n.kNetMetrics());
    final kjRaw = takeString(n, n.kJournalMetrics());
    final kn = fromJsonString(knRaw, FuncResponse.fromMap);
    final kj = fromJsonString(kjRaw, FuncResponse.fromMap);
    return (
      kn.level == 'Success' ? fromJsonString(kn.response, (m) => m) : null,
      kj.level == 'Success' ? fromJsonString(kj.response, (m) => m) : null,
    );
  });
}

Future<KJRecord?> readTask(String libPath, String id) {
  return Isolate.run(() {
    final n = KnetBindings(openKnetLibrary(libPath));
    final raw = _arg(id, (p) => takeString(n, n.kjRead(p)));
    final fr = fromJsonString(raw, FuncResponse.fromMap);
    if (fr.level != 'Success' || fr.response.isEmpty) return null;
    return fromJsonString(fr.response, KJRecord.fromMap);
  });
}

Future<List<KJRecord>> readGroupTask(String libPath, String id) {
  return Isolate.run(() {
    final n = KnetBindings(openKnetLibrary(libPath));
    final raw = _arg(id, (p) => takeString(n, n.kjReadGroup(p)));
    final fr = fromJsonString(raw, FuncResponse.fromMap);
    if (fr.level != 'Success') return <KJRecord>[];
    return fromJsonList(fr.response, KJRecord.fromMap);
  });
}

Future<void> writeTask(String libPath, String recordJson) {
  return Isolate.run(() {
    final n = KnetBindings(openKnetLibrary(libPath));
    final raw = _arg(recordJson, (p) => takeString(n, n.kjWrite(p)));
    final fr = fromJsonString(raw, FuncResponse.fromMap);
    if (fr.level != 'Success') {
      throw StateError('KJWrite: ${fr.response}');
    }
  });
}

Future<Package?> packageTask(String libPath, String id) {
  return Isolate.run(() {
    final n = KnetBindings(openKnetLibrary(libPath));
    final raw = _arg(id, (p) => takeString(n, n.knPackage(p)));
    final fr = fromJsonString(raw, FuncResponse.fromMap);
    if (fr.level != 'Success' || fr.response.isEmpty) return null;
    return fromJsonString(fr.response, Package.fromMap);
  });
}

Future<FuncResponse> executeTask(String libPath, String commandJson) {
  return Isolate.run(() {
    final n = KnetBindings(openKnetLibrary(libPath));
    final raw = _arg(commandJson, (p) => takeString(n, n.knExecute(p)));
    return fromJsonString(raw, FuncResponse.fromMap);
  });
}

Future<Response?> responseTask(String libPath) {
  return Isolate.run(() {
    final n = KnetBindings(openKnetLibrary(libPath));
    final raw = takeString(n, n.knResponse());
    final fr = fromJsonString(raw, FuncResponse.fromMap);
    if (fr.level != 'Success' || fr.response.isEmpty) return null;
    return fromJsonString(fr.response, Response.fromMap);
  });
}

Future<List<PeerInfo>> peerListTask(String libPath) {
  return Isolate.run(() {
    final n = KnetBindings(openKnetLibrary(libPath));
    final raw = takeString(n, n.knPeerList());
    final fr = fromJsonString(raw, FuncResponse.fromMap);
    if (fr.level != 'Success') {
      throw StateError('KNPeerList: ${fr.response}');
    }
    return fromJsonList(fr.response, PeerInfo.fromMap);
  });
}

Future<FuncResponse> writeResponseTask(String libPath, Response response) {
  return Isolate.run(() {
    final n = KnetBindings(openKnetLibrary(libPath));
    final raw = _arg(
      toJsonString(response.toMap()),
      (p) => takeString(n, n.knWriteResponse(p)),
    );
    return fromJsonString(raw, FuncResponse.fromMap);
  });
}

Future<CursorProgram?> getCursorTask(String libPath) {
  return Isolate.run(() {
    final n = KnetBindings(openKnetLibrary(libPath));
    final raw = takeString(n, n.knGetCursor());
    final fr = fromJsonString(raw, FuncResponse.fromMap);
    if (fr.level != 'Success' || fr.response.isEmpty) return null;
    return fromJsonString(fr.response, CursorProgram.fromMap);
  });
}

Future<List<Command>> externalProgramsTask(String libPath) {
  return Isolate.run(() {
    final n = KnetBindings(openKnetLibrary(libPath));
    final raw = takeString(n, n.knExternalPrograms());
    final fr = fromJsonString(raw, FuncResponse.fromMap);
    if (fr.level != 'Success' || fr.response.isEmpty) {
      return <Command>[];
    }
    return fromJsonList(fr.response, Command.fromMap);
  });
}
