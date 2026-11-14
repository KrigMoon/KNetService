import 'package:flutter/material.dart';
import 'package:kui/kui.dart';

Widget rowText({
  required String header,
  required String value,
  required KDFontStyle hStyle,
  required KDFontStyle vStyle,
}) {
  return KUIAxisList(
    axis: Axis.horizontal,
    children: [
      Expanded(
        child: KUIText(label: header, style: hStyle),
      ),
      Expanded(
        child: KUIText(textAlign: TextAlign.end, label: value, style: vStyle),
      ),
    ],
  );
}
