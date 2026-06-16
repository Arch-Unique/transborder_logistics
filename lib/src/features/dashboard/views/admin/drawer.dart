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
  const AppDrawer({this.collapsed = false, super.key});
  final bool collapsed;

  void _navigate(DashboardController controller, DashboardMode e) {
    controller.curDashboardIndex.value = e.index;
    controller.currentModelIndex.value = 0;

    if (e != DashboardMode.dashboard && e != DashboardMode.tracking) {
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
      controller.curResourceHistory.value = ResourceHistory(title: e.name);
    }
    controller.curResourceHistory.refresh();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final appService = Get.find<AppService>();
    final controller = Get.find<DashboardController>();

    return Container(
      width: collapsed ? double.infinity : Ui.width(context) * 0.78,
      color: AppColors.primaryColorBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Logo & dark mode ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: collapsed
                  ? Center(
                      child: AppIcon(HugeIcons.strokeRoundedTruck,
                          color: AppColors.primaryColor, size: 26),
                    )
                  : Row(
                      children: [
                        Image.asset(Assets.fulllogo, width: 110),
                        const Spacer(),
                        const ToogleDarkModeWidget(),
                      ],
                    ),
            ),
            const SizedBox(height: 8),
            Divider(color: AppColors.borderColor, height: 1),
            const SizedBox(height: 4),

            // ── Nav items ──────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: collapsed ? 6 : 10),
                children: [
                  // Dashboard
                  _NavItem(mode: DashboardMode.dashboard, controller: controller, collapsed: collapsed, onTap: () => _navigate(controller, DashboardMode.dashboard)),
                  // Trips
                  _NavItem(mode: DashboardMode.trips, controller: controller, collapsed: collapsed, onTap: () => _navigate(controller, DashboardMode.trips)),
                  // Tracking
                  _NavItem(mode: DashboardMode.tracking, controller: controller, collapsed: collapsed, onTap: () => _navigate(controller, DashboardMode.tracking)),

                  const SizedBox(height: 4),
                  // ── Location group ──────────────────────────────────
                  _NavGroup(
                    icon: HugeIcons.strokeRoundedLocation05,
                    label: 'Location',
                    controller: controller,
                    collapsed: collapsed,
                    children: [
                      DashboardMode.location,
                      DashboardMode.pickups,
                      DashboardMode.facilities,
                    ],
                    onTap: _navigate,
                    childLabels: const ['States', 'Loading Points', 'Facilities'],
                  ),
                  const SizedBox(height: 4),

                  // ── Logistics group ─────────────────────────────────
                  _NavGroup(
                    icon: HugeIcons.strokeRoundedContainerTruck01,
                    label: 'Logistics',
                    controller: controller,
                    collapsed: collapsed,
                    children: [
                      DashboardMode.vehicles,
                      DashboardMode.drivers,
                    ],
                    onTap: _navigate,
                    childLabels: const ['Vehicles', 'Drivers'],
                  ),
                  const SizedBox(height: 4),

                  // VAR Records
                  _NavItem(mode: DashboardMode.varRecords, controller: controller, collapsed: collapsed, onTap: () => _navigate(controller, DashboardMode.varRecords)),
                  // Users
                  _NavItem(mode: DashboardMode.users, controller: controller, collapsed: collapsed, onTap: () => _navigate(controller, DashboardMode.users)),
                ],
              ),
            ),

            Divider(color: AppColors.borderColor, height: 1),

            // ── User profile ───────────────────────────────────────────
            InkWell(
              onTap: () => Get.to(SinglePageScaffold(title: "Profile", child: ProfilePage())),
              child: Padding(
                padding: EdgeInsets.fromLTRB(collapsed ? 0 : 16, 12, collapsed ? 0 : 16, 16),
                child: Obx(() {
                  final user = appService.currentUser.value;
                  final avatar = CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.15),
                    child: AppText.bold(
                      (user.name?.isNotEmpty ?? false) ? user.name![0].toUpperCase() : '?',
                      fontSize: 14, color: AppColors.primaryColor,
                    ),
                  );
                  if (collapsed) {
                    return Center(child: avatar);
                  }
                  return Row(
                    children: [
                      avatar,
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText.medium(user.name ?? 'N/A', fontSize: 13),
                            AppText.thin(user.role.capitalize ?? '', fontSize: 11, color: AppColors.lightTextColor),
                          ],
                        ),
                      ),
                      AppIcon(HugeIcons.strokeRoundedMoreHorizontal, size: 16, color: AppColors.lightTextColor),
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

// ── Single nav item ─────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({required this.mode, required this.controller, required this.onTap, this.collapsed = false});
  final DashboardMode mode;
  final DashboardController controller;
  final VoidCallback onTap;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = controller.curDashboardIndex.value == mode.index;
      final iconBadge = Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryColor : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: AppIcon(mode.icon, size: 16,
          color: isActive ? Colors.white : AppColors.lightTextColor)),
      );

      if (collapsed) {
        return Tooltip(
          message: mode.name,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isActive ? Border.all(color: AppColors.primaryColor.withOpacity(0.2)) : null,
              ),
              child: Center(child: iconBadge),
            ),
          ),
        );
      }

      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive ? Border.all(color: AppColors.primaryColor.withOpacity(0.2)) : null,
          ),
          child: Row(
            children: [
              iconBadge,
              const SizedBox(width: 10),
              Expanded(child: AppText.medium(mode.name, fontSize: 13,
                color: isActive ? AppColors.primaryColor : AppColors.textColor)),
              if (isActive)
                Container(width: 6, height: 6,
                  decoration: BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle)),
            ],
          ),
        ),
      );
    });
  }
}

