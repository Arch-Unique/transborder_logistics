import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/models/var_data.dart';
import 'package:transborder_logistics/src/features/dashboard/views/driver/var_review_screen.dart';
import 'package:transborder_logistics/src/global/model/user.dart';
import 'package:transborder_logistics/src/global/services/barrel.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';
import 'package:transborder_logistics/src/src_barrel.dart';

class VarController extends GetxController {
  // ── Integer ID selections (from dropdowns) ────────────────────────────────
  RxInt selectedDeliveryId = 0.obs;
  RxInt selectedDriverId = 0.obs;
  RxInt selectedVehicleId = 0.obs;
  RxInt selectedOriginId = 0.obs;
  RxInt selectedDestinationId = 0.obs;

  /// The delivery passed to [initFromDelivery]. The banner reads driver name,
  /// truck no., pickup, and stops directly from here instead of doing ID
  /// lookups in the dashboard lists (which may not be loaded in driver mode).
  Rx<Delivery?> activeDelivery = Rx<Delivery?>(null);

  // ── Text fields ───────────────────────────────────────────────────────────
  final jobOrderNo = TextEditingController();
  final dateOfArrival = TextEditingController();

  /// '+2°C to +8°C' or '-15°C to -25°C'
  RxString temperatureRange = '+2°C to +8°C'.obs;

  // ── Sign-off text controllers ─────────────────────────────────────────────
  final dispatchedBy = TextEditingController();
  final deliveredBy = TextEditingController();
  final receivedBy = TextEditingController();

  // ── Dynamic table state ───────────────────────────────────────────────────
  /// [vaccine, batchNo, expiryDate, qtyDispatched, qtyReceived, vvmStatus]
  RxList<List<TextEditingController>> commodityRows =
      <List<TextEditingController>>[].obs;

  /// [monitoringPoint, temperatureCelsius, dateTime]
  RxList<List<TextEditingController>> tempRows =
      <List<TextEditingController>>[].obs;

  /// [item, quantity, condition, destination]
  RxList<List<TextEditingController>> reverseRows =
      <List<TextEditingController>>[].obs;

  RxBool showReverseLogistics = false.obs;
  RxBool isSubmitting = false.obs;

  // ── Fetched VAR records ───────────────────────────────────────────────────
  RxList<VarRecord> allVars = <VarRecord>[].obs;
  RxBool isFetchingVars = false.obs;

  final apiService = Get.find<DioApiService>();

  // ── Commodity helpers ─────────────────────────────────────────────────────
  void addCommodityRow() {
    commodityRows.add(List.generate(6, (_) => TextEditingController()));
  }

  void removeCommodityRow(int index) {
    if (index < commodityRows.length) {
      for (final c in commodityRows[index]) {
        c.dispose();
      }
      commodityRows.removeAt(index);
    }
  }

  // ── Temp monitoring helpers ───────────────────────────────────────────────
  void addTempRow() {
    tempRows.add(List.generate(3, (_) => TextEditingController()));
  }

  void removeTempRow(int index) {
    if (index < tempRows.length) {
      for (final c in tempRows[index]) {
        c.dispose();
      }
      tempRows.removeAt(index);
    }
  }

  // ── Reverse logistics helpers ─────────────────────────────────────────────
  void addReverseRow() {
    reverseRows.add(List.generate(4, (_) => TextEditingController()));
  }

  void removeReverseRow(int index) {
    if (index < reverseRows.length) {
      for (final c in reverseRows[index]) {
        c.dispose();
      }
      reverseRows.removeAt(index);
    }
  }

