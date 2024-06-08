import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';

Widget myTextField({
  required String hintText,
  required String labelText,
  errorText,
  required TextEditingController c,
  List<TextInputFormatter>? inputFormatters,
  required void Function(String) onChanged,
}) {
  return TextFormField(
    onChanged: onChanged,
    style: AppFonts.regularText.copyWith(
      fontSize: 14.0,
      color: BaseColors.primaryText,
    ),
    inputFormatters: inputFormatters,
    decoration: InputDecoration(
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AccentColors.redColor, width: 2),
      ),
      fillColor: BaseColors.primaryText.withOpacity(.02),
      filled: true,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AccentColors.tealColor, width: 2),
      ),
      labelStyle: AppFonts.regularText.copyWith(
        color: BaseColors.primaryText.withOpacity(.3),
        fontSize: 14.0,
      ),
      labelText: labelText,
      alignLabelWithHint: true,
      floatingLabelStyle: AppFonts.mediumText.copyWith(color: AccentColors.tealColor),
      errorText: errorText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintText: hintText,
      hintStyle: AppFonts.regularText.copyWith(
        color: BaseColors.primaryText.withOpacity(.3),
      ),
    ),
    controller: c,
    autofocus: true,
  );
}
