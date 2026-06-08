import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';
import 'package:transborder_logistics/src/app/theme/colors.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/global/model/user.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';
import 'package:transborder_logistics/src/global/ui/widgets/text/app_text.dart';
import 'package:transborder_logistics/src/src_barrel.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final controller = Get.find<DashboardController>();
  final MapController _mapController = MapController();
  final _dio = Dio();

  static const LatLng _defaultCenter = LatLng(10.5264, 7.4384);

  // Trip selection
  Delivery? _selectedDelivery;
  List<LatLng> _routePoints = [];
  bool _loadingRoute = false;

  // Search & filter
  String _searchQuery = '';
  String _filterStatus = 'All';
  final List<String> _filters = ['All', 'New', 'In Progress', 'Completed', 'Cancelled'];

  // Map layer toggles
  bool _showAllLocations = true;
  bool _showFacilities = true;
  bool _showLoadingPoints = true;
  bool _showStreetView = false;

  // Map tile URLs
  static const _osmUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const _streetUrl = 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png';

  // ── Location helpers ────────────────────────────────────────────────────────

  Location? _findLocation(String desc) {
    final locations = controller.allLocation;
    if (desc.isEmpty) return null;
    try {
      return locations.firstWhere(
        (l) => l.desc.toLowerCase().trim() == desc.toLowerCase().trim(),
      );
    } catch (_) {
      try {
        return locations.firstWhere(
          (l) => desc.toLowerCase().contains(l.name?.toLowerCase() ?? ''),
        );
      } catch (_) {
        return null;
      }
    }
  }

  // ── Route fetching ──────────────────────────────────────────────────────────

  Future<void> _fetchRoute(Delivery delivery) async {
    final pickup = _findLocation(delivery.pickup ?? '');
    if (pickup == null || (pickup.lat ?? 0) == 0) {
      Get.snackbar('No coordinates', 'Pickup location has no GPS set',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.yellow.withOpacity(0.9),
          colorText: Colors.white);
      return;
    }

    final stopLocations = delivery.stops
        .map((s) => _findLocation(s))
        .where((l) => l != null && (l.lat ?? 0) != 0)
        .map((l) => LatLng(l!.lat!, l.lng!))
        .toList();

    if (stopLocations.isEmpty) {
      Get.snackbar('No coordinates', 'Delivery stops have no GPS set',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.yellow.withOpacity(0.9),
          colorText: Colors.white);
      return;
    }

    setState(() { _loadingRoute = true; _routePoints = []; });

    try {
      final allPoints = [LatLng(pickup.lat!, pickup.lng!), ...stopLocations];
      final coords = allPoints.map((p) => '${p.longitude},${p.latitude}').join(';');
      final url = 'https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final coordsList = response.data['routes'][0]['geometry']['coordinates'] as List;
        setState(() {
          _routePoints = coordsList
              .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
              .toList();
        });

        if (_routePoints.isNotEmpty) {
          final lats = _routePoints.map((p) => p.latitude);
          final lngs = _routePoints.map((p) => p.longitude);
          _mapController.move(
            LatLng(lats.reduce((a, b) => a + b) / lats.length,
                   lngs.reduce((a, b) => a + b) / lngs.length),
            9.0,
          );
        }
      }
    } catch (e) { print('Route error: $e'); }
    finally { setState(() => _loadingRoute = false); }
  }

  // ── Filtered deliveries ─────────────────────────────────────────────────────

  List<Delivery> get _filteredDeliveries {
    var deliveries = controller.allCustomerDeliveries.toList();
    if (_filterStatus != 'All') {
      deliveries = deliveries.where((d) {
        switch (_filterStatus) {
          case 'New': return d.hasNotStarted && !d.isCanceled;
          case 'In Progress': return d.hasStarted && d.isNotDelivered;
          case 'Completed': return d.isDelivered;
          case 'Cancelled': return d.isCanceled;
          default: return true;
        }
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      deliveries = deliveries.where((d) =>
        d.waybill.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (d.driver?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
        (d.pickup?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    return deliveries;
  }

  // ── Status helpers ──────────────────────────────────────────────────────────

  Color _statusColor(Delivery d) {
    if (d.isCanceled) return AppColors.primaryColor;
    if (d.isDelivered) return AppColors.green;
    if (d.hasStarted) return AppColors.accentColor;
    return AppColors.yellow;
  }

  String _statusLabel(Delivery d) {
    if (d.isCanceled) return 'Cancelled';
    if (d.isDelivered) return 'Completed';
    if (d.hasStarted) return 'In Progress';
    return 'New';
  }

  dynamic _statusIcon(Delivery d) {
    if (d.isCanceled) return HugeIcons.strokeRoundedCancelCircle;
    if (d.isDelivered) return HugeIcons.strokeRoundedCheckmarkCircle02;
    if (d.hasStarted) return HugeIcons.strokeRoundedContainerTruck01;
    return HugeIcons.strokeRoundedClock01;
  }

  // ── Visible locations ───────────────────────────────────────────────────────

  List<Location> get _visibleLocations {
    if (!_showAllLocations) return [];
    return controller.allLocation.where((l) {
      if ((l.lat ?? 0) == 0 || (l.lng ?? 0) == 0) return false;
      final isFacility = l.facilityType == 'Hospital' || l.facilityType == 'Clinic';
      final isLoadingPoint = l.facilityType == 'Loading Point';
      if (isFacility && !_showFacilities) return false;
      if (isLoadingPoint && !_showLoadingPoints) return false;
      return true;
    }).toList();
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColorBackground,
      body: Obx(() {
        final deliveries = _filteredDeliveries;
        final isDesktop = MediaQuery.of(context).size.width > 800;
        return isDesktop ? _buildDesktop(deliveries) : _buildMobile(deliveries);
      }),
    );
  }

  Widget _buildDesktop(List<Delivery> deliveries) {
    return Row(
      children: [
        SizedBox(
          width: 380,
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildFilterChips(),
              _buildStats(),
              Expanded(child: _buildTripList(deliveries)),
            ],
          ),
        ),
        Expanded(child: _buildMap()),
      ],
    );
  }

  Widget _buildMobile(List<Delivery> deliveries) {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        _buildFilterChips(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.38, child: _buildMap()),
        _buildStats(),
        Expanded(child: _buildTripList(deliveries)),
      ],
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20, right: 20, bottom: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryColorBackground,
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppIcon(HugeIcons.strokeRoundedRoute03, color: AppColors.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.bold('Trip Tracking', fontSize: 18),
              Obx(() => AppText.thin(
                '${controller.allCustomerDeliveries.length} total trips',
                fontSize: 12, color: AppColors.lightTextColor,
              )),
            ],
          ),
          const Spacer(),
          InkWell(
            onTap: () async => await controller.initApp(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppIcon(HugeIcons.strokeRoundedRefresh, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search ──────────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            AppIcon(HugeIcons.strokeRoundedSearch02, size: 16, color: AppColors.lightTextColor),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(fontSize: 13, color: AppColors.textColor),
                decoration: InputDecoration(
                  hintText: 'Search by waybill, driver, location...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.lightTextColor),
                  border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter chips ────────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
        children: _filters.map((f) {
          final isSelected = _filterStatus == f;
          Color chipColor = AppColors.lightTextColor;
          if (f == 'New') chipColor = AppColors.yellow;
          if (f == 'In Progress') chipColor = AppColors.accentColor;
          if (f == 'Completed') chipColor = AppColors.green;
          if (f == 'Cancelled') chipColor = AppColors.primaryColor;

          return GestureDetector(
            onTap: () => setState(() => _filterStatus = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? (f == 'All' ? AppColors.primaryColor : chipColor) : AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? (f == 'All' ? AppColors.primaryColor : chipColor) : AppColors.borderColor,
                ),
              ),
              child: AppText.medium(f, fontSize: 12,
                color: isSelected ? Colors.white : AppColors.lightTextColor),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Stats ───────────────────────────────────────────────────────────────────

  Widget _buildStats() {
    return Obx(() {
      final all = controller.allCustomerDeliveries;
      final ongoing = all.where((d) => d.hasStarted && d.isNotDelivered).length;
      final newTrips = all.where((d) => d.hasNotStarted && !d.isCanceled).length;
      final done = all.where((d) => d.isDelivered).length;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            _StatChip(label: 'New', value: newTrips, color: AppColors.yellow),
            _Divider(),
            _StatChip(label: 'Active', value: ongoing, color: AppColors.accentColor),
            _Divider(),
            _StatChip(label: 'Done', value: done, color: AppColors.green),
            _Divider(),
            _StatChip(label: 'Total', value: all.length, color: AppColors.primaryColor),
          ],
        ),
      );
    });
  }

  // ── Trip list ───────────────────────────────────────────────────────────────

  Widget _buildTripList(List<Delivery> deliveries) {
    if (deliveries.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AppIcon(HugeIcons.strokeRoundedRoute03, size: 48, color: AppColors.lightTextColor),
          const SizedBox(height: 12),
          AppText.thin('No trips found', color: AppColors.lightTextColor),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: deliveries.length,
      itemBuilder: (_, i) => _TripCard(
        delivery: deliveries[i],
        isSelected: _selectedDelivery?.id == deliveries[i].id,
        statusColor: _statusColor(deliveries[i]),
        statusLabel: _statusLabel(deliveries[i]),
        statusIcon: _statusIcon(deliveries[i]),
        onTap: () {
          setState(() {
            // Clicking same trip deselects it
            if (_selectedDelivery?.id == deliveries[i].id) {
              _selectedDelivery = null;
              _routePoints = [];
            } else {
              // Clear old route immediately, load new one
              _selectedDelivery = deliveries[i];
              _routePoints = [];
              _fetchRoute(deliveries[i]);
            }
          });
        },
      ),
    );
  }

  // ── Map ─────────────────────────────────────────────────────────────────────

  Widget _buildMap() {
    final visibleLocations = _visibleLocations;
    final pickupLoc = _selectedDelivery != null
        ? _findLocation(_selectedDelivery!.pickup ?? '') : null;
    final stopLoc = _selectedDelivery != null && _selectedDelivery!.stops.isNotEmpty
        ? _findLocation(_selectedDelivery!.stops.last) : null;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _defaultCenter,
            initialZoom: 7.0,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            // Map tiles — standard or street view
            TileLayer(
              urlTemplate: _showStreetView ? _streetUrl : _osmUrl,
              subdomains: _showStreetView ? const ['a', 'b', 'c'] : const [],
              userAgentPackageName: 'com.transborder.logistics',
              maxZoom: 19,
            ),

            // Route polyline — only for selected trip
            if (_routePoints.isNotEmpty)
              PolylineLayer(polylines: [
                Polyline(
                  points: _routePoints,
                  strokeWidth: 5,
                  color: AppColors.accentColor,
                  borderStrokeWidth: 2,
                  borderColor: AppColors.accentColor.withOpacity(0.25),
                ),
              ]),

            // Location markers
            if (visibleLocations.isNotEmpty)
              MarkerLayer(
                markers: visibleLocations.map((loc) {
                  final isFacility = loc.facilityType == 'Hospital' || loc.facilityType == 'Clinic';
                  final color = isFacility
                      ? AppColors.primaryColor.withOpacity(0.7)
                      : AppColors.accentColor.withOpacity(0.7);
                  return Marker(
                    point: LatLng(loc.lat!, loc.lng!),
                    width: 22, height: 22,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(Icons.circle, color: Colors.white, size: 7),
                    ),
                  );
                }).toList(),
              ),

            // Pickup marker (green)
            if (pickupLoc != null && (pickupLoc.lat ?? 0) != 0)
              MarkerLayer(markers: [
                Marker(
                  point: LatLng(pickupLoc.lat!, pickupLoc.lng!),
                  width: 48, height: 48,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.green, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [BoxShadow(color: AppColors.green.withOpacity(0.4), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.trip_origin, color: Colors.white, size: 20),
                  ),
                ),
              ]),

            // Destination marker (red)
            if (stopLoc != null && (stopLoc.lat ?? 0) != 0)
              MarkerLayer(markers: [
                Marker(
                  point: LatLng(stopLoc.lat!, stopLoc.lng!),
                  width: 48, height: 48,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [BoxShadow(color: AppColors.primaryColor.withOpacity(0.4), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.flag, color: Colors.white, size: 20),
                  ),
                ),
              ]),
          ],
        ),

        // No trip selected overlay
        if (_selectedDelivery == null)
          Center(
            child: Material(
              elevation: 8, borderRadius: BorderRadius.circular(16),
              color: AppColors.primaryColorBackground.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  AppIcon(HugeIcons.strokeRoundedRoute03, size: 32, color: AppColors.primaryColor),
                  const SizedBox(height: 8),
                  AppText.medium('Select a trip to view route', fontSize: 13),
                  AppText.thin('Tap any trip card on the left', fontSize: 11, color: AppColors.lightTextColor),
                ]),
              ),
            ),
          ),

        // Loading route
        if (_loadingRoute)
          Positioned(
            top: 16, left: 0, right: 0,
            child: Center(
              child: Material(
                elevation: 8, borderRadius: BorderRadius.circular(20),
                color: AppColors.primaryColorBackground,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentColor)),
                    const SizedBox(width: 8),
                    AppText.thin('Calculating route...', fontSize: 12),
                  ]),
                ),
              ),
            ),
          ),

        // Map controls — top right
        Positioned(
          top: 16, right: 16,
          child: Column(children: [
            _MapBtn(icon: Icons.add, onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1)),
            const SizedBox(height: 4),
            _MapBtn(icon: Icons.remove, onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1)),
            const SizedBox(height: 4),
            _MapBtn(icon: Icons.my_location, onTap: () => _mapController.move(_defaultCenter, 7.0)),
            const SizedBox(height: 4),
            // Street view toggle
            _MapBtn(
              icon: _showStreetView ? Icons.map : Icons.streetview,
              onTap: () => setState(() => _showStreetView = !_showStreetView),
              active: _showStreetView,
            ),
          ]),
        ),

        // Layer controls panel — top left
        Positioned(
          top: 16, left: 16,
          child: Material(
            elevation: 4, borderRadius: BorderRadius.circular(12),
            color: AppColors.primaryColorBackground.withOpacity(0.95),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText.medium('Layers', fontSize: 11, color: AppColors.lightTextColor),
                  const SizedBox(height: 6),
                  _LayerToggle(
                    label: 'All Locations',
                    color: AppColors.primaryColor,
                    value: _showAllLocations,
                    onChanged: (v) => setState(() => _showAllLocations = v),
                  ),
                  if (_showAllLocations) ...[
                    const SizedBox(height: 4),
                    _LayerToggle(
                      label: 'Facilities',
                      color: AppColors.primaryColor,
                      value: _showFacilities,
                      onChanged: (v) => setState(() => _showFacilities = v),
                      indent: true,
                    ),
                    const SizedBox(height: 4),
                    _LayerToggle(
                      label: 'Loading Points',
                      color: AppColors.accentColor,
                      value: _showLoadingPoints,
                      onChanged: (v) => setState(() => _showLoadingPoints = v),
                      indent: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Selected trip info bar at bottom
        if (_selectedDelivery != null)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColorBackground,
                border: Border(top: BorderSide(color: AppColors.borderColor)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: _statusColor(_selectedDelivery!), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText.bold('#${_selectedDelivery!.waybill}', fontSize: 12),
                        AppText.thin(
                          '${_selectedDelivery!.pickup ?? "?"} → ${_selectedDelivery!.stops.isNotEmpty ? _selectedDelivery!.stops.last : "?"}',
                          fontSize: 11, color: AppColors.lightTextColor,
                          maxlines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accentColor.withOpacity(0.3)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.gps_fixed, size: 12, color: AppColors.accentColor),
                      const SizedBox(width: 4),
                      AppText.medium('Driver GPS', fontSize: 10, color: AppColors.accentColor),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() { _selectedDelivery = null; _routePoints = []; }),
                    child: Icon(Icons.close, size: 16, color: AppColors.lightTextColor),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Layer toggle widget
// ─────────────────────────────────────────────────────────────────────────────

class _LayerToggle extends StatelessWidget {
  const _LayerToggle({
    required this.label,
    required this.color,
    required this.value,
    required this.onChanged,
    this.indent = false,
  });
  final String label;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool indent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (indent) const SizedBox(width: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 14, height: 14,
            decoration: BoxDecoration(
              color: value ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: value ? color : AppColors.borderColor, width: 1.5),
            ),
            child: value
                ? const Icon(Icons.check, color: Colors.white, size: 10)
                : null,
          ),
          const SizedBox(width: 6),
          AppText.thin(label, fontSize: 11),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trip Card
// ─────────────────────────────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.delivery,
    required this.isSelected,
    required this.statusColor,
    required this.statusLabel,
    required this.statusIcon,
    required this.onTap,
  });
  final Delivery delivery;
  final bool isSelected;
  final Color statusColor;
  final String statusLabel;
  final dynamic statusIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        decoration: BoxDecoration(
          color: isSelected ? statusColor.withOpacity(0.05) : AppColors.primaryColorBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? statusColor : AppColors.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))]
              : [],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.07),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppIcon(statusIcon, size: 14, color: statusColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.bold('#${delivery.waybill}', fontSize: 13),
                        if (delivery.commodityType?.isNotEmpty ?? false)
                          AppText.thin(delivery.commodityType!, fontSize: 10,
                            color: AppColors.lightTextColor, maxlines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 5, height: 5,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      AppText.medium(statusLabel, fontSize: 10, color: statusColor),
                    ]),
                  ),
                ],
              ),
            ),

            // Route
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Column(children: [
                    Container(width: 8, height: 8,
                      decoration: BoxDecoration(color: AppColors.green, shape: BoxShape.circle,
                        border: Border.all(color: AppColors.green.withOpacity(0.3), width: 2))),
                    Container(width: 1, height: 18, color: AppColors.borderColor),
                    Container(width: 8, height: 8,
                      decoration: BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3), width: 2))),
                  ]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.thin(delivery.pickup ?? 'N/A', fontSize: 12,
                          maxlines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 14),
                        AppText.thin(delivery.stops.isNotEmpty ? delivery.stops.last : 'N/A',
                          fontSize: 12, maxlines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderColor))),
              child: Row(
                children: [
                  AppIcon(HugeIcons.strokeRoundedContainerTruck01, size: 13, color: AppColors.lightTextColor),
                  const SizedBox(width: 4),
                  AppText.thin(delivery.truckno ?? 'N/A', fontSize: 11, color: AppColors.lightTextColor),
                  const SizedBox(width: 12),
                  AppIcon(HugeIcons.strokeRoundedUser, size: 13, color: AppColors.lightTextColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: AppText.thin(delivery.driver ?? 'N/A', fontSize: 11,
                      color: AppColors.lightTextColor, maxlines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.route, size: 10, color: AppColors.accentColor),
                        const SizedBox(width: 3),
                        AppText.medium('Route loaded', fontSize: 10, color: AppColors.accentColor),
                      ]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────


class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        AppText.bold('$value', fontSize: 18, color: color),
        AppText.thin(label, fontSize: 11, color: AppColors.lightTextColor),
      ]),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 30, color: AppColors.borderColor);
}

class _MapBtn extends StatelessWidget {
  const _MapBtn({required this.icon, required this.onTap, this.active = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      color: active ? AppColors.primaryColor : AppColors.primaryColorBackground,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: active ? Colors.white : AppColors.textColor),
        ),
      ),
    );
  }
}