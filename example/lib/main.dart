import 'dart:io';

import 'package:example/pages/chat.dart';
import 'package:example/pages/journal.dart';
import 'package:example/pages/knet.dart';
import 'package:example/pages/logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:k_net_service/k_net_service.dart';
import 'package:kui/kui.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final libPath = await prepareKnetLibraryPath();
  final dir = Directory('./');
  if (!await dir.exists()) await dir.create(recursive: true);
  final path = '${dir.path}/crash_reports';

  runWithKUI(
    otherProviders: [
      ChangeNotifierProvider(
        create: (_) => KNetService(
          libPath: libPath,
          commands: {
            "/map": CommandContainer(
              body: (command) => Response(
                commandID: command.id,
                level: "INFO",
                time: DataTime(
                  year: 0,
                  month: 0,
                  day: 0,
                  hour: 0,
                  minute: 0,
                  second: 0,
                  miliseconds: 0,
                ),
                responseMessage: "GG",
              ),
              check: (Command command) {
                return (
                  Response(
                    commandID: command.id,
                    level: "INFO",
                    time: DataTime(
                      year: 0,
                      month: 0,
                      day: 0,
                      hour: 0,
                      minute: 0,
                      second: 0,
                      miliseconds: 0,
                    ),
                    responseMessage: "RR",
                  ),
                  true,
                );
              },
            ),
          },
        ),
      ),
    ],
    child: MyApp(path: path),
  );
}

class MyApp extends StatelessWidget {
  final String path;
  const MyApp({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    debugPrint("GHG^ d $path");

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: KUIScreen(
        body: Consumer<KNetService>(
          builder: (context, net, child) => KUIMenu(
            position: KDMenuPosition.left,
            children: [
              KDMenuItem(icon: LucideIcons.book_heart, page: JournalPage()),
              KDMenuItem(icon: LucideIcons.logs, page: LogsPage()),
              KDMenuItem(icon: LucideIcons.network, page: KNetPage()),
              KDMenuItem(icon: LucideIcons.messages_square, page: ChatPage()),
            ],
            actions: [
              KDMenuAction(
                icon: net.running ? LucideIcons.power_off : LucideIcons.power,
                action: () => {
                  net.running
                      ? net.endwork()
                      : net.run(
                          KJSettings(
                            defaultReaderBuf: 512,
                            maxInGroup: 64,
                            fileDumperDir: path,
                            alarmRWGroup: DataTime(
                              year: 0,
                              month: 0,
                              day: 0,
                              hour: 0,
                              minute: 0,
                              second: 0,
                              miliseconds: 0,
                            ),
                            alarmWrite: DataTime(
                              year: 0,
                              month: 0,
                              day: 0,
                              hour: 0,
                              minute: 0,
                              second: 0,
                              miliseconds: 0,
                            ),
                            crashReport: path,
                          ),
                          KNSettings(
                            externalCommandsMap: ["/map"],
                            autoRun: ["/connect 5.138.188.189:8080 'secret'"],
                            fileStorageDir: "",
                            remoteControl: true,
                            myNode: Node(
                              id: "flutterNode",
                              name: "FlutterNode",
                              type: TypeNode.client,
                              listeningIP: "",
                              listeningPort: 0,
                            ),
                            password: "1234",
                          ),
                        ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
