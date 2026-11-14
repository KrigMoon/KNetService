import 'package:example/system/system.dart';
import 'package:flutter/material.dart';
import 'package:k_net_service/k_net_service.dart';
import 'package:kui/kui.dart';
import 'package:provider/provider.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final net = context.watch<KNetService>();
    final kjm = net.metrics?.kjournal;
    final colors = context.watch<KDColors>();
    return KUIPage(
      title: "Журнал",
      scroll: false,
      child: KUIAxisList(
        axis: Axis.horizontal,
        children: [
          Expanded(
            child: KUIAxisList(
              axis: Axis.vertical,
              children: [
                SizedBox(
                  height: KDGeometry.headerL * 1,
                  child: KUICard(
                    padding: KDGeometry.baseLSpacing,
                    child: Center(
                      child: KUIAxisList(
                        axis: Axis.vertical,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          rowText(
                            header: "Статус",
                            hStyle: KDFontStyle.h2,
                            value: kjm == null ? "Unknown" : kjm.status.name,
                            vStyle: KDFontStyle.h3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: KUICard(
                    padding: KDGeometry.baseLSpacing,
                    child: KUIAxisList(
                      axis: Axis.vertical,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        rowText(
                          header: "Писателей",
                          hStyle: KDFontStyle.h2,
                          value: kjm == null
                              ? "Unknown"
                              : kjm.writers.toString(),
                          vStyle: KDFontStyle.h3,
                        ),
                        rowText(
                          header: "Читателей",
                          hStyle: KDFontStyle.h2,
                          value: kjm == null
                              ? "Unknown"
                              : kjm.readers.toString(),
                          vStyle: KDFontStyle.h3,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: KUICard(
              paddingArea: EdgeInsets.symmetric(
                horizontal: KDGeometry.baseLSpacing,
                vertical: KDGeometry.baseMSpacing,
              ),
              child: KUIAxisList(
                axis: Axis.vertical,
                mainAxisSize: MainAxisSize.min,
                spacing: 0,
                children: [
                  SizedBox(
                    height: KDGeometry.header,
                    child: Align(
                      alignment: AlignmentGeometry.centerLeft,
                      child: KUIText(label: "Читатели", style: KDFontStyle.h1),
                    ),
                  ),
                  Divider(height: 1, color: colors.border.withAlpha(128)),
                  Expanded(
                    child: SingleChildScrollView(
                      child: KUIAxisList(
                        axis: Axis.vertical,
                        children: List.generate(kjm?.readersFill.length ?? 0, (
                          i,
                        ) {
                          final entry = kjm!.readersFill.entries.elementAt(i);
                          return rowText(
                            header: entry.key,
                            hStyle: KDFontStyle.h2,
                            value: "${entry.value.len} / ${entry.value.cap}",
                            vStyle: KDFontStyle.h3,
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
