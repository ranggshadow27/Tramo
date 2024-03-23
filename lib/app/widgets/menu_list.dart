import 'package:flutter/widgets.dart';
import 'package:tramo/app/constants/themes/font_style.dart';

import '../constants/themes/app_colors.dart';

class MenuList extends StatelessWidget {
  const MenuList({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isShrink,
  });

  final String title;
  final Color iconColor;
  final IconData icon;
  final bool isShrink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: isShrink
          ? Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                ),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: AppFonts.regularText.copyWith(color: BaseColors.primaryText),
                ),
              ],
            )
          : SizedBox(
              width: 40,
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                ),
              ),
            ),
    );
  }
}
