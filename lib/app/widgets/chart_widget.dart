import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChartWidget extends StatelessWidget {
  final GetxController controller;

  String? chartTitle;
  RxList mainData;
  RxList timeData;
  RxInt latestData;
  int currentThresold;

  ChartWidget({
    required this.controller,
    this.chartTitle,
    required this.mainData,
    required this.timeData,
    required this.latestData,
    required this.currentThresold,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => mainData.isEmpty
          ? const CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 21, 21, 22),
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
                        strokeWidth: 1,
                      ),
                      drawVerticalLine: true,
                      getDrawingVerticalLine: (value) => FlLine(
                        color: Colors.cyan.withOpacity(.2),
                        strokeWidth: 1,
                      ),
                      horizontalInterval: 50000,
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: AxisTitles(
                        axisNameSize: 30,
                        axisNameWidget: Text(
                          chartTitle ?? "no data",
                          style: const TextStyle(
                              fontSize: 12.0,
                              color: Color.fromARGB(255, 233, 233, 233),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      rightTitles: AxisTitles(),
                      leftTitles: AxisTitles(
                        axisNameSize: 12,
                        axisNameWidget: const Text(
                          "Traffic Total (Kbps)",
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Color.fromARGB(255, 215, 215, 215),
                          ),
                        ),
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 50000,
                          getTitlesWidget: (value, meta) {
                            var maxVal = mainData.reduce(
                                  (previousValue, element) => previousValue > element
                                      ? previousValue.toDouble()
                                      : element.toDouble(),
                                ) +
                                50000;

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
                                  fontSize: 12.0,
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
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            TextStyle style = const TextStyle(
                              fontSize: 12.0,
                              color: Color.fromARGB(255, 215, 215, 215),
                              fontWeight: FontWeight.bold,
                            );

                            for (var i = 0; i < timeData.length; i++) {
                              if (value.toInt() == 0 && timeData.length < 10) {
                                return const SizedBox();
                              }

                              if (value.toInt() == i &&
                                  int.parse(timeData[i].split(":")[1]) % 5 != 0) {
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

                              if (value.toInt() == i &&
                                  int.parse(timeData[i].split(":")[1]) % 5 == 0) {
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
                    maxY: mainData.reduce(
                          (previousValue, element) => previousValue > element
                              ? previousValue.toDouble()
                              : element.toDouble(),
                        ) +
                        50000.toDouble(),
                    minY: 0,
                    maxX: mainData.length.toDouble() - 1,
                    minX: 0,
                    backgroundColor: Color.fromARGB(255, 21, 21, 22),
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
                        color: latestData.value >= currentThresold
                            ? const Color.fromARGB(255, 18, 216, 219)
                            : latestData.value < currentThresold && latestData.value > 4000
                                ? const Color.fromARGB(255, 213, 203, 15)
                                : const Color.fromARGB(255, 215, 0, 0),
                        isCurved: true,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: latestData.value >= currentThresold
                                ? [
                                    const Color.fromARGB(255, 18, 216, 219).withOpacity(.5),
                                    const Color.fromARGB(255, 18, 216, 219).withOpacity(.25),
                                    const Color.fromARGB(255, 18, 216, 219).withOpacity(.05),
                                    const Color.fromARGB(255, 18, 216, 219).withOpacity(0),
                                  ]
                                : latestData.value < currentThresold &&
                                        latestData.value > currentThresold / 2
                                    ? [
                                        const Color.fromARGB(255, 213, 203, 15).withOpacity(.5),
                                        const Color.fromARGB(255, 213, 203, 15).withOpacity(.25),
                                        const Color.fromARGB(255, 213, 203, 15).withOpacity(0.05),
                                        const Color.fromARGB(255, 213, 203, 15).withOpacity(0),
                                      ]
                                    : [
                                        const Color.fromARGB(255, 215, 0, 0).withOpacity(.5),
                                        const Color.fromARGB(255, 215, 0, 0).withOpacity(.25),
                                        const Color.fromARGB(255, 215, 0, 0).withOpacity(.05),
                                        const Color.fromARGB(255, 215, 0, 0).withOpacity(0),
                                      ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                  curve: Curves.bounceIn,
                  duration: const Duration(milliseconds: 200),
                ),
              ),
            ),
    );
  }
}
