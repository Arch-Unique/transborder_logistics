import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/resource_history.dart';
import 'package:transborder_logistics/src/global/model/user.dart';
import 'package:transborder_logistics/src/global/ui/functions/ui_functions.dart';

import '../repository/app_repo.dart';

class DashboardController extends GetxController {
  RxList<User> allCustomers = <User>[].obs;
  RxList<User> allDrivers = <User>[].obs;
  RxList<User> allAdmins = <User>[].obs;
  RxList<User> allOperators = <User>[].obs;

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
  Rx<ResourceHistory> curResourceHistory = ResourceHistory(title: "Dashboard", filters: [], items: []).obs;

  RxInt curMode = 0.obs;
  final appRepo = Get.find<AppRepo>();
  final isLoading = false.obs;

  Future<void> initApp() async {
    try {
      isLoading.value = true;
      await getAllCustomerDelivery();
      await getAllCustomers();
      await getLocations();
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
    return allDeliveries.where((delivery) => !delivery.isDelivered).toList();
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

  Future<bool> getCustomerDelivery() async {
    final c = await appRepo.getCustomersDelivery();

    allDeliveries.value = c;
    if (c.isEmpty) return true;
    _sortByDateTime(allDeliveries);
    return true;
  }

  Future startDelivery(int id) async {
    final dm = undeliveredDeliveries.where((test) => test.id == id).firstOrNull;
    if (dm == null) {
      return Ui.showError("An Error occurred, please try again");
    }
    await appRepo.startDelivery(id, dm.waybill, dm.driverId);
  }

  Future stopDelivery(int id, int i, String pic) async {
    final dm = undeliveredDeliveries.where((test) => test.id == id).firstOrNull;
    if (dm == null) {
      return Ui.showError("An Error occurred, please try again");
    }
    var sd = List.from(dm.stopsDate);
    List<String?> ssd = [];
    if (sd.isEmpty) {
      ssd = List.generate(dm.stops.length, (j) => null);
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
    }
    List<String?> pics = List.from(dm.stops);

    ssd[i] = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    pics[i] = pic;
    await appRepo.stopDelivery(id, dm.waybill, dm.driverId, ssd, pics);
  }

  Future<bool> resetPassword(password) async {
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
    String phone,
    String role,
    String address, {
    String? truckno,
  }) async {
    return await appRepo.addUser(
      fullname,
      address,
      phone,
      role,
      truckno: truckno,
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
    String phone,
    String role,
    String address,
    int id, {
    String? truckno,
  }) async {
    return await appRepo.editUser(
      fullname,
      address,
      phone,
      role,
      id,
      truckno: truckno,
    );
  }

  //location
  Future<bool> addLocation(String name, String state, String lga) async {
    return await appRepo.addLocation(name, state, lga);
  }

  Future<bool> deleteLocation(int id) async {
    return await appRepo.deleteLocation(id);
  }

  Future<bool> addDelivery(
    String waybill,
    String loc,
    int driver,
    String pickup,
  ) async {
    return await appRepo.addDelivery(waybill, driver, loc, pickup);
  }

  Future<bool> deleteDelivery(int id) async {
    return await appRepo.deleteDelivery(id);
  }

  Future changeLocation(String v) async {
    curLoc.value = v;
    await initApp();
  }

  //filters
  void getFilters<T>(RxList<T> v, String s, String title) {
    if (T == Delivery) {
      if (s == "New") {
        v.value = List.from(undeliveredDeliveries);
      } else if (s == "Ongoing") {
        v.value = List.from(
          allDeliveries.where((test) => test.hasStarted).toList(),
        );
      } else if (s == "Completed") {
        v.value = List.from(
          allDeliveries.where((test) => test.isDelivered).toList(),
        );
      }
    } else if (T == User && title.toLowerCase() == "users") {
      if (s == "Driver") {
        v.value = List.from(allDrivers);
      } else if (s == "Admin") {
        v.value = List.from(allAdmins);
      } else if (s == "Operator") {
        v.value = List.from(allOperators);
      }
    } else if (T == User && title.toLowerCase() == "drivers") {
      if (s == "Available") {
        v.value = List.from(allDrivers);
      } else if (s == "Busy") {
        v.value = List.from(allDrivers);
      } else if (s == "Inactive") {
        v.value = List.from(allDrivers);
      }
    } else if (T == Location && title.toLowerCase() == "facilities") {
      if (s == "Active") {
        v.value = List.from(allLocation);
      } else if (s == "Inactive") {
        v.value = List.from(allLocation);
      }
    } else if (T == Location && title.toLowerCase() == "loading points") {
      if (s == "Active") {
        v.value = List.from(allLocation);
      } else if (s == "Inactive") {
        v.value = List.from(allLocation);
      }
    }
  }
}
