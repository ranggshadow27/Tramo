import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';

class MonitoringList extends StatelessWidget {
  const MonitoringList({
    super.key,
    required this.containerColor,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isShrink,
    this.callback,
  });

  final Color containerColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback? callback;
  final bool isShrink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: containerColor,
        child: InkWell(
          onTap: callback,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: isShrink ? 260 : 40,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: isShrink
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 45),
                      SvgPicture.asset(
                        'assets/icons/square.svg',
                        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 150,
                        child: Text(
                          title,
                          style: AppFonts.semiBoldText.copyWith(color: BaseColors.primaryText),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Tooltip(
                    message: title,
                    child: SvgPicture.asset(
                      'assets/icons/square.svg',
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
