import 'package:example/system/system.dart';
import 'package:flutter/material.dart';
import 'package:k_net_service/k_net_service.dart';
import 'package:kui/kui.dart';
import 'package:provider/provider.dart';

class KNetPage extends StatelessWidget {
  const KNetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final net = context.watch<KNetService>();
    final knm = net.metrics?.knet;
    final kncm = knm?.core;
    final colors = context.watch<KDColors>();
    return KUIPage(
      title: "Сеть",
      scroll: false,
      child: KUIAxisList(
        axis: Axis.horizontal,
        children: [
          Expanded(
            child: KUIAxisList(
              axis: Axis.vertical,
              children: [
                // Статусы
                SizedBox(
                  height: KDGeometry.headerL * 1.75,
                  child: KUICard(
                    padding: KDGeometry.baseLSpacing,
                    child: Center(
                      child: KUIAxisList(
                        axis: Axis.vertical,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          rowText(
                            header: "KNet",
                            hStyle: KDFontStyle.h2,
                            value: knm == null ? "Unknown" : knm.status.name,
                            vStyle: KDFontStyle.h3,
                          ),
                          rowText(
                            header: "Core",
                            hStyle: KDFontStyle.h2,
                            value: kncm == null ? "Unknown" : kncm.status.name,
                            vStyle: KDFontStyle.h3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Метрики под статусами
                Expanded(
                  child: KUICard(
                    padding: KDGeometry.baseLSpacing,
                    child: KUIAxisList(
                      axis: Axis.vertical,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        rowText(
                          header: "Ответов",
                          hStyle: KDFontStyle.h2,
                          value: knm == null
                              ? "Unknown"
                              : "${knm.responses.len} / ${knm.responses.cap}",
                          vStyle: KDFontStyle.h3,
                        ),
                        rowText(
                          header: "Пир (Core)",
                          hStyle: KDFontStyle.h2,
                          value: kncm == null
                              ? "Unknown"
                              : kncm.peersCount.toString(),
                          vStyle: KDFontStyle.h3,
                        ),
                        rowText(
                          header: "Entry (Core)",
                          hStyle: KDFontStyle.h2,
                          value: kncm == null
                              ? "Unknown"
                              : "${kncm.entry.len} / ${kncm.entry.cap}",
                          vStyle: KDFontStyle.h3,
                        ),
                        rowText(
                          header: "Exit (Core)",
                          hStyle: KDFontStyle.h2,
                          value: kncm == null
                              ? "Unknown"
                              : "${kncm.exit.len} / ${kncm.exit.cap}",
                          vStyle: KDFontStyle.h3,
                        ),
                        rowText(
                          header: "Курсор",
                          hStyle: KDFontStyle.h2,
                          value: knm == null
                              ? "Unknown"
                              : "${knm.cursor.len} / ${knm.cursor.cap}",
                          vStyle: KDFontStyle.h3,
                        ),
                        rowText(
                          header: "Исполнитель",
                          hStyle: KDFontStyle.h2,
                          value:
                              knm == null || knm.cursor.cursor.executer.isEmpty
                              ? "Unknown"
                              : knm.cursor.cursor.executer,
                          vStyle: KDFontStyle.h3,
                        ),
                        rowText(
                          header: "Cursor LenLoc/LenExt",
                          hStyle: KDFontStyle.h2,
                          value: knm == null
                              ? "Unknown"
                              : "${knm.cursor.cursor.lenLoc} / ${knm.cursor.cursor.lenExt}",
                          vStyle: KDFontStyle.h3,
                        ),
                        rowText(
                          header: "Читателей",
                          hStyle: KDFontStyle.h2,
                          value: knm == null
                              ? "Unknown"
                              : knm.readersCount.toString(),
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
            child: KUIAxisList(
              axis: Axis.vertical,
              children: [
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
                            child: KUIText(
                              label: "Читатели",
                              style: KDFontStyle.h1,
                            ),
                          ),
                        ),
                        Divider(height: 1, color: colors.border.withAlpha(128)),
                        Expanded(
                          child: SingleChildScrollView(
                            child: KUIAxisList(
                              axis: Axis.vertical,
                              children: List.generate(
                                knm?.readers.length ?? 0,
                                (i) {
                                  final reader = knm!.readers[i];
                                  return rowText(
                                    header: reader.id,
                                    hStyle: KDFontStyle.h2,
                                    value: "${reader.len} / ${reader.cap}",
                                    vStyle: KDFontStyle.h3,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: KUICard(
                    paddingArea: EdgeInsets.symmetric(
                      horizontal: KDGeometry.baseLSpacing,
                      vertical: KDGeometry.baseMSpacing,
                    ),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