  // ── Init from active trip ─────────────────────────────────────────────────
  /// Call this before showing the VAR popup. Populates all trip-context fields
  /// from the delivery that just ended so the driver doesn't re-enter them.
  void initFromDelivery(Delivery delivery, int driverId) {
    reset();
    activeDelivery.value = delivery;
    selectedDeliveryId.value = delivery.id;
    selectedDriverId.value = driverId;
    selectedVehicleId.value = delivery.vehicleId;

    // Resolve origin/destination IDs by matching pickup & last stop names
    // against the location master list (case-insensitive).
    final locations = Get.find<DashboardController>().allLocation;

    int resolveByName(String? name) {
      if (name == null || name.isEmpty) return 0;
      final lower = name.trim().toLowerCase();
      return locations
              .firstWhereOrNull((l) => l.desc.toLowerCase() == lower)
              ?.id ??
          0;
    }

    selectedOriginId.value = resolveByName(delivery.pickup);
    selectedDestinationId.value = delivery.stops.isNotEmpty
        ? resolveByName(delivery.stops.last)
        : 0;

    final now = DateTime.now();
    dateOfArrival.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void goToReview() {
    if (selectedDeliveryId.value == 0 ||
        dateOfArrival.text.trim().isEmpty ||
        commodityRows.isEmpty ||
        tempRows.isEmpty) {
      Ui.showError(
        'Please fill in the date of arrival and add at least one commodity and temperature record.',
        title: 'Incomplete Form',
      );
      return;
    }
    Get.to(() => VarReviewScreen());
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> submit() async {
    try {
      isSubmitting.value = true;

      final data = VarData(
        deliveryid: selectedDeliveryId.value,
        driverid: selectedDriverId.value,
        vehicleid: selectedVehicleId.value,
        originid: selectedOriginId.value,
        destinationid: selectedDestinationId.value,
        joborderno: jobOrderNo.text.trim(),
        dateofarrival: dateOfArrival.text.trim(),
        temperaturerange: temperatureRange.value,
        commodityDetails: commodityRows.map((row) {
          return CommodityRow(
            vaccine: row[0].text.trim(),
            batchNo: row[1].text.trim(),
            expiryDate: row[2].text.trim(),
            qtyDispatched: row[3].text.trim(),
            qtyReceived: row[4].text.trim(),
            vvmStatus: row[5].text.trim(),
          );
        }).toList(),
        temperatureMonitoring: tempRows.map((row) {
          return TempRecord(
            monitoringPoint: row[0].text.trim(),
            temperatureCelsius: row[1].text.trim(),
            dateTime: row[2].text.trim(),
          );
        }).toList(),
        reverseLogistics: showReverseLogistics.value && reverseRows.isNotEmpty
            ? reverseRows.map((row) {
                return ReverseLogisticsRow(
                  item: row[0].text.trim(),
                  quantity: row[1].text.trim(),
                  condition: row[2].text.trim(),
                  destination: row[3].text.trim(),
                );
              }).toList()
            : null,
        signOff: SignOff(
          dispatchedBy: dispatchedBy.text.trim(),
          deliveredBy: deliveredBy.text.trim(),
          receivedBy: receivedBy.text.trim(),
        ),
      );

      print(data.toJson());

      final res = await apiService.post(
        '${AppUrls.varURL}/submit',
        data: data.toJson(),
      );

      if (res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300) {
        Ui.showInfo('VAR submitted successfully.', title: 'Success');
        reset();
        // Pop both review and form screens
        Get.back();
        Get.back();
      } else {
        final msg =
            res.data?['error'] ?? 'Submission failed. Please try again.';
        Ui.showError(msg.toString(), title: 'Error');
      }
    } catch (e) {
      Ui.showError('An error occurred: ${e.toString()}', title: 'Error');
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Fetch VAR list ────────────────────────────────────────────────────────
  Future<void> fetchVars() async {
    try {
      isFetchingVars.value = true;
      final res = await apiService.get(AppUrls.varURL);
      if (res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300) {
        final raw = res.data;
        List<dynamic> list = [];
        if (raw is List) {
          list = raw;
        } else if (raw is Map && raw['data'] is List) {
          list = raw['data'] as List;
        }
        allVars.value = list
            .map((e) => VarRecord.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (e) {
      // silently fail — list stays empty
    } finally {
      isFetchingVars.value = false;
    }
  }

  // ── Reset ─────────────────────────────────────────────────────────────────
  void reset() {
    activeDelivery.value = null;
    selectedDeliveryId.value = 0;
    selectedDriverId.value = 0;
    selectedVehicleId.value = 0;
    selectedOriginId.value = 0;
    selectedDestinationId.value = 0;
    jobOrderNo.clear();
    dateOfArrival.clear();
    dispatchedBy.clear();
    deliveredBy.clear();
    receivedBy.clear();
    temperatureRange.value = '+2°C to +8°C';
    showReverseLogistics.value = false;

    for (final row in commodityRows) {
      for (final c in row) {
        c.dispose();
      }
    }
    commodityRows.clear();

    for (final row in tempRows) {
      for (final c in row) {
        c.dispose();
      }
    }
    tempRows.clear();

    for (final row in reverseRows) {
      for (final c in row) {
        c.dispose();
      }
    }
    reverseRows.clear();

    addCommodityRow();
    addTempRow();
  }

  @override
  void onInit() {
    super.onInit();
    addCommodityRow();
    addTempRow();
  }

  @override
  void onClose() {
    jobOrderNo.dispose();
    dateOfArrival.dispose();
    dispatchedBy.dispose();
    deliveredBy.dispose();
    receivedBy.dispose();
    for (final row in commodityRows) {
      for (final c in row) {
        c.dispose();
      }
    }
    for (final row in tempRows) {
      for (final c in row) {
        c.dispose();
      }
    }
    for (final row in reverseRows) {
      for (final c in row) {
        c.dispose();
      }
    }
    super.onClose();
  }
}
