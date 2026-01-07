import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:transborder_logistics/src/features/auth/controllers/excel.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/resource_history.dart';
import 'package:transborder_logistics/src/global/model/user.dart';
import 'package:transborder_logistics/src/global/ui/functions/ui_functions.dart';
import 'package:transborder_logistics/src/src_barrel.dart';
import 'package:transborder_logistics/src/utils/constants/string/facilities.dart';

import '../repository/app_repo.dart';

class DashboardController extends GetxController {
  RxList<User> allCustomers = <User>[].obs;
  RxList<User> allDrivers = <User>[].obs;
  RxList<User> allAdmins = <User>[].obs;
  RxList<User> allOperators = <User>[].obs;
  RxList<Vehicle> allVehicles = <Vehicle>[].obs;

  RxList<Delivery> allDeliveries = <Delivery>[].obs;
  RxList<Location> allLocation = <Location>[].obs;
  RxList<Delivery> allCustomerDeliveries = <Delivery>[].obs;
  Rx<Delivery> currentDelivery = Delivery(createdAt: DateTime.now()).obs;
  RxString curLoc = "All".obs;

  RxInt curPaginatorPage = 1.obs;
  RxInt curPaginatorTotal = 1.obs;
  RxInt curPaginatorTotalPages = 1.obs;
  RxInt curPaginatorRows = 10.obs;
  RxString curQuery = "".obs;
  RxInt curDashboardIndex = 0.obs;
  Rx<ResourceHistory> curResourceHistory = ResourceHistory(
    title: "Dashboard",
    filters: [],
    items: <Slugger>[],
  ).obs;

  RxInt curMode = 0.obs;
  Rx<Slugger> currentModel = User().obs;
  RxInt currentModelIndex = 0.obs;
  final appRepo = Get.find<AppRepo>();
  final isLoading = false.obs;

  void resetApp() {
    allCustomers.clear();
    allDrivers.clear();
    allAdmins.clear();
    allOperators.clear();
    allVehicles.clear();
    allDeliveries.clear();
    allLocation.clear();
    allCustomerDeliveries.clear();
    currentDelivery.value = Delivery(createdAt: DateTime.now());
    curLoc.value = "All";
    curPaginatorPage.value = 1;
    curPaginatorTotal.value = 1;
    curPaginatorTotalPages.value = 1;
    curPaginatorRows.value = 10;
    curQuery.value = "";
    curDashboardIndex.value = 0;
    curResourceHistory.value = ResourceHistory(
      title: "Dashboard",
      filters: [],
      items: [],
    );
    curMode.value = 0;
  }

  Future<void> initApp() async {
    try {
      isLoading.value = true;
      await getAllCustomerDelivery();
      await getAllCustomers();
      await getLocations();
      await getVehicles();
      isLoading.value = false;
    } catch (e) {
      // TODO
      print(e);
    }
  }

  void gotoNextPage() {
    //increase page
  }

  void gotoPreviousPage() {
    //decrease page
  }

  void gotoFirstPage() {
    //page = 1
  }

  void gotoLastPage() {
    //page = total
  }

  List<Delivery> get undeliveredDeliveries {
    return allDeliveries.where((delivery) => delivery.isNotDelivered).toList();
  }

  List<Delivery> get allUndeliveredDeliveries {
    return allCustomerDeliveries
        .where((delivery) => delivery.isNotDelivered)
        .toList();
  }

  List<Location> get allFacilities {
    return allLocation
        .where(
          (loc) =>
              loc.facilityType == "Hospital" || loc.facilityType == "Clinic",
        )
        .toList();
  }

  List<Location> get allLoadingPoints {
    return allLocation
        .where((loc) => loc.facilityType == "Loading Point")
        .toList();
  }

  List<User> get allUnavailableDrivers {
    return allDrivers
          .where((e) => allUndeliveredDeliveries.any((a) => a.driverId == e.id))
          .toList();
  }

  List<User> get allAvailableDrivers {
    return allDrivers.where((test) => !allUnavailableDrivers.contains(test)).toList();
  }

  Future<bool> getLocations() async {
    final c = await appRepo.getLocations();
    if (curLoc.value != "All" && curLoc.value.isNotEmpty) {
      c.removeWhere((test) => !(test.state?.contains(curLoc.value) ?? false));
    }
    allLocation.value = c;
    if (c.isEmpty) return true;
    return true;
  }

  Future<bool> getVehicles() async {
    final c = await appRepo.getVehicles();
    allVehicles.value = c;
    if (c.isEmpty) return true;
    return true;
  }

  Future<bool> getCustomerDelivery() async {
    final c = await appRepo.getCustomersDelivery();

    allDeliveries.value = c;
    if (c.isEmpty) return true;
    _sortByDateTime(allDeliveries);
    return true;
  }

  Future<bool> startDelivery(int id) async {
    final dm = undeliveredDeliveries.where((test) => test.id == id).firstOrNull;
    if (dm == null) {
      return Ui.showError("An Error occurred, please try again");
    }
    return await appRepo.startDelivery(id, dm.waybill, dm.driverId);
  }

