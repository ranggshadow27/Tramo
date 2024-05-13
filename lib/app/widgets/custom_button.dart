import 'package:flutter/material.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';

Widget myCustomButton({
  required VoidCallback onTap,
  String? title,
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      // elevation: 0,
      backgroundColor: AccentColors.tealColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      fixedSize: const Size(300, 40),
    ),
    onPressed: onTap,
    child: Text(
      title ?? "Submit",
      style: AppFonts.semiBoldText.copyWith(
        // color: AccentColors.blueColor,
        fontSize: 14.0,
      ),
    ),
  );
}
