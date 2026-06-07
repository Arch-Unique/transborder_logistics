import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/dashboard_analytics.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/drawer.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/resource_history.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/route_map.dart';
import 'package:transborder_logistics/src/features/dashboard/views/shared.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';
import 'package:transborder_logistics/src/global/ui/widgets/fields/custom_dropdown.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';
import 'package:transborder_logistics/src/src_barrel.dart';

import '../../../../global/model/barrel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final controller = Get.find<DashboardController>();

  double _tripRate() {
    final now = DateTime.now();
    final thisMonth = controller.allCustomerDeliveries
        .where((d) => d.createdAt.month == now.month && d.createdAt.year == now.year)
        .length;
    final lastMonth = controller.allCustomerDeliveries
        .where((d) => d.createdAt.month == now.month - 1 && d.createdAt.year == now.year)
        .length;
    if (lastMonth == 0) return thisMonth > 0 ? 100 : 0;
    return ((thisMonth - lastMonth) / lastMonth * 100);
  }

  double _completionRate() {
    final total = controller.allCustomerDeliveries.length;
    if (total == 0) return 0;
    final done = controller.allCustomerDeliveries.where((d) => d.isDelivered).length;
    return done / total * 100;
  }

  double _driverUtilRate() {
    final total = controller.allDrivers.length;
    if (total == 0) return 0;
    return controller.allUnavailableDrivers.length / total * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Ui.width(context) > 600
          ? _desktopVersion()
          : _mobileVersion();
    });
  }

  Widget _mobileVersion() {
    return RefreshScrollView(
      onExtend: () async {},
      onRefreshed: () async => await controller.initApp(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppContainer('', [
              CustomDropdown.city(
                hint: 'Select Location',
                label: 'Location',
                selectedValue: controller.curLoc.value,
                onChanged: (v) async => await controller.changeLocation(v ?? 'All'),
                cities: ['All', ...controller.allActiveStateLocations.map((e) => e.name)],
                hasBottomPadding: false,
              ),
            ]),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _statCard(DashboardItem.trips, controller.allCustomerDeliveries.length, _tripRate()),
                _statCard(DashboardItem.users, controller.allCustomers.length, 0),
                _statCard(DashboardItem.drivers, controller.allDrivers.length, _driverUtilRate()),
                _statCard(DashboardItem.location, controller.allLocation.length, 0),
                _statCard(DashboardItem.vehicles, controller.allVehicles.length, 0),
              ],
            ),
            const SizedBox(height: 16),
            const DashboardAnalytics(),
            const SizedBox(height: 16),
            AppText.bold('Ongoing Trips', fontSize: 16),
            const SizedBox(height: 8),
            if (controller.allUndeliveredDeliveries.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AppText.thin('No ongoing trips', color: AppColors.lightTextColor),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.allUndeliveredDeliveries.length,
                itemBuilder: (_, i) => DeliveryInfo(controller.allUndeliveredDeliveries[i]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _desktopVersion() {
    return CurvedContainer(
      border: Border.all(color: AppColors.borderColor),
      radius: 0,
      child: Column(
        children: [
          AppDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                AppText.bold('Welcome to Transborder Logistics', fontSize: 22),
                const Spacer(),
                const NotificationBell(),
                const SizedBox(width: 8),
                SizedBox(
                  width: 260,
                  child: AppContainer('', [
                    CustomDropdown.city(
                      hint: 'Select Location',
                      label: 'Location',
                      selectedValue: controller.curLoc.value,
                      onChanged: (v) async => await controller.changeLocation(v ?? 'All'),
                      cities: ['All', ...controller.allActiveStateLocations.map((e) => e.name)],
                      hasBottomPadding: false,
                    ),
                  ]),
                ),
              ],
            ),
          ),
          AppDivider(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(child: _statCard(DashboardItem.trips, controller.allCustomerDeliveries.length, _tripRate(), flex: true)),
                const SizedBox(width: 12),
                Expanded(child: _statCard(DashboardItem.users, controller.allCustomers.length, _completionRate(), flex: true)),
                const SizedBox(width: 12),
                Expanded(child: _statCard(DashboardItem.drivers, controller.allDrivers.length, _driverUtilRate(), flex: true)),
                const SizedBox(width: 12),
                Expanded(child: _statCard(DashboardItem.location, controller.allLocation.length, 0, flex: true)),
                const SizedBox(width: 12),
                Expanded(child: _statCard(DashboardItem.vehicles, controller.allVehicles.length, 0, flex: true)),
              ],
            ),
          ),
          const DashboardAnalytics(),
          AppDivider(),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 380,
                  child: ResourceHistoryPage<Delivery>(
                    'Trips',
                    controller.allUndeliveredDeliveries,
                    hasDrawer: true,
                    filters: [],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: const DeliveryRouteMap(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(DashboardItem dit, int value, double rate, {bool flex = false}) {
    final color = rate > 0
        ? AppColors.green
        : rate == 0
            ? AppColors.yellow
            : AppColors.primaryColor;

    return CurvedContainer(
      height: 90,
      padding: const EdgeInsets.all(12),
      border: Border.all(color: AppColors.borderColor),
      radius: 12,
      child: Column(
        children: [
          Row(
            children: [
              CircleIcon(
                dit.icon,
                radius: 10,
                size: 14,
                ic: AppColors.primaryColor,
                bg: AppColors.primaryColor[50],
              ),
              const SizedBox(width: 4),
              Expanded(child: AppText.medium(dit.name, fontSize: 12)),
              AppIcon(
                rate > 0
                    ? HugeIcons.strokeRoundedArrowUpRight01
                    : rate == 0
                        ? HugeIcons.strokeRoundedArrowLeftRight
                        : HugeIcons.strokeRoundedArrowDownRight01,
                color: color,
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              AppText.thin(value.toCurrencyWS(), fontSize: 18),
              const Spacer(),
              AppText.thin(
                '${rate > 0 ? '+' : ''}${rate.toStringAsFixed(1)}%',
                fontSize: 11,
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

