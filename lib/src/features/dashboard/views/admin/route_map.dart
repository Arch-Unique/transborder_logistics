import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:transborder_logistics/src/app/theme/colors.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/global/model/user.dart';
import 'package:transborder_logistics/src/global/ui/widgets/text/app_text.dart';
import 'package:transborder_logistics/src/src_barrel.dart';

class DeliveryRouteMap extends StatefulWidget {
  const DeliveryRouteMap({super.key});

  @override
  State<DeliveryRouteMap> createState() => _DeliveryRouteMapState();
}

class _DeliveryRouteMapState extends State<DeliveryRouteMap> {
  static const LatLng _defaultCenter = LatLng(10.5264, 7.4384);
  final MapController _mapController = MapController();
  final _dio = Dio();

  Location? _selectedLocation;
  Delivery? _selectedDelivery;
  List<LatLng> _routePoints = [];
  bool _loadingRoute = false;

  Location? _findLocation(String desc, List<Location> locations) {
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

  Future<void> _fetchRoute(LatLng from, List<LatLng> waypoints) async {
    setState(() {
      _loadingRoute = true;
      _routePoints = [];
    });

    try {
      final coords = [from, ...waypoints]
          .map((p) => '${p.longitude},${p.latitude}')
          .join(';');

      final url =
          'https://router.project-osrm.org/route/v1/driving/$coords'
          '?overview=full&geometries=geojson';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        final coordsList = data['routes'][0]['geometry']['coordinates'] as List;
        setState(() {
          _routePoints = coordsList
              .map((c) => LatLng(
                    (c[1] as num).toDouble(),
                    (c[0] as num).toDouble(),
                  ))
              .toList();
        });
      }
    } catch (e) {
      print('Route fetch error: $e');
    } finally {
      setState(() => _loadingRoute = false);
    }
  }

  void _onDeliveryTap(Delivery delivery, List<Location> locations) {
    final pickup = _findLocation(delivery.pickup ?? '', locations);
    if (pickup == null || (pickup.lat ?? 0) == 0) {
      Get.snackbar(
        'No coordinates',
        'Pickup location has no GPS coordinates set',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.yellow.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    final stopLocations = delivery.stops
        .map((s) => _findLocation(s, locations))
        .where((l) => l != null && (l.lat ?? 0) != 0)
        .map((l) => LatLng(l!.lat!, l.lng!))
        .toList();

    if (stopLocations.isEmpty) {
      Get.snackbar(
        'No coordinates',
        'Delivery stops have no GPS coordinates set',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.yellow.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _selectedDelivery = delivery);
    _fetchRoute(LatLng(pickup.lat!, pickup.lng!), stopLocations);
    _mapController.move(LatLng(pickup.lat!, pickup.lng!), 9.0);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<DashboardController>();
      final locations = controller.allLocation;
      final activeDeliveries = controller.allUndeliveredDeliveries;
      final locationsWithCoords = locations
          .where((l) => (l.lat ?? 0) != 0 && (l.lng ?? 0) != 0)
          .toList();

      return Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 7.0,
              interactionOptions:
                  const InteractionOptions(flags: InteractiveFlag.all),
              onTap: (_, __) => setState(() {
                _selectedLocation = null;
                _selectedDelivery = null;
                _routePoints = [];
              }),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.transborder.logistics',
                maxZoom: 19,
              ),

              // Route polyline
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4,
                      color: AppColors.accentColor,
                      borderStrokeWidth: 2,
                      borderColor: AppColors.accentColor.withOpacity(0.3),
                    ),
                  ],
                ),

