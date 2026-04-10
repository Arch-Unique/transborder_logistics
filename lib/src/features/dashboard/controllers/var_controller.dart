import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/models/var_data.dart';
import 'package:transborder_logistics/src/global/model/user.dart';
import 'package:transborder_logistics/src/global/services/barrel.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';
import 'package:transborder_logistics/src/src_barrel.dart';

import '../repository/app_repo.dart';

class VarController extends GetxController {
  // ── Integer ID selections (from dropdowns) ────────────────────────────────
  RxInt selectedDeliveryId = 0.obs;
  RxInt selectedDriverId = 0.obs;
  RxInt selectedVehicleId = 0.obs;
  RxInt selectedOriginId = 0.obs;
  RxInt selectedDestinationId = 0.obs;


  // ── Trip-specific fields ──────────────────────────────────────────────────
  RxString pickup = ''.obs;
  RxList<String> stops = <String>[].obs;
  RxString commodityType = 'Drug Revolving Fund (DRF)'.obs;
  final truckNo = TextEditingController();

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


  // ── Population helpers ──────────────────────────────────────────────────
  void populateFromTrip(Delivery d) {
    reset();
    selectedDeliveryId.value = d.id;
    
    pickup.value = d.pickup ?? '';
    stops.value = List.from(d.stops);
    commodityType.value = d.commodityType ?? '';
    truckNo.text = d.truckno ?? '';

    final dashCtrl = Get.find<DashboardController>();
    if (d.driver != null) {
      final driver = dashCtrl.allDrivers.firstWhereOrNull((e) => e.name == d.driver);
      if (driver != null) selectedDriverId.value = driver.id;
    }
    if (d.truckno != null) {
      final vehicle = dashCtrl.allVehicles.firstWhereOrNull((e) => e.desc == d.truckno);
      if (vehicle != null) selectedVehicleId.value = vehicle.id;
    }

    final loc = dashCtrl.allLoadingPoints.firstWhereOrNull(
                (e) => e.desc == d.pickup,
              );
    selectedOriginId.value = loc?.id ?? 0;

    final loc2 = dashCtrl.allFacilities.firstWhereOrNull(
                (e) => e.desc == d.stops.last,
               );
    selectedDestinationId.value = loc2?.id ?? 0;
  }

