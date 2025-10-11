import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tramo/app/modules/home/controllers/home_controller.dart';
import 'package:tramo/app/utils/utils.dart';
import 'package:tramo/app/widgets/add_sensors_button.dart';
import 'package:tramo/app/widgets/chart_widget.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';
import 'info_notification.dart';
import 'update_dialog.dart';

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
    String menuTitle =
        controller.monitoringList[activePage].toString().camelCase!;

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
                  "Traffic Watcher",
                  style: AppFonts.regularText.copyWith(
                    color: BaseColors.secondaryText,
                    fontSize: 14.0,
                  ),
                ),
                const Spacer(),
                AddSensorButton(
                  controller: controller,
                  title: "Create Sensor",
                  index: activePage,
                )
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                var height = MediaQuery.of(context).size.height;
                var width = MediaQuery.of(context).size.width;

                if (controller.sensorsData[menuTitle] == null) {
                  return SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "No Traffic Found!",
                                style: AppFonts.boldText
                                    .copyWith(color: AccentColors.redColor),
                              ),
                              Text(
                                "Traffic will appear direclty after you adding some sensor(s)",
                                style: AppFonts.regularText
                                    .copyWith(color: BaseColors.primaryText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                List sensorId = controller.sensorsData[menuTitle]['Id'] ?? [];
                List sensorAlert =
                    controller.sensorsData[menuTitle]['alert'] ?? [];
                List prtgIP = controller.sensorsData[menuTitle]['prtgIp'] ?? [];

                String firstMonitoringMenu =
                    controller.monitoringList[0].toString().camelCase!;

                return SizedBox(
                  height: maxHeig! < 400 || maxHeig! < 670
                      ? height * .8
                      : constraints.maxWidth < 900
                          ? height * .89
                          : height * .89,
                  width: width * 1,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        GridView.builder(
                          padding: const EdgeInsets.all(20),
                          shrinkWrap: true,
                          addAutomaticKeepAlives: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              controller.sensorsData[menuTitle]['Id'].length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: constraints.maxWidth < 580
                                ? 1
                                : constraints.maxWidth >= 580 &&
                                        constraints.maxWidth < 680
                                    ? 2
                                    : constraints.maxWidth >= 680 &&
                                            constraints.maxWidth < 780
                                        ? 2
                                        : constraints.maxWidth >= 780 &&
                                                constraints.maxWidth < 880
                                            ? 2
                                            : constraints.maxWidth >= 880 &&
                                                    constraints.maxWidth < 1100
                                                ? 3
                                                : constraints.maxWidth >=
                                                            1100 &&
                                                        constraints.maxWidth <
                                                            1200
                                                    ? 3
                                                    : 4,
                            childAspectRatio: constraints.maxWidth < 580
                                ? 2
                                : constraints.maxWidth >= 580 &&
                                        constraints.maxWidth < 680
                                    ? 1.5
                                    : constraints.maxWidth >= 680 &&
                                            constraints.maxWidth < 780
                                        ? 1.5
                                        : constraints.maxWidth >= 780 &&
                                                constraints.maxWidth < 880
                                            ? 1.8
                                            : constraints.maxWidth >= 880 &&
                                                    constraints.maxWidth < 1100
                                                ? 1.7
                                                : constraints.maxWidth >=
                                                            1100 &&
                                                        constraints.maxWidth <
                                                            1200
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
                              prtgIP: prtgIP[index]['ip'].toString(),
                              prtgUser: prtgIP[index]['user'].toString(),
                              prtgPw: prtgIP[index]['pass'].toString(),
                              objectName: controller.activeObjectName.isEmpty
                                  ? "sv_$firstMonitoringMenu"
                                  : controller.activeObjectName.value,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: LoadingAnimationWidget.waveDots(
                                    color: BaseColors.secondaryText
                                        .withOpacity(.5),
                                    size: 26,
                                  ),
                                );
                              }

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
                                        "Sensor ID : ${prtgIP[index]['user']}",
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
                                    chartTitle: prtgIP[index]['custom_name'] !=
                                                "" &&
                                            prtgIP[index]['custom_name'] != null
                                        ? prtgIP[index]['custom_name']
                                        : data['name'],
                                    mainData: data['value'],
                                    timeData: data['time'],
                                    sensorID: sensorId[index].toString(),
                                    prtgIP: prtgIP[index]['ip'].toString(),
                                    lineColor: Utils.hexToColor(
                                        prtgIP[index]['chart_color']),
                                  ),
                                  IconButton(
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (context) {
                                        String pageName = controller
                                            .monitoringList[activePage]
                                            .toString()
                                            .camelCase!;

                                        controller.sensorsIdTC.text = controller
                                            .sensorsData[pageName]['Id'][index]
                                            .toString();

                                        controller.prtgIpTC.text = controller
                                            .sensorsData[pageName]['prtgIp']
                                                [index]['ip']
                                            .toString();

                                        controller.passwordTC.text = controller
                                            .sensorsData[pageName]['prtgIp']
                                                [index]['pass']
                                            .toString();

                                        controller.usernameTC.text = controller
                                            .sensorsData[pageName]['prtgIp']
                                                [index]['user']
                                            .toString();

                                        if (controller.sensorsData[pageName]
                                                        ['prtgIp'][index]
                                                    ['custom_name'] !=
                                                null ||
                                            controller.sensorsData[pageName]
                                                    ['prtgIp'][index]
                                                    ['custom_name']
                                                .toString()
                                                .isNotEmpty) {
                                          controller.customSensorNameTC.text =
                                              controller.sensorsData[pageName]
                                                      ['prtgIp'][index]
                                                      ['custom_name']
                                                  .toString();
                                        } else {
                                          controller.customSensorNameTC.text =
                                              controller.sensorsValue[index]
                                                  ['name'];
                                        }

                                        if (controller.sensorsData[pageName]
                                                    ['prtgIp'][index]
                                                ['chart_color'] !=
                                            null) {
                                          controller.chartColorTC.text =
                                              controller.sensorsData[pageName]
                                                      ['prtgIp'][index]
                                                      ['chart_color']
                                                  .toString();
                                        } else {
                                          controller.chartColorTC.text = "";
                                        }

                                        return updateDialog(
                                            context, index, sensorAlert[index]);
                                      },
                                    ),
                                    iconSize: 12,
                                    splashRadius: 12,
                                    icon: const Icon(
                                      FontAwesomeIcons.gear,
                                      color: BaseColors.secondaryText,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: sensorAlert[index] == true
                                        ? const SizedBox()
                                        : IconButton(
                                            onPressed: () {
                                              controller.disableAlert(index);
                                              showInfoNotification(
                                                context: context,
                                                description:
                                                    "${controller.sensorsValue[index]['name']} Unmuted",
                                              );
                                            },
                                            iconSize: 12,
                                            splashRadius: 12,
                                            icon: const Icon(
                                              FontAwesomeIcons.bellSlash,
                                              color: AccentColors.redColor,
                                            ),
                                          ),
                                  ),
                                  Positioned(
                                    top: 60,
                                    child: IconButton(
                                      onPressed: () => controller.playSound(),
                                      iconSize: 12,
                                      splashRadius: 12,
                                      icon: Icon(
                                        FontAwesomeIcons.soundcloud,
                                        color: BaseColors.navbarBackground
                                            .withOpacity(.5),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
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
