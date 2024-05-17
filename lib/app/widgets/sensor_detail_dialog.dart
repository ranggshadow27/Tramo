import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tramo/app/widgets/custom_button.dart';
import 'package:tramo/app/widgets/sensor_detail_tile.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';

Widget sensorDetailDialog(String sensorName, sensorID, prtgIP) {
  return Dialog(
    backgroundColor: BaseColors.secondaryBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: IntrinsicHeight(
      child: Container(
        width: 420,
        height: 320,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Sensor Details",
              textAlign: TextAlign.center,
              style: AppFonts.boldText.copyWith(
                fontSize: 16.0,
                color: BaseColors.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            SensorDetailTile(data: sensorName, title: "| Sensor Name"),
            SensorDetailTile(data: prtgIP, title: "| PRTG IP"),
            SensorDetailTile(data: sensorID, title: "| Sensor ID"),
            const SizedBox(height: 4),
            SizedBox(
              width: 420,
              child: myCustomButton(
                color: BaseColors.primaryText.withOpacity(.1),
                title: "Close",
                onTap: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
