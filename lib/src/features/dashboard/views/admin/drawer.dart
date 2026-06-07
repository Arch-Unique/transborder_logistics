import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/resource_history.dart';
import 'package:transborder_logistics/src/features/dashboard/views/shared.dart';
import 'package:transborder_logistics/src/global/model/user.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';
import 'package:transborder_logistics/src/src_barrel.dart';
import 'package:transborder_logistics/src/features/dashboard/models/var_data.dart';

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
              child: Image.asset(Assets.fulllogo, width: 150),
            ),
            Ui.boxHeight(24),
            Align(alignment: Alignment.center, child: ToogleDarkModeWidget()),
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
                            controller.currentModel = Delivery(
                              createdAt: DateTime.now(),
                            ).obs;

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
                              items: controller.allStateLocations,
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
                            rh = ResourceHistory<Vehicle>(
                              items: controller.allVehicles,
                            );
                          } else if (e == DashboardMode.varRecords) {
                            controller.currentModel = VarRecord().obs;
                            rh = ResourceHistory<VarRecord>(
                              items: controller.allVarRecords,
                            );
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
            ),
          ],
        ),
      ),
    );
  }
}

class ToogleDarkModeWidget extends StatelessWidget {
  const ToogleDarkModeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppService>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        
        AppIcon(IconsaxPlusBold.sun_1),
        Ui.boxWidth(8),
        Obx(
           () {
            return Switch(
              activeTrackColor: AppColors.primaryColor,
              activeThumbColor: AppColors.white,
              value: controller.isDarkMode.value,
              onChanged: (v) async {
                await controller.toggleDarkMode();
              },
            );
          }
        ),
        Ui.boxWidth(16),
        AppIcon(IconsaxPlusBold.moon,),
      ],
    );
  }
}
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardController>();
    return Obx(() {
      final pending = c.allCustomerDeliveries.where((d) => d.hasNotStarted && !d.isCanceled).length;
      return InkWell(
        onTap: () => Get.bottomSheet(
          const _NotificationsSheet(),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AppIcon(HugeIcons.strokeRoundedNotification01),
              if (pending > 0)
                Positioned(
                  top: -4, right: -4,
                  child: Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryColorBackground, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        pending > 9 ? '9+' : '$pending',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardController>();
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.primaryColorBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    AppText.bold('Notifications', fontSize: 18),
                    const Spacer(),
                    Obx(() {
                      final count = c.allCustomerDeliveries.where((d) => d.hasNotStarted && !d.isCanceled).length;
                      if (count == 0) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(12)),
                        child: AppText.medium('$count New', fontSize: 11, color: Colors.white),
                      );
                    }),
                  ],
                ),
              ),
              AppDivider(),
              Expanded(
                child: Obx(() {
                  final newTrips = c.allCustomerDeliveries.where((d) => d.hasNotStarted && !d.isCanceled).toList();
                  final inProgress = c.allCustomerDeliveries.where((d) => d.hasStarted && d.isNotDelivered).toList();
                  final completed = c.allCustomerDeliveries.where((d) => d.isDelivered).toList();

                  if (newTrips.isEmpty && inProgress.isEmpty && completed.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(HugeIcons.strokeRoundedNotification01, size: 48, color: AppColors.lightTextColor),
                          const SizedBox(height: 12),
                          AppText.thin('No notifications', color: AppColors.lightTextColor),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    controller: scrollController,
                    children: [
                      if (newTrips.isNotEmpty) ...[
                        _NotifSection(title: 'New Trips', color: AppColors.yellow, items: newTrips.map((d) => _NotifItem(
                          icon: HugeIcons.strokeRoundedAlertCircle,
                          color: AppColors.yellow,
                          title: 'New trip #${d.waybill}',
                          subtitle: '${d.pickup ?? "N/A"} → ${d.stops.isNotEmpty ? d.stops.last : "N/A"}',
                          time: d.created,
                        )).toList()),
                      ],
                      if (inProgress.isNotEmpty) ...[
                        _NotifSection(title: 'In Progress', color: AppColors.accentColor, items: inProgress.map((d) => _NotifItem(
                          icon: HugeIcons.strokeRoundedContainerTruck01,
                          color: AppColors.accentColor,
                          title: 'Trip #${d.waybill} in progress',
                          subtitle: 'Driver: ${d.driver ?? "N/A"}',
                          time: d.start,
                        )).toList()),
                      ],
                      if (completed.isNotEmpty) ...[
                        _NotifSection(title: 'Recently Completed', color: AppColors.green, items: completed.take(5).map((d) => _NotifItem(
                          icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                          color: AppColors.green,
                          title: 'Trip #${d.waybill} completed',
                          subtitle: '${d.stops.isNotEmpty ? d.stops.last : "N/A"}',
                          time: d.created,
                        )).toList()),
                      ],
                      const SizedBox(height: 24),
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotifSection extends StatelessWidget {
  const _NotifSection({required this.title, required this.color, required this.items});
  final String title;
  final Color color;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
          child: AppText.medium(title, fontSize: 12, color: color),
        ),
        ...items,
      ],
    );
  }
}

class _NotifItem extends StatelessWidget {
  const _NotifItem({required this.icon, required this.color, required this.title, required this.subtitle, required this.time});
  final dynamic icon;
  final Color color;
  final String title, subtitle, time;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.04),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: AppIcon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.medium(title, fontSize: 12),
                AppText.thin(subtitle, fontSize: 11, color: AppColors.lightTextColor, maxlines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          AppText.thin(time.split(' ').first, fontSize: 10, color: AppColors.lightTextColor),
        ],
      ),
    );
  }
}