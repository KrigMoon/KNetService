enum CursorExecuter {
  local(0),
  external(1),
  both(2);

  const CursorExecuter(this.value);
  final int value;

  static CursorExecuter fromInt(int v) => CursorExecuter.values.firstWhere(
    (e) => e.value == v,
    orElse: () => local,
  );

  static CursorExecuter fromAny(Object? any) {
    if (any is int) return fromInt(any);
    if (any is String) {
      final byName = CursorExecuter.values
          .where((e) => e.name.toUpperCase() == any.toUpperCase())
          .firstOrNull;
      if (byName != null) return byName;
      final asInt = int.tryParse(any);
      if (asInt != null) return fromInt(asInt);
    }
    return local;
  }
}

class CursorProgram {
  const CursorProgram({
    required this.id,
    required this.executer,
    required this.wait,
    required this.localProgram,
    required this.externalProgram,
  });

  final String id;
  final CursorExecuter executer;
  final int wait;
  final List<Command>? localProgram;
  final List<Command>? externalProgram;

  factory CursorProgram.fromMap(Map<String, dynamic> map) => CursorProgram(
    id: (map['ID'] as String?) ?? '',
    executer: CursorExecuter.fromAny(map['Executer']),
    wait: (map['Wait'] as int?) ?? 0,
    localProgram: (map['LocalProgram'] as List?)
        ?.map((e) => Command.fromMap((e as Map).cast<String, dynamic>()))
        .toList(),
    externalProgram: (map['ExternalProgram'] as List?)
        ?.map((e) => Command.fromMap((e as Map).cast<String, dynamic>()))
        .toList(),
  );

  Map<String, dynamic> toMap() => {
    'ID': id,
    'Executer': executer.value,
    'Wait': wait,
    'LocalProgram': localProgram?.map((e) => e.toMap()).toList(),
    'ExternalProgram': externalProgram?.map((e) => e.toMap()).toList(),
  };
}

class Command {
  const Command({required this.id, required this.name, required this.args});

  final String id;
  final String name;
  final List<Arg> args;

  factory Command.fromMap(Map<String, dynamic> map) => Command(
    id: (map['ID'] as String?) ?? '',
    name: (map['Name'] as String?) ?? '',
    args:
        (map['Args'] as List?)
            ?.map((e) => Arg.fromMap((e as Map).cast<String, dynamic>()))
            .toList() ??
        const [],
  );

  Map<String, dynamic> toMap() => {
    'ID': id,
    'Name': name,
    'Args': args.map((e) => e.toMap()).toList(),
  };
}

class Arg {
  const Arg({
    required this.ident,
    required this.str,
    required this.addr,
    required this.list,
    required this.id,
    required this.key,
    required this.number,
  });

  final String ident;
  final String str;
  final String addr;
  final String list;
  final String id;
  final String key;
  final String number;

  factory Arg.fromMap(Map<String, dynamic> map) => Arg(
    ident: (map['Ident'] as String?) ?? '',
    str: (map['Str'] as String?) ?? '',
    addr: (map['Addr'] as String?) ?? '',
    list: (map['List'] as String?) ?? '',
    id: (map['ID'] as String?) ?? '',
    key: (map['Key'] as String?) ?? '',
    number: (map['Number'] as String?) ?? '',
  );

  Map<String, dynamic> toMap() => {
    'Ident': ident,
    'Str': str,
    'Addr': addr,
    'List': list,
    'ID': id,
    'Key': key,
    'Number': number,
  };
}
