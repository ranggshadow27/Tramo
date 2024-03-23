import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:tramo/app/constants/themes/app_colors.dart';
import 'package:tramo/app/constants/themes/font_style.dart';

import '../controllers/monitoring_controller.dart';

class MonitoringView extends GetView<MonitoringController> {
  const MonitoringView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: BaseColors.primaryBackground,
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: BaseColors.secondaryText.withOpacity(.25),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Traffic Backhaul LC 1",
                    style: AppFonts.boldText.copyWith(
                      color: BaseColors.primaryText,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Monitoring",
                    style: AppFonts.regularText.copyWith(
                      color: BaseColors.secondaryText,
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            )
          ],
        ));
  }
}
