import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/explorer.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/resource_history.dart';
import 'package:transborder_logistics/src/features/dashboard/views/shared.dart';
import 'package:transborder_logistics/src/global/model/user.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';
import 'package:transborder_logistics/src/src_barrel.dart';
import 'package:transborder_logistics/src/utils/constants/string/facilities.dart';
import 'package:transborder_logistics/src/features/dashboard/models/var_data.dart';

import '../../../../global/services/barrel.dart';
import '../../../../global/ui/ui_barrel.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigate(DashboardController controller, DashboardMode e) {
    controller.curDashboardIndex.value = e.index;
    controller.currentModelIndex.value = 0;

    if (e != DashboardMode.dashboard) {
      ResourceHistory rh;
      if (e == DashboardMode.trips) {
        controller.currentModel = Delivery(createdAt: DateTime.now()).obs;
        rh = ResourceHistory<Delivery>(items: controller.allCustomerDeliveries);
      } else if (e == DashboardMode.users) {
        controller.currentModel = User().obs;
        rh = ResourceHistory<User>(items: controller.allCustomers);
      } else if (e == DashboardMode.drivers) {
        controller.currentModel = User().obs;
        rh = ResourceHistory<User>(items: controller.allDrivers);
      } else if (e == DashboardMode.location) {
        controller.currentModel = StateLocation().obs;
        rh = ResourceHistory<StateLocation>(items: controller.allStateLocations);
      } else if (e == DashboardMode.facilities) {
        controller.currentModel = Location().obs;
        rh = ResourceHistory<Location>(items: controller.allFacilities);
      } else if (e == DashboardMode.pickups) {
        controller.currentModel = Location().obs;
        rh = ResourceHistory<Location>(items: controller.allLoadingPoints);
      } else if (e == DashboardMode.vehicles) {
        controller.currentModel = Vehicle().obs;
        rh = ResourceHistory<Vehicle>(items: controller.allVehicles);
      } else if (e == DashboardMode.varRecords) {
        controller.currentModel = VarRecord().obs;
        rh = ResourceHistory<VarRecord>(items: controller.allVarRecords);
      } else {
        rh = ResourceHistory(items: []);
      }
      controller.currentModel.refresh();
      rh.title = e.name;
      rh.filters = e.filters;
      rh.onFilter = (v, s) => controller.getFilters(v, s, e.name);
      controller.curResourceHistory.value = rh;
    } else {
      controller.curResourceHistory.value = ResourceHistory();
    }
    controller.curResourceHistory.refresh();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final appService = Get.find<AppService>();
    final controller = Get.find<DashboardController>();

    return Container(
      width: Ui.width(context) * 0.75,
      color: AppColors.primaryColorBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo & dark mode toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  Image.asset(Assets.fulllogo, width: 120),
                  const Spacer(),
                  const ToogleDarkModeWidget(),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: AppColors.borderColor, height: 1),
            const SizedBox(height: 8),

            // Nav items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: DashboardMode.values.map((e) {
                  return Obx(() {
                    final isActive = controller.curDashboardIndex.value == e.index;
                    return GestureDetector(
                      onTap: () => _navigate(controller, e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isActive
                              ? Border.all(color: AppColors.primaryColor.withOpacity(0.2))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primaryColor
                                    : AppColors.surfaceColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: AppIcon(
                                  e.icon,
                                  size: 18,
                                  color: isActive ? Colors.white : AppColors.lightTextColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppText.medium(
                                e.name,
                                fontSize: 14,
                                color: isActive
                                    ? AppColors.primaryColor
                                    : AppColors.textColor,
                              ),
                            ),
                            if (isActive)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),
            ),

            Divider(color: AppColors.borderColor, height: 1),

            // User profile footer
            InkWell(
              onTap: () => Get.to(
                SinglePageScaffold(title: "Profile", child: ProfilePage()),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Obx(() {
                  final user = appService.currentUser.value;
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryColor.withOpacity(0.15),
                        child: AppText.bold(
                          (user.name?.isNotEmpty ?? false)
                              ? user.name![0].toUpperCase()
                              : '?',
                          fontSize: 16,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText.medium(user.name ?? 'N/A', fontSize: 13),
                            AppText.thin(
                              user.role.capitalize ?? '',
                              fontSize: 11,
                              color: AppColors.lightTextColor,
                            ),
                          ],
                        ),
                      ),
                      AppIcon(
                        HugeIcons.strokeRoundedMoreHorizontal,
                        size: 18,
                        color: AppColors.lightTextColor,
                      ),
                    ],
                  );
                }),
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
    return Obx(() {
      return GestureDetector(
        onTap: () async => await controller.toggleDarkMode(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 56,
          height: 28,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: controller.isDarkMode.value
                ? AppColors.primaryColor
                : AppColors.borderColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: controller.isDarkMode.value
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      controller.isDarkMode.value
                          ? Icons.nightlight_round
                          : Icons.wb_sunny_rounded,
                      size: 13,
                      color: controller.isDarkMode.value
                          ? AppColors.primaryColor
                          : AppColors.yellow,
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

// ─────────────────────────────────────────────────────────────────────────────
// Notifications Panel
// ─────────────────────────────────────────────────────────────────────────────

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardController>();
    return Obx(() {
      final pending = c.allCustomerDeliveries
          .where((d) => d.hasNotStarted && !d.isCanceled)
          .length;
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
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColorBackground,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        pending > 9 ? '9+' : '$pending',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    AppText.bold('Notifications', fontSize: 18),
                    const Spacer(),
                    Obx(() {
                      final count = c.allCustomerDeliveries
                          .where((d) => d.hasNotStarted && !d.isCanceled)
                          .length;
                      if (count == 0) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppText.medium('$count New',
                            fontSize: 11, color: Colors.white),
                      );
                    }),
                  ],
                ),
              ),
              AppDivider(),
              Expanded(
                child: Obx(() {
                  final newTrips = c.allCustomerDeliveries
                      .where((d) => d.hasNotStarted && !d.isCanceled)
                      .toList();
                  final inProgress = c.allCustomerDeliveries
                      .where((d) => d.hasStarted && d.isNotDelivered)
                      .toList();
                  final completed = c.allCustomerDeliveries
                      .where((d) => d.isDelivered)
                      .toList();

                  if (newTrips.isEmpty &&
                      inProgress.isEmpty &&
                      completed.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(
                            HugeIcons.strokeRoundedNotification01,
                            size: 48,
                            color: AppColors.lightTextColor,
                          ),
                          const SizedBox(height: 12),
                          AppText.thin('No notifications',
                              color: AppColors.lightTextColor),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    controller: scrollController,
                    children: [
                      if (newTrips.isNotEmpty) ...[
                        _NotifSection(
                          title: 'New Trips',
                          color: AppColors.yellow,
                          items: newTrips
                              .map((d) => _NotifItem(
                                    icon: HugeIcons.strokeRoundedAlertCircle,
                                    color: AppColors.yellow,
                                    title: 'New trip #${d.waybill}',
                                    subtitle:
                                        '${d.pickup ?? "N/A"} → ${d.stops.isNotEmpty ? d.stops.last : "N/A"}',
                                    time: d.created,
                                  ))
                              .toList(),
                        ),
                      ],
                      if (inProgress.isNotEmpty) ...[
                        _NotifSection(
                          title: 'In Progress',
                          color: AppColors.accentColor,
                          items: inProgress
                              .map((d) => _NotifItem(
                                    icon: HugeIcons
                                        .strokeRoundedContainerTruck01,
                                    color: AppColors.accentColor,
                                    title: 'Trip #${d.waybill} in progress',
                                    subtitle: 'Driver: ${d.driver ?? "N/A"}',
                                    time: d.start,
                                  ))
                              .toList(),
                        ),
                      ],
                      if (completed.isNotEmpty) ...[
                        _NotifSection(
                          title: 'Recently Completed',
                          color: AppColors.green,
                          items: completed
                              .take(5)
                              .map((d) => _NotifItem(
                                    icon: HugeIcons
                                        .strokeRoundedCheckmarkCircle02,
                                    color: AppColors.green,
                                    title: 'Trip #${d.waybill} completed',
                                    subtitle:
                                        '${d.stops.isNotEmpty ? d.stops.last : "N/A"}',
                                    time: d.created,
                                  ))
                              .toList(),
                        ),
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
  const _NotifSection(
      {required this.title, required this.color, required this.items});
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
  const _NotifItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
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
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppIcon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.medium(title, fontSize: 12),
                AppText.thin(subtitle,
                    fontSize: 11,
                    color: AppColors.lightTextColor,
                    maxlines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          AppText.thin(time.split(' ').first,
              fontSize: 10, color: AppColors.lightTextColor),
        ],
      ),
    );
  }
}