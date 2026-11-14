import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<String> prepareKnetLibraryPath() async {
  final abiDir = _abiDir();
  const libName = 'libknet_service.so';
  final assetPath = 'packages/k_net_service/assets/native/$abiDir/$libName';
  final file = await _extractAsset(assetPath, libName);
  return file.path;
}

DynamicLibrary openKnetLibrary(String path) => DynamicLibrary.open(path);

String _abiDir() {
  if (Platform.isLinux) return 'linux-amd64';
  if (Platform.isAndroid) {
    final abi = Abi.current();
    if (abi == Abi.androidArm64) return 'android-arm64';
    if (abi == Abi.androidArm) return 'android-arm';
    if (abi == Abi.androidX64) return 'android-amd64';
    throw UnsupportedError('Unsupported Android ABI: $abi');
  }
  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
}

Future<File> _extractAsset(String assetPath, String fileName) async {
  final dir = await getApplicationSupportDirectory();
  final file = File('${dir.path}/$fileName');
  if (await file.exists() && await file.length() > 0) return file;

  final data = await rootBundle.load(assetPath);
  await file.writeAsBytes(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    flush: true,
  );
  return file;
}

//region FFI typedefs

typedef RunKJournalC = Pointer<Utf8> Function(Pointer<Utf8>);
typedef RunKJournalDart = Pointer<Utf8> Function(Pointer<Utf8>);

typedef EndworkKJournalC = Pointer<Utf8> Function();
typedef EndworkKJournalDart = Pointer<Utf8> Function();

typedef KJournalMetricsC = Pointer<Utf8> Function();
typedef KJournalMetricsDart = Pointer<Utf8> Function();

typedef KJNewWriterC = Pointer<Utf8> Function();
typedef KJNewWriterDart = Pointer<Utf8> Function();

typedef KJDelWriterC = Pointer<Utf8> Function();
typedef KJDelWriterDart = Pointer<Utf8> Function();

typedef KJWriteC = Pointer<Utf8> Function(Pointer<Utf8>);
typedef KJWriteDart = Pointer<Utf8> Function(Pointer<Utf8>);

typedef KJNewReaderC = Pointer<Utf8> Function(Pointer<Utf8>, Int32);
typedef KJNewReaderDart = Pointer<Utf8> Function(Pointer<Utf8>, int);

typedef KJDelReaderC = Pointer<Utf8> Function(Pointer<Utf8>);
typedef KJDelReaderDart = Pointer<Utf8> Function(Pointer<Utf8>);

typedef KJReadC = Pointer<Utf8> Function(Pointer<Utf8>);
typedef KJReadDart = Pointer<Utf8> Function(Pointer<Utf8>);

typedef KJReadGroupC = Pointer<Utf8> Function(Pointer<Utf8>);
typedef KJReadGroupDart = Pointer<Utf8> Function(Pointer<Utf8>);

typedef RunKNetC = Pointer<Utf8> Function(Pointer<Utf8>);
typedef RunKNetDart = Pointer<Utf8> Function(Pointer<Utf8>);

typedef EndworkKNetC = Pointer<Utf8> Function();
typedef EndworkKNetDart = Pointer<Utf8> Function();

typedef KNetMetricsC = Pointer<Utf8> Function();
typedef KNetMetricsDart = Pointer<Utf8> Function();

typedef KNExecuteC = Pointer<Utf8> Function(Pointer<Utf8>);
typedef KNExecuteDart = Pointer<Utf8> Function(Pointer<Utf8>);

typedef KNResponseC = Pointer<Utf8> Function();
typedef KNResponseDart = Pointer<Utf8> Function();

typedef KNWriteResponseC = Pointer<Utf8> Function(Pointer<Utf8>);
typedef KNWriteResponseDart = Pointer<Utf8> Function(Pointer<Utf8>);

typedef KNGetCursorC = Pointer<Utf8> Function();
typedef KNGetCursorDart = Pointer<Utf8> Function();

typedef KNExternalProgramsC = Pointer<Utf8> Function();
typedef KNExternalProgramsDart = Pointer<Utf8> Function();

typedef KNPeerListC = Pointer<Utf8> Function();
typedef KNPeerListDart = Pointer<Utf8> Function();

typedef KNAddReaderPackagesC = Pointer<Utf8> Function(Pointer<Utf8>, Int32);
typedef KNAddReaderPackagesDart = Pointer<Utf8> Function(Pointer<Utf8>, int);

typedef KNDelReaderPackagesC = Pointer<Utf8> Function(Pointer<Utf8>);
typedef KNDelReaderPackagesDart = Pointer<Utf8> Function(Pointer<Utf8>);

typedef KNPackageC = Pointer<Utf8> Function(Pointer<Utf8>);
typedef KNPackageDart = Pointer<Utf8> Function(Pointer<Utf8>);

typedef FreeStringC = Void Function(Pointer<Utf8>);
typedef FreeStringDart = void Function(Pointer<Utf8>);

//endregion

//region Bindings

