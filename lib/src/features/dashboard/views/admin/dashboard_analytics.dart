import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transborder_logistics/src/app/theme/colors.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/global/ui/widgets/text/app_text.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';

class DashboardAnalytics extends StatelessWidget {
  const DashboardAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final c = Get.find<DashboardController>();
      if (c.isLoading.value) {
        return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 700) {
              return Column(
                children: [
                  _TripsBarChart(controller: c),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _DeliveryStatusDonut(controller: c)),
                      const SizedBox(width: 12),
                      Expanded(child: _DriverAvailabilityCard(controller: c)),
                    ],
                  ),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _TripsBarChart(controller: c)),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _DeliveryStatusDonut(controller: c)),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _DriverAvailabilityCard(controller: c)),
              ],
            );
          },
        ),
      );
    });
  }
}

class _TripsBarChart extends StatelessWidget {
  const _TripsBarChart({required this.controller});
  final DashboardController controller;

  List<MapEntry<String, int>> get _monthlyEntries {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final now = DateTime.now();
    final map = <String, int>{};
    for (int i = 5; i >= 0; i--) {
      int m = now.month - i;
      int y = now.year;
      if (m <= 0) { m += 12; y -= 1; }
      map[months[m - 1]] = 0;
    }
    for (final d in controller.allCustomerDeliveries) {
      final key = months[d.createdAt.month - 1];
      if (map.containsKey(key)) map[key] = (map[key] ?? 0) + 1;
    }
    return map.entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _monthlyEntries;
    if (entries.isEmpty) return const SizedBox.shrink();
    final maxVal = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxY = (maxVal < 1 ? 5 : maxVal + 2).toDouble();

    return _AnalyticsCard(
      title: 'Trips — Last 6 Months',
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            minY: 0,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => AppColors.primaryColor,
                getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                  '${entries[gi].key}: ${rod.toY.toInt()}',
                  const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(entries[i].key, style: TextStyle(fontSize: 10, color: AppColors.lightTextColor)),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: maxY > 4 ? (maxY / 4).ceilToDouble() : 1,
                  getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: TextStyle(fontSize: 10, color: AppColors.lightTextColor)),
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(color: AppColors.borderColor, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(entries.length, (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: entries[i].value.toDouble(),
                  color: AppColors.primaryColor,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true, toY: maxY,
                    color: AppColors.primaryColor.withOpacity(0.07),
                  ),
                ),
              ],
            )),
          ),
        ),
      ),
    );
  }
}

class _DeliveryStatusDonut extends StatelessWidget {
  const _DeliveryStatusDonut({required this.controller});
  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final deliveries = controller.allCustomerDeliveries;
    final completed = deliveries.where((d) => d.isDelivered).length;
    final inProgress = deliveries.where((d) => d.hasStarted && d.isNotDelivered).length;
    final newTrips = deliveries.where((d) => d.hasNotStarted && !d.isCanceled).length;
    final cancelled = deliveries.where((d) => d.isCanceled).length;
    final total = completed + inProgress + newTrips + cancelled;

    return _AnalyticsCard(
      title: 'Delivery Status',
      child: SizedBox(
        height: 180,
        child: total == 0
            ? Center(child: AppText.thin('No deliveries yet', color: AppColors.lightTextColor))
            : Row(
                children: [
                  Expanded(
                    child: PieChart(PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: [
                        if (completed > 0) PieChartSectionData(value: completed.toDouble(), color: AppColors.green, title: '', radius: 26),
                        if (inProgress > 0) PieChartSectionData(value: inProgress.toDouble(), color: AppColors.accentColor, title: '', radius: 26),
                        if (newTrips > 0) PieChartSectionData(value: newTrips.toDouble(), color: AppColors.yellow, title: '', radius: 26),
                        if (cancelled > 0) PieChartSectionData(value: cancelled.toDouble(), color: AppColors.primaryColor, title: '', radius: 26),
                      ],
                    )),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Legend(color: AppColors.green, label: 'Done', value: completed),
                      _Legend(color: AppColors.accentColor, label: 'Active', value: inProgress),
                      _Legend(color: AppColors.yellow, label: 'New', value: newTrips),
                      _Legend(color: AppColors.primaryColor, label: 'Cancel', value: cancelled),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, required this.value});
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          AppText.thin('$label ($value)', fontSize: 11),
        ],
      ),
    );
  }
}

class _DriverAvailabilityCard extends StatelessWidget {
  const _DriverAvailabilityCard({required this.controller});
  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final total = controller.allDrivers.length;
    final busy = controller.allUnavailableDrivers.length;
    final available = controller.allAvailableDrivers.length;
    final pct = total == 0 ? 0.0 : available / total;

    return _AnalyticsCard(
      title: 'Driver Availability',
      child: SizedBox(
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90, height: 90,
                  child: CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 10,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText.bold('$available', fontSize: 22),
                    AppText.thin('of $total', fontSize: 11, color: AppColors.lightTextColor),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Chip(color: AppColors.green, label: 'Free', count: available),
                const SizedBox(width: 8),
                _Chip(color: AppColors.primaryColor, label: 'Busy', count: busy),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.color, required this.label, required this.count});
  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: AppText.medium('$count $label', fontSize: 11, color: color),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      border: Border.all(color: AppColors.borderColor),
      radius: 12,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(title, fontSize: 13),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}