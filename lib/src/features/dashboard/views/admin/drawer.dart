import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/explorer.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/resource_history.dart';
import 'package:transborder_logistics/src/features/dashboard/views/shared.dart';
import 'package:transborder_logistics/src/global/model/user.dart';
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
                        controller.curDashboardIndex.value = e.index;
                        if (e != DashboardMode.dashboard) {
                          List items = [];
                          ResourceHistory rh;
                          if (e == DashboardMode.trips) {
                            rh = ResourceHistory<Delivery>(
                              items: controller.allDeliveries,
                            );
                          } else if (e == DashboardMode.users) {
                            rh = ResourceHistory<User>(
                              items: controller.allAdmins,
                            );
                          } else if (e == DashboardMode.drivers) {
                            rh = ResourceHistory<User>(
                              items: controller.allDrivers,
                            );
                          } else if (e == DashboardMode.location) {
                            rh = ResourceHistory<Location>(
                              items: controller.allLocation,
                            );
                          } else if (e == DashboardMode.facilities) {
                            rh = ResourceHistory<Location>(
                              items: controller.allLocation,
                            );
                          } else if (e == DashboardMode.pickups) {
                            rh = ResourceHistory<Location>(
                              items: controller.allLocation,
                            );
                          } else if (e == DashboardMode.vehicles) {
                            rh = ResourceHistory(items: []);
                          } else {
                            rh = ResourceHistory(items: []);
                          }
                          rh.title = e.name;
                          rh.filters = e.filters;
                          rh.onFilter = (v, s) {
                            controller.getFilters(v, s, e.name);
                          };

                          controller.curResourceHistory.value = rh;
                        } else {
                          controller.curResourceHistory.value = ResourceHistory();
                        }
                        Get.back();
                      },
                      child: Obx(() {
                        final txtColor =
                            controller.curDashboardIndex.value == e.index
                            ? AppColors.primaryColor
                            : AppColors.textColor;
                        final iconColor =
                            controller.curDashboardIndex.value == e.index
                            ? AppColors.primaryColor
                            : AppColors.lightTextColor;
                        return Row(
                          children: [
                            AppIcon(e.icon, size: 20, color: iconColor),

                            Ui.boxWidth(8),
                            AppText.medium(
                              e.name,
                              fontSize: 14,
                              color: txtColor,
                            ),
                          ],
                        );
                      }),
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
