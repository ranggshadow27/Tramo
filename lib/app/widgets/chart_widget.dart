import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constants/themes/app_colors.dart';

class ChartWidget extends StatelessWidget {
  final GetxController controller;

  String? chartTitle;
  List mainData;
  List timeData;

  ChartWidget({
    required this.controller,
    this.chartTitle,
    required this.mainData,
    required this.timeData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    int latestData = mainData[mainData.length - 1];

    var maxVal = mainData.reduce(
      (previousValue, element) =>
          previousValue > element ? previousValue.toDouble() : element.toDouble(),
    );

    double currentThresold = maxVal * .75;

    if (maxVal <= 20000) {
      maxVal += 2000;
    } else if (maxVal >= 800000) {
      maxVal += 200000;
    } else {
      maxVal += 100000;
    }

    if (mainData.isEmpty) {
      return const CircularProgressIndicator();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: BaseColors.navbarBackground.withOpacity(.5),
      ),
      height: 300,
      padding: const EdgeInsets.only(top: 20, bottom: 20, right: 30, left: 24),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.cyan.withOpacity(.2),
              strokeWidth: .3,
            ),
            drawVerticalLine: true,
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.cyan.withOpacity(.2),
              strokeWidth: .3,
            ),
            horizontalInterval: maxVal >= 800000
                ? 200000
                : maxVal <= 350000
                    ? maxVal <= 20000
                        ? 2000
                        : 50000
                    : 100000,
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(
              axisNameSize: 23,
              axisNameWidget: SizedBox(
                width: MediaQuery.of(context).size.width * .2,
                child: SizedBox(
                  width: 200,
                  child: Text(
                    "$chartTitle (${mainData.length})",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: BaseColors.primaryText,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
            rightTitles: AxisTitles(),
            leftTitles: AxisTitles(
              axisNameSize: 15,
              axisNameWidget: const Text(
                "Total Traffic (Kbps)",
                style: TextStyle(
                  fontSize: 8.0,
                  color: BaseColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxVal >= 800000
                    ? 200000
                    : maxVal <= 350000 && maxVal > 20000
                        ? 50000
                        : maxVal <= 20000
                            ? 2000
                            : 100000,
                getTitlesWidget: (value, meta) {
                  for (var i = 0; i < mainData.length; i++) {
                    if (value == 0) {
                      return const SizedBox();
                    }

                    if (value == maxVal) {
                      return const SizedBox();
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      "${(value).toInt() ~/ 1000}K",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 215, 215, 215),
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                interval: 1,
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  TextStyle style = const TextStyle(
                    fontSize: 10.0,
                    color: Color.fromARGB(255, 215, 215, 215),
                    fontWeight: FontWeight.bold,
                  );

                  for (var i = 0; i < timeData.length; i++) {
                    if (value.toInt() == 0 && timeData.length < 10) {
                      return const SizedBox();
                    }

                    if (value.toInt() == i && int.parse(timeData[i].split(":")[1]) % 5 != 0) {
                      return const SizedBox();
                    }

                    if (value.toInt() == 1 && timeData.length < 10) {
                      return RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          timeData[i],
                          style: style,
                        ),
                      );
                    }

                    if (value.toInt() == i && int.parse(timeData[i].split(":")[1]) % 5 == 0) {
                      return RotatedBox(
                        quarterTurns: 3,
                        child: Text(timeData[i], style: style),
                      );
                    }

                    if (value.toInt() == i) {
                      return RotatedBox(
                        quarterTurns: 3,
                        child: Text(timeData[i], style: style),
                      );
                    }
                  }

                  return Text(value.toString());
                },
              ),
            ),
          ),
          maxY: maxVal.toDouble(),
          minY: 0,
          maxX: mainData.length.toDouble() - 1,
          minX: 0,
          backgroundColor: BaseColors.primaryBackground,
          clipData: FlClipData.all(),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Colors.cyan.withOpacity(.2),
              width: 1,
            ),
          ),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Color.fromARGB(255, 33, 35, 35).withOpacity(.7),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((e) {
                  final flSpot = e;

                  return LineTooltipItem(
                    "- Time: ${timeData[flSpot.x.toInt()]} WIB\n- Traffic: ${NumberFormat.decimalPattern().format(flSpot.y.toInt())} Kbps",
                    const TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.left,
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              dotData: FlDotData(show: false),
              spots: List.generate(
                mainData.length,
                (index) => FlSpot(index.toDouble(), mainData[index].toDouble()),
              ),
              color: latestData >= currentThresold
                  ? AccentColors.tealColor
                  : latestData < currentThresold && latestData > currentThresold / 2
                      ? AccentColors.yellowColor
                      : AccentColors.maroonColor,
              isCurved: true,
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: latestData >= currentThresold
                      ? [
                          AccentColors.tealColor.withOpacity(.5),
                          AccentColors.tealColor.withOpacity(.25),
                          AccentColors.tealColor.withOpacity(.05),
                          AccentColors.tealColor.withOpacity(0),
                        ]
                      : latestData < currentThresold && latestData > currentThresold / 2
                          ? [
                              AccentColors.yellowColor.withOpacity(.5),
                              AccentColors.yellowColor.withOpacity(.25),
                              AccentColors.yellowColor.withOpacity(0.05),
                              AccentColors.yellowColor.withOpacity(0),
                            ]
                          : [
                              AccentColors.maroonColor.withOpacity(.5),
                              AccentColors.maroonColor.withOpacity(.25),
                              AccentColors.maroonColor.withOpacity(.05),
                              AccentColors.maroonColor.withOpacity(0),
                            ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