              // Location markers
              MarkerLayer(
                markers: locationsWithCoords.map((loc) {
                  final isSelected = _selectedLocation?.id == loc.id;
                  return Marker(
                    point: LatLng(loc.lat!, loc.lng!),
                    width: isSelected ? 44 : 32,
                    height: isSelected ? 44 : 32,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedLocation = loc;
                        _selectedDelivery = null;
                        _routePoints = [];
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor
                              : loc.isActive
                                  ? AppColors.primaryColor.withOpacity(0.8)
                                  : AppColors.yellow.withOpacity(0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white,
                              width: isSelected ? 3 : 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.location_on,
                            color: Colors.white,
                            size: isSelected ? 24 : 18),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Route start/end markers
              if (_routePoints.isNotEmpty)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _routePoints.first,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.trip_origin,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    Marker(
                      point: _routePoints.last,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.flag,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Active trips + legend panel
          Positioned(
            top: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.primaryColorBackground.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LegendItem(
                            color: AppColors.primaryColor,
                            label: 'Active location'),
                        const SizedBox(height: 4),
                        _LegendItem(
                            color: AppColors.yellow, label: 'Inactive'),
                        const SizedBox(height: 4),
                        _LegendItem(
                            color: AppColors.accentColor, label: 'Route'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (activeDeliveries.isNotEmpty)
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.primaryColorBackground.withOpacity(0.95),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText.medium('Active Trips',
                              fontSize: 11,
                              color: AppColors.lightTextColor),
                          const SizedBox(height: 6),
                          ...activeDeliveries.take(5).map(
                            (d) => GestureDetector(
                              onTap: () => _onDeliveryTap(d, locations),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _selectedDelivery?.id == d.id
                                      ? AppColors.accentColor
                                          .withOpacity(0.15)
                                      : AppColors.surfaceColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _selectedDelivery?.id == d.id
                                        ? AppColors.accentColor
                                        : AppColors.borderColor,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.route,
                                        size: 12,
                                        color: _selectedDelivery?.id == d.id
                                            ? AppColors.accentColor
                                            : AppColors.lightTextColor),
                                    const SizedBox(width: 4),
                                    AppText.medium('#${d.waybill}',
                                        fontSize: 11,
                                        color: _selectedDelivery?.id == d.id
                                            ? AppColors.accentColor
                                            : AppColors.textColor),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Zoom controls
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                _MapButton(
                    icon: Icons.fullscreen,
                    onTap: () => Get.to(
                      () => FullScreenRouteMap(
                        initialDelivery: _selectedDelivery,
                        initialRoute: _routePoints,
                      ),
                      transition: Transition.fade,
                    )),
                const SizedBox(height: 4),
                _MapButton(
                    icon: Icons.add,
                    onTap: () => _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1)),
                const SizedBox(height: 4),
                _MapButton(
                    icon: Icons.remove,
                    onTap: () => _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1)),
                const SizedBox(height: 4),
                _MapButton(
                    icon: Icons.my_location,
                    onTap: () =>
                        _mapController.move(_defaultCenter, 7.0)),
              ],
            ),
          ),

          // Loading indicator
          if (_loadingRoute)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primaryColorBackground,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accentColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppText.thin('Calculating route...',
                            fontSize: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Location info popup
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
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryColor[50],
                        child: Icon(Icons.location_on,
                            color: AppColors.primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText.bold(_selectedLocation!.name ?? '',
                                fontSize: 13),
                            AppText.thin(
                              '${_selectedLocation!.lga}, ${_selectedLocation!.state}',
                              fontSize: 11,
                              color: AppColors.lightTextColor,
                            ),
                            if ((_selectedLocation!.facilityType ?? '')
                                .isNotEmpty)
                              AppText.thin(
                                _selectedLocation!.facilityType!,
                                fontSize: 11,
                                color: AppColors.accentColor,
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _selectedLocation!.isActive
                              ? AppColors.green.withOpacity(0.15)
                              : AppColors.yellow.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppText.medium(
                          _selectedLocation!.isActive
                              ? 'Active'
                              : 'Inactive',
                          fontSize: 11,
                          color: _selectedLocation!.isActive
                              ? AppColors.green
                              : AppColors.yellow,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _selectedLocation = null),
                        child: Icon(Icons.close,
                            size: 18, color: AppColors.lightTextColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Route info popup
          if (_selectedDelivery != null && _routePoints.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: AppColors.primaryColorBackground,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.route,
                            color: AppColors.accentColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText.bold(
                                '#${_selectedDelivery!.waybill}',
                                fontSize: 13),
                            AppText.thin(
                              '${_selectedDelivery!.pickup ?? "?"} → ${_selectedDelivery!.stops.isNotEmpty ? _selectedDelivery!.stops.last : "?"}',
                              fontSize: 11,
                              color: AppColors.lightTextColor,
                              maxlines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppText.thin(
                              'Driver: ${_selectedDelivery!.driver ?? "N/A"}',
                              fontSize: 11,
                              color: AppColors.lightTextColor,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          _selectedDelivery = null;
                          _routePoints = [];
                        }),
                        child: Icon(Icons.close,
                            size: 18, color: AppColors.lightTextColor),
                      ),
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

class FullScreenRouteMap extends StatefulWidget {
  const FullScreenRouteMap({
    super.key,
    this.initialDelivery,
    this.initialRoute = const [],
  });
  final Delivery? initialDelivery;
  final List<LatLng> initialRoute;

  @override
  State<FullScreenRouteMap> createState() => _FullScreenRouteMapState();
}

class _FullScreenRouteMapState extends State<FullScreenRouteMap> {
  static const LatLng _defaultCenter = LatLng(10.5264, 7.4384);
  final MapController _mapController = MapController();
  final _dio = Dio();

  Delivery? _selectedDelivery;
  List<LatLng> _routePoints = [];
  bool _loadingRoute = false;

  @override
  void initState() {
    super.initState();
    _selectedDelivery = widget.initialDelivery;
    _routePoints = List.from(widget.initialRoute);
  }

  Location? _findLocation(String desc, List<Location> locations) {
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

  Future<void> _fetchRoute(LatLng from, List<LatLng> waypoints) async {
    setState(() { _loadingRoute = true; _routePoints = []; });
    try {
      final coords = [from, ...waypoints]
          .map((p) => '${p.longitude},${p.latitude}').join(';');
      final url = 'https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson';
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final coordsList = response.data['routes'][0]['geometry']['coordinates'] as List;
        setState(() {
          _routePoints = coordsList.map((c) => LatLng(
            (c[1] as num).toDouble(), (c[0] as num).toDouble())).toList();
        });
      }
    } catch (e) { print(e); }
    finally { setState(() => _loadingRoute = false); }
  }

  void _onDeliveryTap(Delivery delivery, List<Location> locations) {
    final pickup = _findLocation(delivery.pickup ?? '', locations);
    if (pickup == null || (pickup.lat ?? 0) == 0) return;
    final stopLocations = delivery.stops
        .map((s) => _findLocation(s, locations))
        .where((l) => l != null && (l.lat ?? 0) != 0)
        .map((l) => LatLng(l!.lat!, l.lng!)).toList();
    if (stopLocations.isEmpty) return;
    setState(() => _selectedDelivery = delivery);
    _fetchRoute(LatLng(pickup.lat!, pickup.lng!), stopLocations);
    _mapController.move(LatLng(pickup.lat!, pickup.lng!), 10.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final controller = Get.find<DashboardController>();
        final locations = controller.allLocation;
        final activeDeliveries = controller.allUndeliveredDeliveries;
        final locationsWithCoords = locations
            .where((l) => (l.lat ?? 0) != 0 && (l.lng ?? 0) != 0).toList();

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _routePoints.isNotEmpty
                    ? _routePoints.first : _defaultCenter,
                initialZoom: _routePoints.isNotEmpty ? 10.0 : 7.0,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.transborder.logistics',
                  maxZoom: 19,
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5,
                      color: AppColors.accentColor,
                      borderStrokeWidth: 2,
                      borderColor: AppColors.accentColor.withOpacity(0.3),
                    ),
                  ]),
                MarkerLayer(
                  markers: locationsWithCoords.map((loc) => Marker(
                    point: LatLng(loc.lat!, loc.lng!),
                    width: 32, height: 32,
                    child: Container(
                      decoration: BoxDecoration(
                        color: loc.isActive
                            ? AppColors.primaryColor.withOpacity(0.85)
                            : AppColors.yellow.withOpacity(0.85),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.location_on, color: Colors.white, size: 18),
                    ),
                  )).toList(),
                ),
                if (_routePoints.isNotEmpty)
                  MarkerLayer(markers: [
                    Marker(
                      point: _routePoints.first,
                      width: 44, height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.trip_origin, color: Colors.white, size: 22),
                      ),
                    ),
                    Marker(
                      point: _routePoints.last,
                      width: 44, height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.flag, color: Colors.white, size: 22),
                      ),
                    ),
                  ]),
              ],
            ),

            // Top bar
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                color: AppColors.primaryColorBackground.withOpacity(0.92),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8, right: 16, bottom: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.fullscreen_exit, color: AppColors.textColor),
                      onPressed: () => Get.back(),
                    ),
                    AppText.bold('Live Map', fontSize: 18),
                    const Spacer(),
                    if (_loadingRoute)
                      Row(children: [
                        SizedBox(width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentColor)),
                        const SizedBox(width: 8),
                        AppText.thin('Calculating route...', fontSize: 12),
                      ]),
                  ],
                ),
              ),
            ),

            // Active trips
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              left: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                color: AppColors.primaryColorBackground.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText.medium('Active Trips', fontSize: 11, color: AppColors.lightTextColor),
                      const SizedBox(height: 6),
                      ...activeDeliveries.take(8).map((d) => GestureDetector(
                        onTap: () => _onDeliveryTap(d, locations),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _selectedDelivery?.id == d.id
                                ? AppColors.accentColor.withOpacity(0.15)
                                : AppColors.surfaceColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedDelivery?.id == d.id
                                  ? AppColors.accentColor : AppColors.borderColor),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.route, size: 13,
                              color: _selectedDelivery?.id == d.id
                                  ? AppColors.accentColor : AppColors.lightTextColor),
                            const SizedBox(width: 5),
                            AppText.medium('#${d.waybill}', fontSize: 12,
                              color: _selectedDelivery?.id == d.id
                                  ? AppColors.accentColor : AppColors.textColor),
                          ]),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),

            // Zoom controls
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              right: 16,
              child: Column(children: [
                _MapButton(icon: Icons.add, onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1)),
                const SizedBox(height: 4),
                _MapButton(icon: Icons.remove, onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1)),
                const SizedBox(height: 4),
                _MapButton(icon: Icons.my_location, onTap: () => _mapController.move(_defaultCenter, 7.0)),
              ]),
            ),

            // Route info popup
            if (_selectedDelivery != null && _routePoints.isNotEmpty)
              Positioned(
                bottom: 16, left: 16, right: 16,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.primaryColorBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.route, color: AppColors.accentColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText.bold('#${_selectedDelivery!.waybill}', fontSize: 14),
                          AppText.thin(
                            '${_selectedDelivery!.pickup ?? "?"} → ${_selectedDelivery!.stops.isNotEmpty ? _selectedDelivery!.stops.last : "?"}',
                            fontSize: 12, color: AppColors.lightTextColor,
                            maxlines: 1, overflow: TextOverflow.ellipsis),
                          AppText.thin('Driver: ${_selectedDelivery!.driver ?? "N/A"}',
                            fontSize: 12, color: AppColors.lightTextColor),
                        ],
                      )),
                      GestureDetector(
                        onTap: () => setState(() { _selectedDelivery = null; _routePoints = []; }),
                        child: Icon(Icons.close, size: 20, color: AppColors.lightTextColor),
                      ),
                    ]),
                  ),
                ),
              ),
          ],
        );
      }),
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
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        AppText.thin(label, fontSize: 10),
      ],
    );
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
            child: Icon(icon, size: 20, color: AppColors.textColor)),
      ),
    );
  }
}