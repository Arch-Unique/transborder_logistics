import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:transborder_logistics/src/global/services/barrel.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';
import 'package:transborder_logistics/src/src_barrel.dart';

import '../../../global/model/user.dart';
import 'package:dio/dio.dart' as d;

class AppRepo extends GetxController {
  final apiService = Get.find<DioApiService>();

  final appService = Get.find<AppService>();

  Future<void> login(String email, String password) async {
    final res = await apiService.post(
      "${AppUrls.authURL}/login",
      data: {"email": email, "password": password, "userType": "user"},
      hasToken: false,
    );
    if (res.statusCode!.isSuccess()) {
      await appService.loginUser(
        res.data["data"]["jwt"],
        res.data["data"]["refresh"],
      );
    } else {
      throw res.data["error"];
    }
  }

  Future<User?> getUser() async {
    const uri = "${AppUrls.profileURL}/user/p";

    final res = await apiService.get(uri);
    if (res.statusCode!.isSuccess()) {
      final c = res.data["data"];
      User user = User.fromJson(c);
      return user;
    }

    return null;
  }

  Future<bool> forgotPassword(String email) async {
    const uri = "${AppUrls.authURL}/forgot-password";

    final res = await apiService.post(uri, data: {"email": email});

    if (res.statusCode!.isSuccess()) {
      return true;
    }

    return false;
  }

  Future<bool> resetPassword(String password) async {
    const uri = "${AppUrls.profileURL}/reset-password";

    final res = await apiService.post(uri, data: {"password": password});

    if (res.statusCode!.isSuccess()) {
      return true;
    }

    return false;
  }

  Future<bool> startDelivery(int id, String a, int c) async {
    final uri = "${AppUrls.deliveryURL}/deliveries/driver/$id";

    final res = await apiService.patch(
      uri,
      data: {
        "startdate": DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
        "waybill": a,
        "driverid": c,
      },
    );

    if (res.statusCode!.isSuccess()) {
      return true;
    }

    return false;
  }

  Future<bool> stopDelivery(
    int id,
    String a,
    int c,
    List<String?> sd,
    List<String?> pics,
    List<List<String>?> recv,
    
  ) async {
    final uri = "${AppUrls.deliveryURL}/deliveries/driver/$id";

    final res = await apiService.patch(
      uri,
      data: {
        "stopsdate": sd,
        "waybill": a,
        "driverid": c,
        "picture": pics,
        "receiver": recv
      },
    );

    if (res.statusCode!.isSuccess()) {
      return true;
    }

    return false;
  }

  Future<String?> uploadPhoto(String imagePath) async {
    final res = await apiService.post(
      "/upload/upload",
      data: d.FormData.fromMap({
        'type': 2,
        'file': await d.MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      }),
    );

    if (res.statusCode!.isSuccess()) {
      return res.data["data"];
    }
    return null;
  }

  Future<bool> addUser(
    String name,
    String location,
    String phone,
    String role,
    String email, {
    String? truckno,String? image
  }) async {
    const uri = "${AppUrls.profileURL}/user";
    final res = await apiService.post(
      uri,
      data: {
        "fullname": name,
        "address": location,
        "phone": phone,
        "role": role,
        "email": email,
        "truckno": truckno,
        if (image != null) "image": image
      },
    );
    return res.statusCode!.isSuccess();
  }

  Future<bool> editUser(
    String name,
    String location,
    String phone,
    String role,
    int id,
    String email, {
    String? truckno,String? image
  }) async {
    final uri = "${AppUrls.profileURL}/user/$id";

    final res = await apiService.patch(
      uri,
      data: {
        "fullname": name,
        "address": location,
        "phone": phone,
        "role": role,
        "truckno": truckno,
        "email": email,
        if (image != null) "image": image
      },
    );
    return res.statusCode!.isSuccess();
  }

  Future<bool> updateFCM(String fcm) async {
    final uri = "${AppUrls.profileURL}/user/${appService.currentUser.value.id}";

    final res = await apiService.patch(uri, data: {"fcmtoken": fcm});
    return res.statusCode!.isSuccess();
  }

  Future<bool> deleteUser(int id) async {
    final uri = "${AppUrls.profileURL}/user/$id";

    final res = await apiService.delete(uri);
    return res.statusCode!.isSuccess();
  }

  Future<List<User>> getUsers({String? id}) async {
    final uri =
        "${AppUrls.profileURL}/user${id == null ? "?page=1&pageSize=0" : "/$id"}";

    try {
      final res = await apiService.get(uri);
      List<User> users = [];
      if (res.statusCode!.isSuccess()) {
        final c = res.data["data"]["data"] as List;
        users.addAll(c.map<User>((e) => User.fromJson(e)));
      }
      return users;
    } catch (e) {
      return [];
    }
  }

  Future<List<Delivery>> getCustomersDelivery() async {
    const uri = "${AppUrls.profileURL}/delivery";

    final res = await apiService.get(uri);
    List<Delivery> delivery = [];
    if (res.statusCode!.isSuccess()) {
      final c = res.data["data"]["data"] as List;
      delivery.addAll(c.map<Delivery>((e) => Delivery.fromJson(e)));
      return delivery;
    }
    return delivery;
  }

  Future<int> getLastDeliveryID() async {
    const uri = "${AppUrls.deliveryURL}/last";

    final res = await apiService.get(uri);
    if (res.statusCode!.isSuccess()) {
      final c = res.data["data"] as int;

      return c;
    }
    return 0;
  }