  Future<bool> stopDelivery(
    int id,
    int i,
    String pic,
    String picName,
    String picContact,
    String sig,
  ) async {
    final dm = undeliveredDeliveries.where((test) => test.id == id).firstOrNull;
    if (dm == null) {
      return Ui.showError("An Error occurred, please try again");
    }
    var sd = List.from(dm.stopsDate);
    var oldPics = List.from(dm.picture);
    var oldrecv = List.from(dm.receiver);
    List<String?> ssd = [];
    List<String?> ops = [];
    List<List<String>?> ors = [];
    if (sd.isEmpty) {
      ssd = List.generate(dm.stops.length, (j) => null);
      ops = List.generate(dm.stops.length, (j) => null);
      ors = List.generate(dm.stops.length, (j) => null);
    } else {
      ssd = List.generate(dm.stops.length, (j) {
        try {
          return (sd[j] == null || sd[j] == "" || sd[j] == "null")
              ? null
              : DateFormat("yyyy-MM-dd HH:mm:ss").format(sd[j]);
        } catch (e) {
          return null;
        }
      });
      ops = List.generate(dm.stops.length, (j) {
        try {
          return (oldPics[j] == null ||
                  oldPics[j] == "" ||
                  oldPics[j] == "null")
              ? null
              : oldPics[j];
        } catch (e) {
          return null;
        }
      });
      ors = List.generate(dm.stops.length, (j) {
        try {
          return (oldrecv[j] == null ||
                  oldrecv[j] == "" ||
                  oldrecv[j] == "null")
              ? null
              : oldrecv[j];
        } catch (e) {
          return null;
        }
      });
    }
    List<String?> pics = List.from(ops);
    List<List<String>?> recvs = List.from(ors);

    ssd[i] = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    final upic = await uploadImage(pic);
    final usig = await uploadImage(sig);
    pics[i] = upic;
    recvs[i] = [picName, picContact, usig ?? ""];
    return await appRepo.stopDelivery(
      id,
      dm.waybill,
      dm.driverId,
      ssd,
      pics,
      recvs,
    );
  }

  Future<bool> resetPassword(String password) async {
    final c = await appRepo.resetPassword(password);

    return c;
  }

  Future<bool> getAllCustomerDelivery() async {
    final c = await appRepo.getAllCustomersDelivery();
    if (curLoc.value != "All" && curLoc.value.isNotEmpty) {
      c.removeWhere((test) => !test.stops.join(",").contains(curLoc.value));
    }
    allCustomerDeliveries.value = c;
    if (c.isEmpty) return true;
    _sortByDateTime(allCustomerDeliveries);
    return true;
  }

  Future<bool> getAllCustomers() async {
    allCustomers.value = await appRepo.getUsers();
    if (curLoc.value != "All" && curLoc.value.isNotEmpty) {
      allCustomers.removeWhere(
        (test) => !(test.location?.contains(curLoc.value) ?? true),
      );
    }
    allCustomers.removeWhere((test) => test.role == "customer");
    allDrivers.value = allCustomers
        .where((test) => test.role == "driver")
        .toList();
    allOperators.value = allCustomers
        .where((test) => test.role == "operator")
        .toList();
    allAdmins.value = allCustomers.where((test) => test.isAdmin).toList();
    return true;
  }

