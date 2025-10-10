import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/resource_history.dart';
import 'package:transborder_logistics/src/features/dashboard/views/shared.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';
import 'package:transborder_logistics/src/src_barrel.dart';

import '../../../../global/services/barrel.dart';
import '../../../../global/ui/ui_barrel.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final appService = Get.find<AppService>();
    final controller = Get.find<DashboardController>();
    return CurvedContainer(
      radius: 0,
      width: Ui.width(context) * 0.75,
      child: Ui.padding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Ui.boxHeight(24),
            AppIcon(Assets.logo, size: 48),
            Ui.boxHeight(48),
            AppContainer(
              "",
              DashboardMode.values
                  .map(
                    (e) => InkWell(
                      onTap: () {
                        if (e != DashboardMode.dashboard) {
                          List items = [];
                          if (e == DashboardMode.trips) {
                            items = controller.allCustomerDeliveries;
                          } else if (e == DashboardMode.users) {
                            items = controller.allCustomers;
                          } else if (e == DashboardMode.drivers) {
                            items = controller.allDrivers;
                          } else if (e == DashboardMode.location) {
                            items = controller.allLocation;
                          } else if (e == DashboardMode.facilities) {
                            items = controller.allLocation;
                          } else if (e == DashboardMode.pickups) {
                            items = controller.allLocation;
                          } else if (e == DashboardMode.vehicles) {
                            items = [];
                          }

                          Get.to(
                            ResourceHistoryPage(
                              e.name,
                              items,
                              hasDrawer: true,
                              filters: e.filters,
                              onFilter: (v, s) {
                                controller.getFilters(v, s, e.name);
                              },
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          AppIcon(e.icon, size: 20),
                          Ui.boxWidth(8),
                          AppText.medium(e.name, fontSize: 14),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              hasBorder: false,
              margin: 36,
            ),
            Spacer(),
            InkWell(
              onTap: () {
                Get.to(
                  SinglePageScaffold(title: "Profile", child: ProfilePage()),
                );
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CurvedImage("", w: 20, h: 20, fit: BoxFit.cover),
                  ),
                  Ui.boxWidth(8),
                  Expanded(
                    child: AppText.medium(
                      appService.currentUser.value.name ?? "N/A",
                      fontSize: 14,
                    ),
                  ),
                  Ui.boxWidth(8),
                  AppIcon(HugeIcons.strokeRoundedMoreHorizontal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
