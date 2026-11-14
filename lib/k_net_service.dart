export './models/common.dart';
export './models/metrics.dart';
export './models/settings.dart';
export './models/record.dart';
export './models/cmd.dart';
export './export.dart';

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:k_net_service/k_net_service.dart';

import 'static_api.dart';

class CommandContainer {
  const CommandContainer({required this.check, required this.body});

  final (Response, bool) Function(Command command) check;
  final Response Function(Command command) body;
}

class KNetService extends ChangeNotifier {
  KNetService({
    required this.libPath,
    Map<String, CommandContainer> commands = const {},
  }) : _commands = Map.unmodifiable(commands);

  final String libPath;

  static const _readGroupThreshold = 64;
  static const _recordsCapacity = 256;
  static const _packagesCapacity = 256;
  static const _responsesCapacity = 256;

  bool _running = false;
  bool get running => _running;

  String? _reader;
  Metrics? _metrics;
  Metrics? get metrics => _metrics;

  List<KJRecord> _records = const [];
  List<KJRecord> get records => _records;

  List<Package> _packages = const [];
  List<Package> get packages => _packages;

  List<Response> _responses = const [];
  List<Response> get responses => _responses;

  List<PeerInfo> _peers = const [];
  List<PeerInfo> get peers => _peers;

  final Map<String, CommandContainer> _commands;
  Map<String, CommandContainer> get commands => _commands;

  Timer? _metricsTimer;
  Timer? _recordsTimer;
  Timer? _packagesTimer;
  Timer? _responsesTimer;
  Timer? _peersTimer;

  void run(KJSettings kj, KNSettings kn) {
    if (_running) return;
    _running = true;
    notifyListeners();

    runTask(libPath, toJsonString(kj.toMap()), toJsonString(kn.toMap()))
        .then((result) {
          final (level, response, reader) = result;
          if (level == 'Error') {
            debugPrint('KNetService.run native error: $response');
            _running = false;
            notifyListeners();
            return;
          }
          _reader = reader;
          _startMetricsPolling(const Duration(seconds: 1));
          _startRecordsPolling(const Duration(milliseconds: 200));
          _startPackagesPolling(const Duration(milliseconds: 200));
          _startResponsesPolling(const Duration(milliseconds: 200));
          _startPeersPolling(const Duration(seconds: 2));
          unawaited(_executerLoop());
        })
        .catchError((e) {
          debugPrint('KNetService.run: $e');
          _running = false;
          notifyListeners();
        });
  }

  void endwork() {
    if (!_running) return;
    _running = false;
    _metricsTimer?.cancel();
    _metricsTimer = null;
    _recordsTimer?.cancel();
    _recordsTimer = null;
    _packagesTimer?.cancel();
    _packagesTimer = null;
    _responsesTimer?.cancel();
    _responsesTimer = null;
    _peersTimer?.cancel();
    _peersTimer = null;
    _metrics = null;
    _records = const [];
    _packages = const [];
    _responses = const [];
    _peers = const [];
    final reader = _reader;
    _reader = null;
    notifyListeners();

    endworkTask(libPath, reader).catchError((e) {
      debugPrint('KNetService.endwork: $e');
    });
  }

  void write(KJRecord record) {
    if (!_running) return;
    writeTask(libPath, toJsonString(record.toMap())).catchError((e) {
      debugPrint('KNetService.write: $e');
    });
  }

  Future<FuncResponse?> execute(String commandJson) async {
    if (!_running) return null;
    try {
      final fr = await executeTask(libPath, commandJson);
      if (fr.level == 'Error') {
        debugPrint('KNetService.execute native error: ${fr.response}');
      }
      return fr;
    } catch (e) {
      debugPrint('KNetService.execute: $e');
      return null;
    }
  }

  Future<Metrics?> getMetrics() async {
    if (!_running) return null;
    try {
      final (kn, kj) = await metricsTask(libPath);
      if (kn == null || kj == null) return _metrics;

      final metrics = Metrics(
        kjournal: KJMetrics.fromMap(kj),
        knet: KNetMetrics.fromMap(kn),
      );
      _metrics = metrics;
      notifyListeners();
      return metrics;
    } catch (e) {
      debugPrint('KNetService.getMetrics: $e');
      return _metrics;
    }
  }