  void _sortByDateTime(List<Delivery> dlv) {
    dlv.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  //users
  Future<bool> addUser(
    String fullname,
    String email,
    String phone,
    String role,
    String address, {
    String? truckno,
    String? image,
  }) async {
    if (image != null) {
      image = await uploadImage(image);
    }
    return await appRepo.addUser(
      fullname,
      address,
      phone,
      role,
      email,
      truckno: truckno,
      image: image,
    );
  }

  Future<bool> deleteUser(int id) async {
    return await appRepo.deleteUser(id);
  }

  Future<String?> uploadImage(String imagePath) async {
    return await appRepo.uploadPhoto(imagePath);
  }

  Future<bool> editUser(
    String fullname,
    String email,
    String phone,
    String role,
    String address,
    int id, {
    String? truckno,
    String? image,
  }) async {
    if (image != null) {
      image = await uploadImage(image);
    }
    return await appRepo.editUser(
      fullname,
      address,
      phone,
      role,
      id,
      email,
      truckno: truckno,
      image: image,
    );
  }

  //location
  Future<bool> addLocation(
    String name,
    String state,
    String lga,
    String type,
    String code,
  ) async {
    return await appRepo.addLocation(name, state, lga, type, code);
  }

  Future<bool> editLocation(
    String name,
    String state,
    String lga,
    String type,
    String code,
    int id,
  ) async {
    return await appRepo.updateLocation(name, state, lga, type, code, id);
  }

  Future<bool> deleteLocation(int id) async {
    return await appRepo.deleteLocation(id);
  }

  Future<bool> addDelivery(
    String waybill,
    List<String> loc,
    int driver,
    int vehicle,
    String pickup,
    String truckno,
    String invoiceno,
  ) async {
    return await appRepo.addDelivery(
      waybill,
      driver,
      vehicle,
      loc,
      pickup,
      truckno,
      invoiceno,
    );
  }

  Future<bool> deleteDelivery(int id) async {
    return await appRepo.deleteDelivery(id);
  }

  Future<String> generateWayBill(bool isKano) async {
    final lastId = await appRepo.getLastDeliveryID();
    final sd = DateFormat("MM/yy").format(DateTime.now());
    return "TBL/${isKano ? "KN" : "KD"}/$sd/${(lastId + 1).toString().padLeft(4, "0")}";
  }

  Future changeLocation(String v) async {
    curLoc.value = v;
    await initApp();
  }

  Future exportData() async {
    try {
      List<Slugger> allItems = curResourceHistory.value.items;
      final a = allItems[0];
      final f = await generateExcelReport(
        reportTitle:
            "Transborder Logistics ${curResourceHistory.value.title} Report",
        data: allItems
            .map((e) => Map.fromIterables(a.tableTitle, e.tableValue))
            .toList(),
        columnsToInclude: a.tableTitle,
        columnHeaders: Map.fromIterables(a.tableTitle, a.tableTitle),
      );
      if (f == null) {
        return Ui.showError("Failed to generate report");
      }
      return Ui.showInfo("Export saved to:\n$f");
    } catch (e) {
      Ui.showError("No data available to export");
    }
  }

  //filters
  void getFilters<T>(RxList<T> v, String s, String title) {
    if (title.toLowerCase() == "trips") {
      // if (s == "New") {
      //   v.value = List.from(
      //     allCustomerDeliveries
      //         .where((test) => !test.hasStarted && !test.isDelivered)
      //         .toList(),
      //   );
      // } else
      if (s == "In Progress") {
        v.value = List.from(
          allCustomerDeliveries.where((test) => test.isNotDelivered).toList(),
        );
      } else if (s == "Completed") {
        v.value = List.from(
          allCustomerDeliveries.where((test) => test.isDelivered).toList(),
        );
      } else if (s == "Cancelled") {
        v.value = List.from(
          allCustomerDeliveries.where((test) => test.isCanceled).toList(),
        );
      }
    } else if (title.toLowerCase() == "drivertrips") {
      // if (s == "New") {
      //   v.value = List.from(
      //     allDeliveries
      //         .where((test) => !test.hasStarted && !test.isDelivered)
      //         .toList(),
      //   );
      // } else
      if (s == "In Progress") {
        v.value = List.from(
          allDeliveries.where((test) => test.isNotDelivered).toList(),
        );
      } else if (s == "Completed") {
        v.value = List.from(
          allDeliveries.where((test) => test.isDelivered).toList(),
        );
      } else if (s == "Cancelled") {
        v.value = List.from(
          allDeliveries.where((test) => test.isCanceled).toList(),
        );
      }
    } else if (title.toLowerCase() == "users") {
      if (s == "Driver") {
        v.value = List.from(allDrivers);
      } else if (s == "Admin") {
        v.value = List.from(allAdmins);
      } else if (s == "Operator") {
        v.value = List.from(allOperators);
      }
    } else if (title.toLowerCase() == "drivers") {
      if (s == "Available") {
        v.value = List.from(allAvailableDrivers);
      } else if (s == "Busy") {
        v.value = List.from(allUnavailableDrivers);
      }
      // else if (s == "Inactive") {
      //   v.value = List.from(allDrivers);
      // }
    } else if (title.toLowerCase() == "facilities") {
      if (s == "Active") {
        v.value = List.from(allFacilities);
      } else if (s == "Inactive") {
        v.value = List.from(allFacilities);
      }
    } else if (title.toLowerCase() == "loading points") {
      if (s == "Active") {
        v.value = List.from(allLoadingPoints);
      } else if (s == "Inactive") {
        v.value = List.from(allLoadingPoints);
      }
    }
    // v.refresh();
  }

  void refreshResource() {
    if (curResourceHistory.value.title == DashboardMode.trips.name) {
      curResourceHistory.value.items = allCustomerDeliveries;
    } else if (curResourceHistory.value.title == DashboardMode.users.name) {
      curResourceHistory.value.items = allCustomers;
    } else if (curResourceHistory.value.title == DashboardMode.drivers.name) {
      curResourceHistory.value.items = allDrivers;
    } else if (curResourceHistory.value.title == DashboardMode.location.name) {
      curResourceHistory.value.items = List.from(
        States.states.indexed.map((t) {
          final (index, e) = t;
          return StateLocation(id: index+1,name: e, isActive: e == "Kano" || e == "Kaduna");
        }),
      );
    } else if (curResourceHistory.value.title ==
        DashboardMode.facilities.name) {
      curResourceHistory.value.items = allFacilities;
    } else if (curResourceHistory.value.title == DashboardMode.pickups.name) {
      curResourceHistory.value.items = allLoadingPoints;
    } else if (curResourceHistory.value.title == DashboardMode.vehicles.name) {
      curResourceHistory.value.items = allVehicles;
    } else {
      curResourceHistory.value.items = [];
    }
    curResourceHistory.refresh();
  }
}
