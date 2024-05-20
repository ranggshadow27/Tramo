import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';

Widget loadingDialog() {
  return Dialog(
    backgroundColor: BaseColors.secondaryBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: IntrinsicHeight(
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.hexagonDots(
              color: BaseColors.secondaryText.withOpacity(.5),
              size: 30,
            ),
            const SizedBox(height: 16),
            Text(
              "Importing Profile, Please Wait ..",
              textAlign: TextAlign.center,
              style: AppFonts.regularText.copyWith(
                fontSize: 14.0,
                color: BaseColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