  Future<void> _executerLoop() async {
    CursorProgram? oldCursor;
    while (_running) {
      CursorProgram? newCursor;
      try {
        newCursor = await getCursorTask(libPath);
      } catch (e) {
        debugPrint('KNetService._executerLoop cursor: $e');
      }

      if (newCursor == null) {
        await Future.delayed(const Duration(milliseconds: 50));
        continue;
      }

      if (oldCursor != null &&
          toJsonString(oldCursor.toMap()) == toJsonString(newCursor.toMap())) {
        await Future.delayed(const Duration(milliseconds: 50));
        continue;
      }

      if (newCursor.executer == CursorExecuter.external ||
          newCursor.executer == CursorExecuter.both) {
        try {
          final programs = await externalProgramsTask(libPath);
          await Future.wait(programs.map(_executeCommand));
        } catch (e) {
          debugPrint('KNetService._executerLoop programs: $e');
        }
      }

      oldCursor = newCursor;
    }
  }

  Future<void> _executeCommand(Command command) async {
    final container = _commands[command.name];
    if (container == null) {
      debugPrint(
        'KNetService._executeCommand: no container for ${command.name}',
      );
      return;
    }
    try {
      final (checkResp, ok) = container.check(command);
      final resp = ok ? container.body(command) : checkResp;
      final fr = await writeResponseTask(libPath, resp);
      if (fr.level == 'Error') {
        debugPrint(
          'KNetService._executeCommand writeResponse error: ${fr.response}',
        );
      }
    } catch (e) {
      debugPrint('KNetService._executeCommand: $e');
    }
  }

  Future<void> _pollRecords() async {
    if (!_running) return;
    final reader = _reader;
    if (reader == null) return;

    final len = _metrics?.kjournal.readersFill[reader]?.len ?? 0;

    try {
      if (len < _readGroupThreshold) {
        final record = await readTask(libPath, reader);
        if (record == null) return;
        _appendRecords([record]);
      } else {
        final batch = await readGroupTask(libPath, reader);
        if (batch.isEmpty) return;
        _appendRecords(batch);
      }
    } catch (e) {
      debugPrint('KNetService._pollRecords: $e');
    }
  }

  Future<void> _pollPackages() async {
    if (!_running) return;
    final reader = _reader;
    if (reader == null) return;

    try {
      final package = await packageTask(libPath, reader);
      if (package == null) return;
      _appendPackages([package]);
    } catch (e) {
      debugPrint('KNetService._pollPackages: $e');
    }
  }

  Future<void> _pollResponses() async {
    if (!_running) return;
    try {
      final response = await responseTask(libPath);
      if (response == null) return;
      _appendResponses([response]);
    } catch (e) {
      debugPrint('KNetService._pollResponses: $e');
    }
  }

  Future<void> _pollPeers() async {
    if (!_running) return;
    try {
      final peers = await peerListTask(libPath);
      _peers = peers; // снапшот — replace, не append
      notifyListeners();
    } catch (e) {
      debugPrint('KNetService._pollPeers: $e');
    }
  }

  void _appendRecords(List<KJRecord> incoming) {
    final merged = [..._records, ...incoming];
    _records = merged.length > _recordsCapacity
        ? merged.sublist(merged.length - _recordsCapacity)
        : merged;
    notifyListeners();
  }

  void _appendPackages(List<Package> incoming) {
    final merged = [..._packages, ...incoming];
    _packages = merged.length > _packagesCapacity
        ? merged.sublist(merged.length - _packagesCapacity)
        : merged;
    notifyListeners();
  }

  void _appendResponses(List<Response> incoming) {
    final merged = [..._responses, ...incoming];
    _responses = merged.length > _responsesCapacity
        ? merged.sublist(merged.length - _responsesCapacity)
        : merged;
    notifyListeners();
  }

  void _startMetricsPolling(Duration d) {
    _metricsTimer?.cancel();
    _metricsTimer = Timer.periodic(d, (_) => getMetrics());
  }

  void _startRecordsPolling(Duration d) {
    _recordsTimer?.cancel();
    _recordsTimer = Timer.periodic(d, (_) => _pollRecords());
  }

  void _startPackagesPolling(Duration d) {
    _packagesTimer?.cancel();
    _packagesTimer = Timer.periodic(d, (_) => _pollPackages());
  }

  void _startResponsesPolling(Duration d) {
    _responsesTimer?.cancel();
    _responsesTimer = Timer.periodic(d, (_) => _pollResponses());
  }

  void _startPeersPolling(Duration d) {
    _peersTimer?.cancel();
    _peersTimer = Timer.periodic(d, (_) => _pollPeers());
  }

  @override
  void dispose() {
    _metricsTimer?.cancel();
    _recordsTimer?.cancel();
    _packagesTimer?.cancel();
    _responsesTimer?.cancel();
    _peersTimer?.cancel();
    super.dispose();
  }
}
