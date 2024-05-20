import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';
import '../widgets/custom_button.dart';

Widget confirmResetDataDialog(String groupData, VoidCallback onTap) {
  return Dialog(
    backgroundColor: BaseColors.secondaryBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Container(
      width: 300,
      height: 320,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(
            size: 36,
            FontAwesomeIcons.circleExclamation,
            color: AccentColors.redColor,
          ),
          const SizedBox(height: 10),
          Text(
            "Are you sure?",
            style: AppFonts.boldText.copyWith(
              fontSize: 18.0,
              color: BaseColors.primaryText,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: Center(
              child: Text(
                "This action will reset all sensors traffic data in $groupData group",
                textAlign: TextAlign.center,
                style: AppFonts.regularText.copyWith(
                  fontSize: 14.0,
                  color: BaseColors.primaryText.withOpacity(.6),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 20),
          myCustomButton(
            onTap: onTap,
            color: AccentColors.redColor,
            title: "Reset Data",
          ),
          myCustomButton(
            onTap: () => Get.back(),
            color: BaseColors.secondaryText.withOpacity(.1),
            title: "Cancel",
          ),
        ],
      ),
    ),
  );
}
