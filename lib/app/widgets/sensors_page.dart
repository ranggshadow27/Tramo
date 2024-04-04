import 'package:flutter/material.dart';
import 'package:tramo/app/modules/home/controllers/home_controller.dart';
import 'package:tramo/app/widgets/add_sensors_button.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';

class SensorsPage extends StatelessWidget {
  const SensorsPage({
    super.key,
    required this.dataMonit,
    required this.sensorsData,
    required this.index,
    required this.controller,
    this.dat,
    this.maxHeig,
  });

  final List dataMonit;
  final Map sensorsData;
  final int index;
  final String? dat;
  final double? maxHeig;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    String menuTitle = dataMonit[index];
    Map<String, dynamic> data = sensorsData[menuTitle] ?? {};

    debugPrint("Ini adalah datanya ==========> $data");

    return Scaffold(
      backgroundColor: BaseColors.primaryBackground,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
                  menuTitle,
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
                const Spacer(),
                AddSensorButton(
                  controller: controller,
                  title: "Add Sensors",
                  index: index,
                )
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                var height = MediaQuery.of(context).size.height;
                var width = MediaQuery.of(context).size.width;

                if (sensorsData[menuTitle] == null) {
                  return Center(
                    child: Text(
                      "There is no data to show",
                      style: AppFonts.regularText.copyWith(color: BaseColors.primaryText),
                    ),
                  );
                }

                return SizedBox(
                  height: maxHeig! < 400 || maxHeig! < 670
                      ? height * .8
                      : constraints.maxWidth < 900
                          ? height * .89
                          : height * .89,
                  width: width * 1,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: sensorsData[menuTitle]['Id'].length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth <= 720 ? 2 : 3,
                      childAspectRatio: constraints.maxWidth <= 720 ? 1.5 : 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AccentColors.tealColor,
                      ),
                      child: Center(
                        child: Text(
                          "Sensor Id : ${sensorsData[menuTitle]['Id'][index]} \n PRTG IP : ${sensorsData[menuTitle]['prtgIp'][index]}",
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
