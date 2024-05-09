import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tramo/app/modules/home/controllers/home_controller.dart';
import 'package:tramo/app/widgets/add_sensors_button.dart';
import 'package:tramo/app/widgets/chart_widget.dart';

import '../constants/themes/app_colors.dart';
import '../constants/themes/font_style.dart';

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.monitoringList[activePage],
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
                  return Center(
                    child: Text(
                      "There is no data to show",
                      style: AppFonts.regularText.copyWith(color: BaseColors.primaryText),
                    ),
                  );
                }

                List sensorId = controller.sensorsData[menuTitle]['Id'] ?? [];
                List sensorIp = controller.sensorsData[menuTitle]['prtgIp'] ?? [];

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
                      crossAxisCount: constraints.maxWidth <= 720 ? 2 : 3,
                      childAspectRatio: constraints.maxWidth <= 720 ? 1.3 : 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) => FutureBuilder(
                      future: controller.fetchApiData(
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
                            child: Text("EROR COK : ${snapshot.error}"),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data == null) {
                          return Center(
                            child: Text(
                              "Sensor Id : ${sensorId[index]} \nTerjadi Kesalahan Euy! Sensor tidak ada",
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
                                onPressed: () => controller.notificationAlert(),
                                iconSize: 12,
                                splashRadius: 12,
                                icon: const Icon(
                                  FontAwesomeIcons.soundcloud,
                                  color: AccentColors.tealColor,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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

  Widget updateDialog(BuildContext context, int index) {
    return Dialog(
      child: IntrinsicWidth(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .5,
          child: Column(
            children: [
              const Text("Please insert the Sensor Id from PRTG"),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: controller.sensorsIdTC,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(height: 20),
              const Text("Please insert the PRTG IP"),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: controller.prtgIpTC,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await controller.updateSensor(index);
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
