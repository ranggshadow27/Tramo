import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:tramo/app/constants/themes/app_colors.dart';
import 'package:tramo/app/constants/themes/font_style.dart';
import 'package:tramo/app/widgets/add_monitoring_button.dart';
import 'package:tramo/app/widgets/menu_list.dart';
import 'package:tramo/app/widgets/monitoring_list.dart';
import 'package:tramo/app/widgets/sensors_page.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var maxWidth = MediaQuery.sizeOf(context).width;
    var maxHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: BaseColors.primaryBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          RxString maxH = constraints.maxHeight.toString().obs;
          RxDouble maxHeig = constraints.maxHeight.obs;

          if (constraints.maxWidth <= 800) {
            controller.isNavbarShrink.value = false;
          } else if (constraints.maxWidth <= 1000) {
            controller.isWideWindow.value = false;
          } else {
            controller.isWideWindow.value = true;
            controller.isNavbarShrink.value = true;
          }

          return Obx(
            () {
              return Row(
                children: [
                  Container(
                    height: maxHeight,
                    color: BaseColors.navbarBackground,
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: controller.isNavbarShrink.value ? 32 : 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        tramoLogo(
                          controller: controller,
                          width: constraints.maxWidth,
                          isShrink: controller.isNavbarShrink.value,
                        ),
                        const SizedBox(height: 24),
                        MenuList(
                          title: "Dashboard",
                          isShrink: controller.isNavbarShrink.value,
                          icon: FontAwesomeIcons.qrcode,
                          iconColor: AccentColors.tealColor,
                        ),
                        MenuList(
                          title: "Monitoring",
                          isShrink: controller.isNavbarShrink.value,
                          icon: FontAwesomeIcons.chartSimple,
                          iconColor: AccentColors.redColor,
                        ),
                        SizedBox(
                          width: controller.isNavbarShrink.value ? 230 : 40,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.monitoringList.length,
                            itemBuilder: (context, index) {
                              if (controller.monitoringList.isEmpty) {
                                return const SizedBox();
                              } else {
                                return Obx(() {
                                  return MonitoringList(
                                    callback: () {
                                      controller.switchPage(index);
                                    },
                                    containerColor: controller.activePage.value == index
                                        ? BaseColors.secondaryBackground
                                        : Colors.transparent,
                                    title: controller.monitoringList[index],
                                    isShrink: controller.isNavbarShrink.value,
                                    icon: FontAwesomeIcons.circle,
                                    iconColor: controller.autoColor(index),
                                  );
                                });
                              }
                            },
                          ),
                        ),
                        const Divider(),
                        AddMonitoringButton(
                          title: 'Add New Group',
                          controller: controller,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Expanded(
                    child: controller.monitoringList.isEmpty
                        ? Center(
                            child: Text(
                              "There is no data to show",
                              style: AppFonts.regularText.copyWith(color: BaseColors.primaryText),
                            ),
                          )
                        : Center(
                            child: GetBuilder<HomeController>(
                              builder: (c) {
                                return SensorsPage(
                                  sensorsData: c.sensorsData,
                                  dataMonit: c.monitoringList,
                                  index: c.activePage.value,
                                  dat: maxH.value,
                                  maxHeig: maxHeig.value,
                                  controller: c,
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

Widget tramoLogo(
    {required final HomeController controller,
    required final bool isShrink,
    required double width}) {
  return isShrink
      ? InkWell(
          onTap: width > 600
              ? () {
                  controller.switchNavbarType();
                }
              : null,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                text: "Tramo",
                style: AppFonts.boldText.copyWith(
                  fontSize: 24.0,
                  color: BaseColors.primaryText,
                ),
                children: [
                  TextSpan(
                    text: ".",
                    style:
                        AppFonts.boldText.copyWith(fontSize: 40.0, color: const Color(0xFF00E8E8)),
                  ),
                ],
              ),
            ),
          ),
        )
      : InkWell(
          onTap: width > 600
              ? () {
                  controller.switchNavbarType();
                }
              : null,
          child: SizedBox(
            width: 40,
            child: Center(
              child: Text.rich(
                TextSpan(
                  text: "T",
                  style: AppFonts.boldText.copyWith(
                    fontSize: 24.0,
                    color: BaseColors.primaryText,
                  ),
                  children: [
                    TextSpan(
                      text: ".",
                      style: AppFonts.boldText
                          .copyWith(fontSize: 40.0, color: const Color(0xFF00E8E8)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
}