  Future<bool> addLocation(
    String name,
    String state,
    String lga,
    String type,
    String code,
  ) async {
    const uri = "${AppUrls.utilsURL}/location";

    final res = await apiService.post(
      uri,
      data: {
        "name": name,
        "state": state,
        "lga": lga,
        "type": type,
        "code": code,
      },
    );
    return res.statusCode!.isSuccess();
  }

  Future<bool> updateLocation(
    String name,
    String state,
    String lga,
    String type,
    String code,
    int id,
  ) async {
    final uri = "${AppUrls.utilsURL}/location/$id";

    final res = await apiService.patch(
      uri,
      data: {
        "name": name,
        "state": state,
        "lga": lga,
        "type": type,
        "code": code,
      },
    );
    return res.statusCode!.isSuccess();
  }

  Future<bool> deleteLocation(int id) async {
    final uri = "${AppUrls.utilsURL}/location/$id";

    final res = await apiService.delete(uri);
    return res.statusCode!.isSuccess();
  }

  Future<List<Location>> getLocations() async {
    const uri = "${AppUrls.utilsURL}/location?page=1&pageSize=0";

    final res = await apiService.get(uri);
    List<Location> locations = [];
    if (res.statusCode!.isSuccess()) {
      final c = res.data["data"]["data"] as List;
      locations.addAll(c.map<Location>((e) => Location.fromJson(e)));
      return locations;
    }
    return locations;
  }

  Future<bool> addDelivery(
    String waybill,
    int driver,
    int vehicle,
    List<String> loc,
    String pickup,
    String truckno,
    String invoiceno,
  ) async {
    const uri = "${AppUrls.deliveryURL}/deliveries";

    final res = await apiService.post(
      uri,
      data: {
        "waybill": waybill,
        "driverid": driver,
        "vehicleid": vehicle,
        "ownerid": appService.currentUser.value.id,
        "stops": loc,
        "pickup": pickup,
        "truckno": truckno,
        "invoiceno": invoiceno,
      },
    );
    return res.statusCode!.isSuccess();
  }

  Future<bool> updateDelivery(
    String waybill,
    List<String> loc,
    int driver,
    int vehicle,
    String pickup,
    String truckno,
    String invoiceno,
    int id,
  ) async {
    final uri = "${AppUrls.deliveryURL}/deliveries/admin/$id";

    final res = await apiService.patch(
      uri,
      data: {
        "waybill": waybill,
        "driverid": driver,
        "vehicleid": vehicle,
        "ownerid": appService.currentUser.value.id,
        "stops": loc,
        "pickup": pickup,
        "truckno": truckno,
        "invoiceno": invoiceno,
      },
    );
    return res.statusCode!.isSuccess();
  }

  Future<bool> cancelDelivery(
    String waybill,
    int driver,
    int id,
  ) async {
    final uri = "${AppUrls.deliveryURL}/deliveries/admin/$id";

    final res = await apiService.patch(
      uri,
      data: {
        "waybill": waybill,
        "driverid": driver,
        "iscanceled": true
      },
    );
    return res.statusCode!.isSuccess();
  }

  Future<bool> deleteDelivery(int id) async {
    final uri = "${AppUrls.deliveryURL}/deliveries/$id";

    final res = await apiService.delete(uri);
    return res.statusCode!.isSuccess();
  }

  Future<List<Delivery>> getAllCustomersDelivery() async {
    const uri = "${AppUrls.deliveryURL}/deliveries?page=1&pageSize=0";

    final res = await apiService.get(uri);
    List<Delivery> delivery = [];
    if (res.statusCode!.isSuccess()) {
      final c = res.data["data"]["data"] as List;
      delivery.addAll(c.map<Delivery>((e) => Delivery.fromJson(e)));
      return delivery;
    }
    return delivery;
  }

  Future<List<Vehicle>> getVehicles() async {
    const uri = "${AppUrls.utilsURL}/vehicle?page=1&pageSize=0";

    final res = await apiService.get(uri);
    List<Vehicle> vehicles = [];
    if (res.statusCode!.isSuccess()) {
      final c = res.data["data"]["data"] as List;
      vehicles.addAll(c.map<Vehicle>((e) => Vehicle.fromJson(e)));
      return vehicles;
    }
    return vehicles;
  }

  Future<bool> addVehicle(
    String name,
    String regno,
    String type,
    bool isActive, {
    String? driver,String?  image,
    int? driverid,
  }) async {
    const uri = "${AppUrls.utilsURL}/vehicle";

    final res = await apiService.post(
      uri,
      data: {
        "name": name,
        "regno": regno,
        "type": type,
        "isactive": isActive,

        if (image != null) "image": image,
        if (driver != null) "driver": driver,
        if (driverid != null) "driverid": driverid,
      },
    );
    return res.statusCode!.isSuccess();
  }

  Future<bool> updateVehicle(
    String name,
    String regno,
    String type,
    bool isActive,
    int id, {
    String? driver,String?  image,
    int? driverid,
  }) async {
    final uri = "${AppUrls.utilsURL}/vehicle/$id";

    final res = await apiService.patch(
      uri,
      data: {
        "name": name,
        "regno": regno,
        "type": type,
        "isactive": isActive,

        if (image != null) "image": image,
        if (driver != null) "driver": driver,
        if (driverid != null) "driverid": driverid,
      },
    );
    return res.statusCode!.isSuccess();
  }

  Future<bool> deleteVehicle(int id) async {
    final uri = "${AppUrls.utilsURL}/vehicle/$id";

    final res = await apiService.delete(uri);
    return res.statusCode!.isSuccess();
  }
}
