import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/views/shared.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';
import 'package:transborder_logistics/src/global/ui/widgets/fields/custom_dropdown.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';
import 'package:transborder_logistics/src/src_barrel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return RefreshScrollView(
      onExtend: () async {},
      onRefreshed: () async {
        await controller.initApp();
      },
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            AppContainer("", [
              CustomDropdown.city(
                hint: "Select Location",
                label: "Location",
                selectedValue: controller.curLoc.value,
                onChanged: (v) async {
                  await controller.changeLocation(v ?? "All");
                },
                cities: ["All", "Kano", "Kaduna"],
                hasBottomPadding: false
              ),
            ]),
            Ui.boxHeight(16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                dashboardItem(
                  DashboardItem.trips,
                  controller.allCustomerDeliveries.length,
                  20,
                ),
                dashboardItem(
                  DashboardItem.users,
                  controller.allCustomers.length,
                  0,
                ),
                dashboardItem(
                  DashboardItem.drivers,
                  controller.allDrivers.length,
                  -10,
                ),
                dashboardItem(
                  DashboardItem.location,
                  controller.allLocation.length,
                  0,
                ),
                dashboardItem(
                  DashboardItem.vehicles,
                  controller.allVehicles.length,
                  0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  CurvedContainer dashboardItem(DashboardItem dit, int value, double rate) {
    final color = rate > 0
        ? AppColors.green
        : rate == 0
        ? AppColors.yellow
        : AppColors.primaryColor;
    return CurvedContainer(
      width: (Ui.width(context) - 48) / 2,
      height: 100,
      padding: EdgeInsets.all(12),
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
              Ui.boxWidth(4),
              AppText.medium(dit.name, fontSize: 14),
              Spacer(),
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
          Spacer(),
          Row(
            children: [
              AppText.thin(value.toCurrencyWS(), fontSize: 18),
              Spacer(),
              AppText.thin(
                "${rate > 0 ? "+" : ""}${rate.toStringAsFixed(2)}%",
                fontSize: 12,
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
