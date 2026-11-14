import 'package:flutter/material.dart';
import 'package:k_net_service/k_net_service.dart';
import 'package:kui/kui.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _cmd = TextEditingController();

  @override
  void dispose() {
    _cmd.dispose();
    super.dispose();
  }

  Future<void> _execute() async {
    final text = _cmd.text.trim();
    if (text.isEmpty) return;

    final service = context.read<KNetService>();
    if (!service.running) return;

    final fr = await service.execute(text);
    if (!mounted) return;

    if (fr == null || fr.level == 'Error') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(fr?.response ?? 'Не удалось отправить')),
      );
      return;
    }

    _cmd.clear();
  }

  @override
  Widget build(BuildContext context) {
    return KUIPage(
      title: "Чат",
      scroll: false,
      child: KUIAxisList(
        axis: Axis.vertical,
        children: [
          Expanded(child: ChatPackagesList()),
          KUIInput(controller: _cmd, action: (_) => _execute()),
        ],
      ),
    );
  }
}

class ChatPackagesList extends StatelessWidget {
  const ChatPackagesList({super.key});

  @override
  Widget build(BuildContext context) {
    final packages = context.watch<KNetService>().packages;
    if (packages.isEmpty) {
      return const Center(
        child: KUIText(label: "Пусто", style: KDFontStyle.p),
      );
    }
    return SingleChildScrollView(
      child: KUIAxisList(
        axis: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        spacing: 0,
        children: [
          for (final p in packages)
            KUICard(
              height: KDGeometry.header * 2.5,
              paddingArea: EdgeInsets.symmetric(
                horizontal: KDGeometry.baseLSpacing,
                vertical: KDGeometry.baseMSpacing,
              ),
              child: Center(
                child: KUIAxisList(
                  mainAxisSize: MainAxisSize.min,
                  axis: Axis.vertical,
                  children: [
                    KUIText(label: p.from, style: KDFontStyle.h3),
                    KUIText(label: p.text ?? "", style: KDFontStyle.p),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
