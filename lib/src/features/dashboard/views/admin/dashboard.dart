import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/dashboard_analytics.dart';
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

  LatLng get center {
    final locations = _locationsWithCoords;
    return locations.isNotEmpty
        ? LatLng(locations.first.lat!, locations.first.lng!)
        : _defaultCenter;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final locations = _locationsWithCoords;

      return Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 7.0,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
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
                              : loc.isActive
                                  ? AppColors.primaryColor.withOpacity(0.85)
                                  : AppColors.yellow.withOpacity(0.85),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 3))],
                        ),
                        child: Icon(Icons.location_on, color: Colors.white, size: isSelected ? 26 : 20),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          if (_selectedLocation != null)
            Positioned(
              bottom: 16, left: 16, right: 16,
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
                            AppText.thin('${_selectedLocation!.lga}, ${_selectedLocation!.state}', fontSize: 12, color: AppColors.lightTextColor),
                            if ((_selectedLocation!.facilityType ?? '').isNotEmpty)
                              AppText.thin(_selectedLocation!.facilityType!, fontSize: 11, color: AppColors.accentColor),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _selectedLocation!.isActive ? AppColors.green.withOpacity(0.15) : AppColors.yellow.withOpacity(0.15),
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
            top: 16, right: 16,
            child: Column(
              children: [
                _MapButton(icon: Icons.add, onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1)),
                const SizedBox(height: 4),
                _MapButton(icon: Icons.remove, onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1)),
                const SizedBox(height: 4),
                _MapButton(icon: Icons.my_location, onTap: () => _mapController.move(center, 7.0)),
              ],
            ),
          ),

          Positioned(
            top: 16, left: 16,
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
        child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon, size: 20, color: AppColors.textColor)),
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
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        AppText.thin(label, fontSize: 11),
      ],
    );
  }
}