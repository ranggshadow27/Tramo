import 'package:flutter/material.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';

class SensorDetailWidget extends StatelessWidget {
  const SensorDetailWidget({
    super.key,
    required this.chartTitle,
    required this.onTap,
  });

  final String chartTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        chartTitle,
        textAlign: TextAlign.center,
        style: AppFonts.semiBoldText.copyWith(
          color: BaseColors.primaryText,
          fontSize: 12.0,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
