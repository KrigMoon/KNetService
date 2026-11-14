import 'package:k_net_service/k_net_service.dart';

//region Peer

class PeerInfo {
  const PeerInfo({required this.node, required this.peerList});

  final Node node;
  final List<Node> peerList;

  factory PeerInfo.fromMap(Map<String, dynamic> m) => PeerInfo(
    node: Node.fromMap(Map<String, dynamic>.from(m['Node'] as Map)),
    peerList: (m['PeerList'] as List<dynamic>? ?? const [])
        .map((e) => Node.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );
}

//endregion

//region Node

enum TypeNode {
  server(0),
  client(1);

  const TypeNode(this.value);
  final int value;

  static TypeNode fromValue(int v) => TypeNode.values.firstWhere(
    (e) => e.value == v,
    orElse: () => TypeNode.server,
  );
}

class Node {
  const Node({
    required this.id,
    required this.name,
    required this.type,
    required this.listeningIP,
    required this.listeningPort,
  });

  final String id;
  final String name;
  final TypeNode type;
  final String listeningIP;
  final int listeningPort;

  Map<String, dynamic> toMap() => {
    'Id': id,
    'Name': name,
    'Type': type.value,
    'ListeningIP': listeningIP,
    'ListeningPort': listeningPort,
  };

  factory Node.fromMap(Map<String, dynamic> m) => Node(
    id: m['Id'] as String? ?? '',
    name: m['Name'] as String? ?? '',
    type: TypeNode.fromValue((m['Type'] as int?) ?? TypeNode.server.value),
    listeningIP: m['ListeningIP'] as String? ?? '',
    listeningPort: m['ListeningPort'] as int? ?? 0,
  );
}

//endregion

//region Settings

class KJSettings {
  const KJSettings({
    required this.defaultReaderBuf,
    required this.maxInGroup,
    required this.fileDumperDir,
    required this.alarmRWGroup,
    required this.alarmWrite,
    required this.crashReport,
  });

  final int defaultReaderBuf;
  final int maxInGroup;
  final String fileDumperDir;
  final DataTime alarmRWGroup;
  final DataTime alarmWrite;
  final String crashReport;

  Map<String, dynamic> toMap() => {
    'DefaultReaderBuf': defaultReaderBuf,
    'MaxInGroup': maxInGroup,
    'FileDumperDir': fileDumperDir,
    'AlarmRWGroup': alarmRWGroup.toMap(),
    'AlarmWrite': alarmWrite.toMap(),
    'CrashReport': crashReport,
  };
}

class KNSettings {
  const KNSettings({
    required this.externalCommandsMap,
    required this.autoRun,
    required this.fileStorageDir,
    required this.remoteControl,
    required this.myNode,
    required this.password,
  });

  final List<String> externalCommandsMap;
  final List<String> autoRun;
  final String fileStorageDir;
  final bool remoteControl;
  final Node myNode;
  final String password;

  Map<String, dynamic> toMap() => {
    'ExternalCommandsMap': externalCommandsMap,
    'AutoRun': autoRun,
    'FileStorageDir': fileStorageDir,
    'RemoteControl': remoteControl,
    'MyNode': myNode.toMap(),
    'Password': password,
  };
}

//endregion
