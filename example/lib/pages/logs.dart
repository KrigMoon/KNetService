import 'package:flutter/material.dart';
import 'package:k_net_service/k_net_service.dart';
import 'package:kui/kui.dart';
import 'package:provider/provider.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final net = context.watch<KNetService>();
    final records = net.records;
    final response = net.responses;
    return KUIPage(
      title: "Системные сообщения",
      scroll: false,
      child: KUIAxisList(
        axis: Axis.horizontal,
        children: [
          Expanded(child: _columnList("Записи", records.isEmpty, true, net)),
          Expanded(child: _columnList("Ответы", response.isEmpty, false, net)),
        ],
      ),
    );
  }

  List<Widget> _columnRecords(KNetService net) {
    final records = net.records;
    return [
      for (final r in records)
        KUICard(
          height: KDGeometry.header * 2.5,
          paddingArea: EdgeInsets.symmetric(
            horizontal: KDGeometry.baseLSpacing * 1.5,
            vertical: KDGeometry.baseMSpacing,
          ),
          child: Center(
            child: KUIAxisList(
              mainAxisSize: MainAxisSize.min,
              axis: Axis.vertical,
              children: [
                KUIAxisList(
                  axis: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: KUIText(label: r.level, style: KDFontStyle.h3),
                    ),
                    Expanded(
                      child: KUIText(label: r.author, style: KDFontStyle.h3),
                    ),
                    Expanded(
                      child: KUIText(label: r.code, style: KDFontStyle.h3),
                    ),
                  ],
                ),
                KUIText(label: r.message, style: KDFontStyle.p),
              ],
            ),
          ),
        ),
    ];
  }

  List<Widget> _columnResponse(KNetService net) {
    final response = net.responses;
    return [
      for (final r in response)
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
                KUIText(label: r.level, style: KDFontStyle.h3),
                KUIText(label: r.responseMessage, style: KDFontStyle.p),
              ],
            ),
          ),
        ),
    ];
  }

  Widget _columnList(String title, bool empty, bool rOrr, KNetService net) {
    return SizedBox(
      child: KUIAxisList(
        axis: Axis.vertical,
        children: [
          Center(
            child: KUIText(label: title, style: KDFontStyle.h2),
          ),
          Expanded(
            child: empty
                ? Center(
                    child: KUIText(label: "Пусто", style: KDFontStyle.p),
                  )
                : SingleChildScrollView(
                    child: KUIAxisList(
                      axis: Axis.vertical,
                      children: rOrr
                          ? _columnRecords(net)
                          : _columnResponse(net),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