  void populateFromVar(VarRecord v) {
    reset();
    selectedDeliveryId.value = v.deliveryid;
    selectedDriverId.value = v.driverid;
    selectedVehicleId.value = v.vehicleid;
    selectedOriginId.value = v.originid;
    selectedDestinationId.value = v.destinationid;
    jobOrderNo.text = v.joborderno;
    dateOfArrival.text = v.dateofarrival;
    temperatureRange.value = v.temperaturerange.isNotEmpty ? v.temperaturerange : '+2\u00b0C to +8\u00b0C';

    dispatchedBy.text = v.signOff.dispatchedBy;
    deliveredBy.text = v.signOff.deliveredBy;
    receivedBy.text = v.signOff.receivedBy;

    if (v.commodityDetails.isNotEmpty) {
      commodityRows.clear();
      for (final req in v.commodityDetails) {
        final row = List.generate(6, (_) => TextEditingController());
        row[0].text = req.vaccine;
        row[1].text = req.batchNo;
        row[2].text = req.expiryDate;
        row[3].text = req.qtyDispatched;
        row[4].text = req.qtyReceived;
        row[5].text = req.vvmStatus;
        commodityRows.add(row);
      }
    }

    if (v.temperatureMonitoring.isNotEmpty) {
      tempRows.clear();
      for (final req in v.temperatureMonitoring) {
        final row = List.generate(3, (_) => TextEditingController());
        row[0].text = req.monitoringPoint;
        row[1].text = req.temperatureCelsius;
        row[2].text = req.dateTime;
        tempRows.add(row);
      }
    }

    if (v.reverseLogistics.isNotEmpty) {
      reverseRows.clear();
      showReverseLogistics.value = true;
      for (final req in v.reverseLogistics) {
        final row = List.generate(4, (_) => TextEditingController());
        row[0].text = req.item;
        row[1].text = req.quantity;
        row[2].text = req.condition;
        row[3].text = req.destination;
        reverseRows.add(row);
      }
    }

    final dashCtrl = Get.find<DashboardController>();

    // Resolve origin display name from ID
    if (v.originid != 0) {
      final originLoc = dashCtrl.allLoadingPoints.firstWhereOrNull(
        (e) => e.id == v.originid,
      ) ?? dashCtrl.allLocation.firstWhereOrNull((e) => e.id == v.originid);
      if (originLoc != null) {
        pickup.value = originLoc.desc;
      } else if (v.originName.isNotEmpty) {
        pickup.value = v.originName;
      }
    }

    // Resolve destination display name from ID and set as stops[0]
    if (v.destinationid != 0) {
      final destLoc = dashCtrl.allFacilities.firstWhereOrNull(
        (e) => e.id == v.destinationid,
      ) ?? dashCtrl.allLocation.firstWhereOrNull((e) => e.id == v.destinationid);
      final destName = destLoc?.desc ?? (v.destinationName.isNotEmpty ? v.destinationName : '');
      if (destName.isNotEmpty) stops.value = [destName];
    }

    // Search both admin and driver delivery lists
    final delivery = dashCtrl.allDeliveries.firstWhereOrNull(
          (d) => d.id == v.deliveryid,
        ) ??
        dashCtrl.allCustomerDeliveries.firstWhereOrNull(
          (d) => d.id == v.deliveryid,
        );
    if (delivery != null) {
      // Only override if not yet populated from ID lookup
      if (pickup.value.isEmpty) pickup.value = delivery.pickup ?? '';
      if (stops.isEmpty || (stops.length == 1 && stops.first.isEmpty)) {
        stops.value = List.from(delivery.stops);
      }
      commodityType.value = delivery.commodityType ?? commodityType.value;
      truckNo.text = delivery.truckno ?? '';
    }

  }

  // ── Admin Actions ─────────────────────────────────────────────────────────
  Future<bool> createVar(Map<String, dynamic> extraTripData) async {
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

      final payload = {
        ...extraTripData,
        ...data.toJson(),
      };

      final appRepo = Get.find<AppRepo>();
      final success = await appRepo.createVar(payload);

      if (success) {
        Ui.showInfo('VAR and Trip created successfully.', title: 'Success');
        reset();
        // await fetchVars();
        return true;
      } else {
        Ui.showError('Creation failed. Please try again.', title: 'Error');
        return false;
      }
    } catch (e) {
      Ui.showError('An error occurred: ${e.toString()}', title: 'Error');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateVar(int id, Map<String, dynamic> extraTripData) async {
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

      final payload = {
        ...extraTripData,
        ...data.toJson(),
      };

      final appRepo = Get.find<AppRepo>();
      final success = await appRepo.updateVar(id, payload);

      if (success) {
        Ui.showInfo('VAR updated successfully.', title: 'Success');
        reset();
        // await fetchVars();
        return true;
      } else {
        Ui.showError('Update failed. Please try again.', title: 'Error');
        return false;
      }
    } catch (e) {
      Ui.showError('An error occurred: ${e.toString()}', title: 'Error');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> closeVar(int id) async {
    try {
      Ui.showInfo("Closing...", title: "In Progress");
      final appRepo = Get.find<AppRepo>();
      final success = await appRepo.closeVar(id);
      
      if (success) {
        Ui.showInfo('VAR closed successfully.', title: 'Success');
        // await fetchVars();
      } else {
        Ui.showError('Failed to close VAR.', title: 'Error');
      }
    } catch (e) {
      Ui.showError('An error occurred: ${e.toString()}', title: 'Error');
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
    selectedDeliveryId.value = 0;
    selectedDriverId.value = 0;
    selectedVehicleId.value = 0;
    selectedOriginId.value = 0;
    selectedDestinationId.value = 0;
    jobOrderNo.clear();
    dateOfArrival.clear();
    truckNo.clear();
    pickup.value = '';
    stops.clear();
    commodityType.value = '';
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
    truckNo.dispose();
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
