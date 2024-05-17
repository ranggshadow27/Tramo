import 'package:flutter/material.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';

class SensorDetailTile extends StatelessWidget {
  const SensorDetailTile({
    super.key,
    required this.title,
    required this.data,
  });

  final String title;
  final String data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: AppFonts.regularText.copyWith(
            fontSize: 14.0,
            color: BaseColors.primaryText.withOpacity(.6),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          child: Text(
            data,
            style: AppFonts.regularText.copyWith(
              fontSize: 14.0,
              color: BaseColors.primaryText,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
