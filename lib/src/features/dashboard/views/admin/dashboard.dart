import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/resource_history.dart';
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

  @override
  Widget build(BuildContext context) {
    return Obx((){
      print(controller.appRepo.appService.isDarkMode.value);
      return Ui.width(context) > 500
        ? desktopVersion()
        : RefreshScrollView(
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
                      cities: ["All", ...controller.allActiveStateLocations.map((e) => e.name)],
                      hasBottomPadding: false,
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
  
    });
    }

  Widget desktopVersion() {
    return CurvedContainer(
      border: Border.all(color: AppColors.borderColor),
      radius: 0,
      child: Column(
        children: [
          AppDivider(),
          Padding(
            padding: EdgeInsetsGeometry.all(8),
            child: Row(
              children: [
                AppText.bold("Welcome to Transborder Logistics", fontSize: 24),
                Spacer(),
                SizedBox(
                  width: 280,
                  child: AppContainer("", [
                    CustomDropdown.city(
                      hint: "Select Location",
                      label: "Location",
                      selectedValue: controller.curLoc.value,
                      onChanged: (v) async {
                        await controller.changeLocation(v ?? "All");
                      },
                      cities: ["All", ...controller.allActiveStateLocations.map((e) => e.name)],
                      hasBottomPadding: false,
                    ),
                  ]),
                ),
              ],
            ),
          ),
          AppDivider(),
          Ui.boxHeight(8),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              dashboardItem(
                DashboardItem.trips,
                controller.allCustomerDeliveries.length,
                0,
              ),
              dashboardItem(
                DashboardItem.users,
                controller.allCustomers.length,
                0,
              ),
              dashboardItem(
                DashboardItem.drivers,
                controller.allDrivers.length,
                0,
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
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 400,
                  child: ResourceHistoryPage<Delivery>(
                    "Trips",
                    controller.allUndeliveredDeliveries,
                    hasDrawer: true,
                    filters: [],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(24),
                      child: _DeliveryMap(controller: controller),
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

  CurvedContainer dashboardItem(DashboardItem dit, int value, double rate) {
    final color = rate > 0
        ? AppColors.green
        : rate == 0
        ? AppColors.yellow
        : AppColors.primaryColor;
    return CurvedContainer(
      width: Ui.width(context) > 500
          ? Ui.width(context) / 7
          : (Ui.width(context) - 48) / 2,
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

// ─────────────────────────────────────────────────────────────────────────────
// Interactive map widget — renders OSM tiles with delivery location markers
// ─────────────────────────────────────────────────────────────────────────────

class _DeliveryMap extends StatefulWidget {
  const _DeliveryMap({required this.controller});
  final DashboardController controller;

  @override
  State<_DeliveryMap> createState() => _DeliveryMapState();
}

class _DeliveryMapState extends State<_DeliveryMap> {
  static const LatLng _defaultCenter = LatLng(10.5264, 7.4384);
  final MapController _mapController = MapController();
  Location? _selectedLocation;

  List<Location> get _locationsWithCoords => widget.controller.allLocation
      .where((l) => (l.lat ?? 0) != 0 && (l.lng ?? 0) != 0)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final locations = _locationsWithCoords;
      final center = locations.isNotEmpty
          ? LatLng(locations.first.lat!, locations.first.lng!)
          : _defaultCenter;

      return Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 7.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (_, __) => setState(() => _selectedLocation = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.transborder.logistics',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: locations.map((loc) {
                  final isActive = loc.isActive;
                  final isSelected = _selectedLocation?.id == loc.id;
                  return Marker(
                    point: LatLng(loc.lat!, loc.lng!),
                    width: isSelected ? 48 : 36,
                    height: isSelected ? 48 : 36,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedLocation = loc),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor
                              : isActive
                                  ? AppColors.primaryColor.withOpacity(0.85)
                                  : AppColors.yellow.withOpacity(0.85),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: isSelected ? 26 : 20,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          if (_selectedLocation != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: AppColors.primaryColorBackground,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryColor[50],
                        child: Icon(Icons.location_on, color: AppColors.primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText.bold(_selectedLocation!.name ?? '', fontSize: 14),
                            AppText.thin(
                              '${_selectedLocation!.lga}, ${_selectedLocation!.state}',
                              fontSize: 12,
                              color: AppColors.lightTextColor,
                            ),
                            if ((_selectedLocation!.facilityType ?? '').isNotEmpty)
                              AppText.thin(
                                _selectedLocation!.facilityType!,
                                fontSize: 11,
                                color: AppColors.accentColor,
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _selectedLocation!.isActive
                              ? AppColors.green.withOpacity(0.15)
                              : AppColors.yellow.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppText.medium(
                          _selectedLocation!.isActive ? 'Active' : 'Inactive',
                          fontSize: 11,
                          color: _selectedLocation!.isActive ? AppColors.green : AppColors.yellow,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _selectedLocation = null),
                        child: Icon(Icons.close, size: 18, color: AppColors.lightTextColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.add,
                  onTap: () => _mapController.move(
                      _mapController.camera.center, _mapController.camera.zoom + 1),
                ),
                const SizedBox(height: 4),
                _MapButton(
                  icon: Icons.remove,
                  onTap: () => _mapController.move(
                      _mapController.camera.center, _mapController.camera.zoom - 1),
                ),
                const SizedBox(height: 4),
                _MapButton(
                  icon: Icons.my_location,
                  onTap: () => _mapController.move(center, 7.0),
                ),
              ],
            ),
          ),

          Positioned(
            top: 16,
            left: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(10),
              color: AppColors.primaryColorBackground.withOpacity(0.92),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LegendItem(color: AppColors.primaryColor, label: 'Active'),
                    const SizedBox(height: 4),
                    _LegendItem(color: AppColors.yellow, label: 'Inactive'),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      color: AppColors.primaryColorBackground,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: AppColors.textColor),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        AppText.thin(label, fontSize: 11),
      ],
    );
  }
}