class KnetBindings {
  final RunKJournalDart runKJournal;
  final EndworkKJournalDart endworkKJournal;
  final KJournalMetricsDart kJournalMetrics;
  final KJNewWriterDart kjNewWriter;
  final KJDelWriterDart kjDelWriter;
  final KJWriteDart kjWrite;
  final KJNewReaderDart kjNewReader;
  final KJDelReaderDart kjDelReader;
  final KJReadDart kjRead;
  final KJReadGroupDart kjReadGroup;
  final RunKNetDart runKNet;
  final EndworkKNetDart endworkKNet;
  final KNetMetricsDart kNetMetrics;
  final KNExecuteDart knExecute;
  final KNResponseDart knResponse;
  final KNWriteResponseDart knWriteResponse;
  final KNGetCursorDart knGetCursor;
  final KNExternalProgramsDart knExternalPrograms;
  final KNPeerListDart knPeerList;
  final KNAddReaderPackagesDart knAddReaderPackages;
  final KNDelReaderPackagesDart knDelReaderPackages;
  final KNPackageDart knPackage;
  final FreeStringDart freeString;

  KnetBindings._({
    required this.runKJournal,
    required this.endworkKJournal,
    required this.kJournalMetrics,
    required this.kjNewWriter,
    required this.kjDelWriter,
    required this.kjWrite,
    required this.kjNewReader,
    required this.kjDelReader,
    required this.kjRead,
    required this.kjReadGroup,
    required this.runKNet,
    required this.endworkKNet,
    required this.kNetMetrics,
    required this.knExecute,
    required this.knResponse,
    required this.knWriteResponse,
    required this.knGetCursor,
    required this.knExternalPrograms,
    required this.knPeerList,
    required this.knAddReaderPackages,
    required this.knDelReaderPackages,
    required this.knPackage,
    required this.freeString,
  });

  factory KnetBindings(DynamicLibrary lib) {
    return KnetBindings._(
      runKJournal: lib.lookupFunction<RunKJournalC, RunKJournalDart>(
        'RunKJournal',
      ),
      endworkKJournal: lib
          .lookupFunction<EndworkKJournalC, EndworkKJournalDart>(
            'EndworkKJournal',
          ),
      kJournalMetrics: lib
          .lookupFunction<KJournalMetricsC, KJournalMetricsDart>(
            'KJournalMetrics',
          ),
      kjNewWriter: lib.lookupFunction<KJNewWriterC, KJNewWriterDart>(
        'KJNewWriter',
      ),
      kjDelWriter: lib.lookupFunction<KJDelWriterC, KJDelWriterDart>(
        'KJDelWriter',
      ),
      kjWrite: lib.lookupFunction<KJWriteC, KJWriteDart>('KJWrite'),
      kjNewReader: lib.lookupFunction<KJNewReaderC, KJNewReaderDart>(
        'KJNewReader',
      ),
      kjDelReader: lib.lookupFunction<KJDelReaderC, KJDelReaderDart>(
        'KJDelReader',
      ),
      kjRead: lib.lookupFunction<KJReadC, KJReadDart>('KJRead'),
      kjReadGroup: lib.lookupFunction<KJReadGroupC, KJReadGroupDart>(
        'KJReadGroup',
      ),
      runKNet: lib.lookupFunction<RunKNetC, RunKNetDart>('RunKNet'),
      endworkKNet: lib.lookupFunction<EndworkKNetC, EndworkKNetDart>(
        'EndworkKNet',
      ),
      kNetMetrics: lib.lookupFunction<KNetMetricsC, KNetMetricsDart>(
        'KNetMetrics',
      ),
      knExecute: lib.lookupFunction<KNExecuteC, KNExecuteDart>('KNExecute'),
      knResponse: lib.lookupFunction<KNResponseC, KNResponseDart>('KNResponse'),
      knWriteResponse: lib
          .lookupFunction<KNWriteResponseC, KNWriteResponseDart>(
            'KNWriteResponse',
          ),
      knGetCursor: lib.lookupFunction<KNGetCursorC, KNGetCursorDart>(
        'KNGetCursor',
      ),
      knExternalPrograms: lib
          .lookupFunction<KNExternalProgramsC, KNExternalProgramsDart>(
            'KNExternalPrograms',
          ),
      knPeerList: lib.lookupFunction<KNPeerListC, KNPeerListDart>('KNPeerList'),
      knAddReaderPackages: lib
          .lookupFunction<KNAddReaderPackagesC, KNAddReaderPackagesDart>(
            'KNAddReaderPackages',
          ),
      knDelReaderPackages: lib
          .lookupFunction<KNDelReaderPackagesC, KNDelReaderPackagesDart>(
            'KNDelReaderPackages',
          ),
      knPackage: lib.lookupFunction<KNPackageC, KNPackageDart>('KNPackage'),
      freeString: lib.lookupFunction<FreeStringC, FreeStringDart>('FreeString'),
    );
  }
}

//endregion

//region Call With AutoClear

String takeString(KnetBindings bindings, Pointer<Utf8> ptr) {
  if (ptr == nullptr) return '';
  try {
    return ptr.toDartString();
  } finally {
    bindings.freeString(ptr);
  }
}

//endregion
