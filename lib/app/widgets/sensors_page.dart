import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tramo/app/modules/home/controllers/home_controller.dart';
import 'package:tramo/app/widgets/add_sensors_button.dart';
import 'package:tramo/app/widgets/chart_widget.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';
import 'custom_button.dart';
import 'custom_textfield.dart';

class SensorsPage extends StatelessWidget {
  const SensorsPage({
    super.key,
    required this.controller,
    this.dat,
    this.maxHeig,
  });

  final String? dat;
  final double? maxHeig;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    int activePage = controller.activePage.value;
    String menuTitle = controller.monitoringList[activePage].toString().camelCase!;

    // Map<String, dynamic> data = sensorsData[menuTitle] ?? {'kosong': 'kosong'};
    // debugPrint("Ini adalah datanya ==========> $data");

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  controller.monitoringList[activePage],
                  style: AppFonts.boldText.copyWith(
                    color: BaseColors.primaryText,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Monitoring",
                  style: AppFonts.regularText.copyWith(
                    color: BaseColors.secondaryText,
                    fontSize: 14.0,
                  ),
                ),
                const Spacer(),
                AddSensorButton(
                  controller: controller,
                  title: "Add Sensor",
                  index: activePage,
                )
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              var height = MediaQuery.of(context).size.height;
              var width = MediaQuery.of(context).size.width;

              if (controller.sensorsData[menuTitle] == null) {
                return Center(
                  child: Text(
                    "There is no data to show",
                    style: AppFonts.regularText.copyWith(color: BaseColors.primaryText),
                  ),
                );
              }

              List sensorId = controller.sensorsData[menuTitle]['Id'] ?? [];
              List sensorAlert = controller.sensorsData[menuTitle]['alert'] ?? [];

              String firstMonitoringMenu = controller.monitoringList[0].toString().camelCase!;

              return SizedBox(
                height: maxHeig! < 400 || maxHeig! < 670
                    ? height * .8
                    : constraints.maxWidth < 900
                        ? height * .89
                        : height * .89,
                width: width * 1,
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: controller.sensorsData[menuTitle]['Id'].length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth < 580
                        ? 1
                        : constraints.maxWidth >= 580 && constraints.maxWidth < 680
                            ? 2
                            : constraints.maxWidth >= 680 && constraints.maxWidth < 780
                                ? 2
                                : constraints.maxWidth >= 780 && constraints.maxWidth < 880
                                    ? 2
                                    : constraints.maxWidth >= 880 && constraints.maxWidth < 1100
                                        ? 3
                                        : constraints.maxWidth >= 1100 &&
                                                constraints.maxWidth < 1200
                                            ? 3
                                            : 4,
                    childAspectRatio: constraints.maxWidth < 580
                        ? 2
                        : constraints.maxWidth >= 580 && constraints.maxWidth < 680
                            ? 1.5
                            : constraints.maxWidth >= 680 && constraints.maxWidth < 780
                                ? 1.5
                                : constraints.maxWidth >= 780 && constraints.maxWidth < 880
                                    ? 1.8
                                    : constraints.maxWidth >= 880 && constraints.maxWidth < 1100
                                        ? 1.7
                                        : constraints.maxWidth >= 1100 &&
                                                constraints.maxWidth < 1200
                                            ? 1.7
                                            : 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) => FutureBuilder(
                    future: controller.fetchApiData(
                      context: context,
                      index: index,
                      key: sensorId[index].toString(),
                      objectName: controller.activeObjectName.isEmpty
                          ? "sv_$firstMonitoringMenu"
                          : controller.activeObjectName.value,
                    ),
                    builder: (context, snapshot) {
                      // if (snapshot.connectionState == ConnectionState.waiting) {
                      //   return const Center(
                      //     child: CircularProgressIndicator(),
                      //   );
                      // }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Snapshot Err : ${snapshot.error}",
                            style: AppFonts.regularText.copyWith(
                              fontSize: 12.0,
                              color: BaseColors.primaryText,
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return Container(
                          width: Get.width,
                          height: Get.height,
                          decoration: BoxDecoration(
                            color: BaseColors.secondaryBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Spacer(),
                              Text(
                                "Sensor ID : ${sensorId[index]}",
                                style: AppFonts.regularText.copyWith(
                                  fontSize: 12.0,
                                  color: BaseColors.primaryText,
                                ),
                              ),
                              Text(
                                "404",
                                style: AppFonts.boldText.copyWith(
                                  fontSize: 60.0,
                                  color: AccentColors.redColor,
                                ),
                              ),
                              Text(
                                "Failed to Get Response from Server",
                                style: AppFonts.regularText.copyWith(
                                  fontSize: 12.0,
                                  color: AccentColors.redColor,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        );
                      }

                      Map<String, dynamic> data = snapshot.data;

                      return Stack(
                        children: [
                          ChartWidget(
                            controller: controller,
                            chartTitle: data['name'],
                            mainData: data['value'],
                            timeData: data['time'],
                          ),
                          IconButton.outlined(
                            onPressed: () => showDialog(
                              context: context,
                              builder: (context) {
                                String pageName =
                                    controller.monitoringList[activePage].toString().camelCase!;

                                controller.sensorsIdTC.text =
                                    controller.sensorsData[pageName]['Id'][index].toString();

                                controller.prtgIpTC.text =
                                    controller.sensorsData[pageName]['prtgIp'][index].toString();

                                return updateDialog(context, index);
                              },
                            ),
                            iconSize: 12,
                            splashRadius: 12,
                            icon: const Icon(
                              FontAwesomeIcons.penToSquare,
                              color: AccentColors.tealColor,
                            ),
                          ),
                          Positioned(
                            top: 30,
                            child: IconButton.outlined(
                              onPressed: () => controller.disableAlert(index),
                              iconSize: 12,
                              splashRadius: 12,
                              icon: Icon(
                                sensorAlert[index] == true
                                    ? FontAwesomeIcons.solidBell
                                    : FontAwesomeIcons.bellSlash,
                                color: AccentColors.tealColor,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton.outlined(
                              onPressed: () => controller.confirmDelete(index, context),
                              iconSize: 12,
                              splashRadius: 12,
                              icon: const Icon(
                                FontAwesomeIcons.xmark,
                                color: AccentColors.redColor,
                              ),
                            ),
                          ),
                          // Positioned(
                          //   top: 60,
                          //   child: IconButton.outlined(
                          //     onPressed: () => controller.playSound(),
                          //     iconSize: 12,
                          //     splashRadius: 12,
                          //     icon: const Icon(
                          //       FontAwesomeIcons.soundcloud,
                          //       color: AccentColors.tealColor,
                          //     ),
                          //   ),
                          // ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget updateDialog(BuildContext context, int index) {
    return Dialog(
      backgroundColor: BaseColors.primaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: IntrinsicHeight(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          width: 300,
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              GetBuilder<HomeController>(
                builder: (controller) => myTextField(
                  hintText: "ex. 25609",
                  c: controller.sensorsIdTC,
                  errorText: controller.groupNameObx,
                  labelText: "Insert the Sensor ID from PRTG",
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(height: 20),
              GetBuilder<HomeController>(
                builder: (controller) => myTextField(
                  hintText: "ex. 202.55.175.235:8443",
                  c: controller.prtgIpTC,
                  errorText: controller.errNameObx,
                  labelText: "Insert the PRTG IP",
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(height: 20),
              myCustomButton(
                onTap: () async {
                  await controller.updateSensor(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
