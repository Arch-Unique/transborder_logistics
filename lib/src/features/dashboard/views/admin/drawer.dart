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
import 'package:transborder_logistics/src/utils/constants/string/facilities.dart';

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
            Align(
              alignment: Alignment.center,
              child: Image.asset(Assets.fulllogo, width: 150)),
            Ui.boxHeight(24),
            AppContainer(
              "",
              DashboardMode.values
                  .map(
                    (e) => InkWell(
                      onTap: () {
                        controller.curDashboardIndex.value = e.index;
                        
                          controller.currentModelIndex.value = 0;
                        

                        if (e != DashboardMode.dashboard) {
                          // List items = [];
                          ResourceHistory rh;
                          if (e == DashboardMode.trips) {
                            controller.currentModel = Delivery(createdAt: DateTime.now()).obs;
                        
                            rh = ResourceHistory<Delivery>(
                              items: controller.allCustomerDeliveries,
                            );
                          } else if (e == DashboardMode.users) {
                            controller.currentModel = User().obs;
                            rh = ResourceHistory<User>(
                              items: controller.allCustomers,
                            );
                          } else if (e == DashboardMode.drivers) {
                            controller.currentModel = User().obs;
                            rh = ResourceHistory<User>(
                              items: controller.allDrivers,
                            );
                          } else if (e == DashboardMode.location) {
                            controller.currentModel = StateLocation().obs;
                            rh = ResourceHistory<StateLocation>(
                              items: List.from(
                                States.states.map((e) {
                                  return StateLocation(
                                    name: e,
                                    isActive: e == "Kano" || e == "Kaduna",
                                  );
                                }),
                              ),
                            );
                          } else if (e == DashboardMode.facilities) {
                            controller.currentModel = Location().obs;
                            rh = ResourceHistory<Location>(
                              items: controller.allFacilities,
                            );
                          } else if (e == DashboardMode.pickups) {
                            controller.currentModel = Location().obs;
                            rh = ResourceHistory<Location>(
                              items: controller.allLoadingPoints,
                            );
                          } else if (e == DashboardMode.vehicles) {
                            controller.currentModel = Vehicle().obs;
                            rh = ResourceHistory<Vehicle>(items: controller.allVehicles);
                          } else {
                            rh = ResourceHistory(items: []);
                          }
                          controller.currentModel.refresh();
                          rh.title = e.name;
                          rh.filters = e.filters;
                          rh.onFilter = (v, s) {
                            controller.getFilters(v, s, e.name);
                          };

                          controller.curResourceHistory.value = rh;
                        } else {
                          controller.curResourceHistory.value =
                              ResourceHistory();
                        }
                        controller.curResourceHistory.refresh();
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
            SafeArea(
              child: InkWell(
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
            )
            
          ],
        ),
      ),
    );
  }
}
