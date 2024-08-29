import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:tramo/app/constants/themes/app_colors.dart';
import 'package:tramo/app/constants/themes/font_style.dart';
import 'package:tramo/app/widgets/add_monitoring_button.dart';
import 'package:tramo/app/widgets/logout_button.dart';
import 'package:tramo/app/widgets/menu_list.dart';
import 'package:tramo/app/widgets/monitoring_list.dart';
import 'package:tramo/app/widgets/sensors_page.dart';
import 'package:tramo/app/widgets/setting_button.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // var maxWidth = MediaQuery.sizeOf(context).width;
    var maxHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: BaseColors.navbarBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          RxString maxH = constraints.maxHeight.toString().obs;
          RxDouble maxHeig = constraints.maxHeight.obs;
          RxDouble maxWidth = constraints.maxWidth.obs;

          if (controller.isNavbarShrink.value == true) {
            if (maxWidth < 1000) {
              controller.isNavbarShrink.value = false;
              controller.isWideWindow.value = false;
            } else if (maxWidth >= 1000) {
              controller.isNavbarShrink.value = true;
              controller.isWideWindow.value = true;
            }
          } else {
            if (maxWidth < 1000) {
              controller.isWideWindow.value = false;
            } else if (maxWidth >= 1000) {
              controller.isWideWindow.value = true;
            }
          }

          return Row(
            children: [
              Obx(() {
                int maxGroups = controller.monitoringList.length;

                if (controller.monitoringList.length >= 5) {
                  maxGroups = 5;
                }

                return Container(
                  height: maxHeight,
                  color: BaseColors.primaryBackground,
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
                        title: "Monitoring",
                        isShrink: controller.isNavbarShrink.value,
                        icon: FontAwesomeIcons.layerGroup,
                        iconColor: AccentColors.tealColor,
                      ),
                      SizedBox(
                        height: maxGroups < 1
                            ? 0
                            : maxGroups < 5
                                ? 45.5 * maxGroups
                                : 210,
                        width: controller.isNavbarShrink.value ? 230 : 40,
                        child: ListView.builder(
                          itemCount: controller.monitoringList.length,
                          itemBuilder: (context, index) {
                            if (controller.monitoringList.isEmpty) {
                              return const SizedBox();
                            } else {
                              return Obx(
                                () => MonitoringList(
                                  callback: () {
                                    controller.switchPage(index);
                                  },
                                  containerColor:
                                      controller.activePage.value == index
                                          ? BaseColors.secondaryBackground
                                              .withOpacity(.2)
                                          : Colors.transparent,
                                  title: controller.monitoringList[index],
                                  isShrink: controller.isNavbarShrink.value,
                                  icon: FontAwesomeIcons.circle,
                                  iconColor: controller.autoColor(index),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      AddMonitoringButton(
                        title: 'New Groups',
                        controller: controller,
                      ),
                      const Spacer(),
                      SettingButton(title: "Settings"),
                      const SizedBox(height: 6),
                      LogoutButton(title: "Sign Out"),
                    ],
                  ),
                );
              }),
              GetBuilder<HomeController>(builder: (c) {
                debugPrint("-----------------Reload Page-------------------");
                return Expanded(
                  child: c.isLoading == true
                      ? Center(
                          child: Center(
                            child: LoadingAnimationWidget.hexagonDots(
                              color: BaseColors.secondaryText.withOpacity(.5),
                              size: 30,
                            ),
                          ),
                        )
                      : c.monitoringList.isEmpty
                          ? Center(
                              child: Text(
                                "Sensor List is Empty",
                                style: AppFonts.regularText
                                    .copyWith(color: BaseColors.primaryText),
                              ),
                            )
                          : Center(
                              child: SensorsPage(
                                dat: maxH.value,
                                maxHeig: maxHeig.value,
                                controller: c,
                              ),
                            ),
                );
              }),
            ],
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
                text: "NETLERT",
                style: AppFonts.boldText.copyWith(
                  fontSize: 20.0,
                  color: BaseColors.primaryText,
                ),
                children: [
                  TextSpan(
                    text: "Monitor",
                    style: AppFonts.boldText.copyWith(
                      fontSize: 20.0,
                      color: BaseColors.primaryText,
                    ),
                  ),
                  TextSpan(
                    text: ".",
                    style: AppFonts.boldText.copyWith(
                        fontSize: 40.0, color: const Color(0xFF00E8E8)),
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
                  text: "N",
                  style: AppFonts.boldText.copyWith(
                    fontSize: 24.0,
                    color: BaseColors.primaryText,
                  ),
                  children: [
                    TextSpan(
                      text: "M",
                      style: AppFonts.boldText.copyWith(
                          fontSize: 12.0, color: const Color(0xFF00E8E8)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
}