// ── Group nav item with expandable sub-items ────────────────────────────────

class _NavGroup extends StatefulWidget {
  const _NavGroup({
    required this.icon,
    required this.label,
    required this.controller,
    required this.children,
    required this.onTap,
    required this.childLabels,
    this.collapsed = false,
  });
  final dynamic icon;
  final String label;
  final DashboardController controller;
  final List<DashboardMode> children;
  final Function(DashboardController, DashboardMode) onTap;
  final List<String> childLabels;
  final bool collapsed;

  @override
  State<_NavGroup> createState() => _NavGroupState();
}

class _NavGroupState extends State<_NavGroup> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _expandAnim;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _expandAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    // Auto-expand if any child is active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idx = widget.controller.curDashboardIndex.value;
      if (widget.children.any((c) => c.index == idx)) {
        setState(() => _isExpanded = true);
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    _isExpanded ? _animController.forward() : _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final idx = widget.controller.curDashboardIndex.value;
      final hasActiveChild = widget.children.any((c) => c.index == idx);

      if (widget.collapsed) {
        return Tooltip(
          message: widget.label,
          child: GestureDetector(
            onTap: () {
              // Groups need the full sidebar to show sub-items, so
              // collapsing them inline doesn't make sense — instead,
              // tapping a collapsed group re-expands the whole sidebar.
              widget.controller.isSidebarCollapsed.value = false;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: hasActiveChild ? AppColors.primaryColor.withOpacity(0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: hasActiveChild ? AppColors.primaryColor : AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: AppIcon(widget.icon, size: 16,
                    color: hasActiveChild ? Colors.white : AppColors.lightTextColor)),
                ),
              ),
            ),
          ),
        );
      }

      return Column(
        children: [
          // Group header
          GestureDetector(
            onTap: _toggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: hasActiveChild ? AppColors.primaryColor.withOpacity(0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: hasActiveChild ? AppColors.primaryColor : AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: AppIcon(widget.icon, size: 16,
                      color: hasActiveChild ? Colors.white : AppColors.lightTextColor)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: AppText.medium(widget.label, fontSize: 13,
                    color: hasActiveChild ? AppColors.primaryColor : AppColors.textColor)),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: AppIcon(HugeIcons.strokeRoundedArrowRight01, size: 14,
                      color: AppColors.lightTextColor),
                  ),
                ],
              ),
            ),
          ),

          // Sub-items
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Padding(
              padding: const EdgeInsets.only(left: 14, bottom: 2),
              child: Column(
                children: List.generate(widget.children.length, (i) {
                  final mode = widget.children[i];
                  final label = widget.childLabels[i];
                  final isActive = idx == mode.index;
                  return GestureDetector(
                    onTap: () => widget.onTap(widget.controller, mode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isActive ? Border.all(color: AppColors.primaryColor.withOpacity(0.2)) : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primaryColor : AppColors.borderColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: AppText.medium(label, fontSize: 12,
                            color: isActive ? AppColors.primaryColor : AppColors.lightTextColor)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      );
    });
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

// ─────────────────────────────────────────────────────────────────────────────
// Notifications Panel
// ─────────────────────────────────────────────────────────────────────────────

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
              // Handle
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
                          AppIcon(HugeIcons.strokeRoundedNotificationOff01, size: 48, color: AppColors.lightTextColor),
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
                          icon: HugeIcons.strokeRoundedTruck,
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