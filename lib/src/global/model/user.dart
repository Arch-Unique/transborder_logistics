import 'dart:convert';

import 'package:intl/intl.dart';

abstract class Slugger {
  final String slug;
  final String rawId;
  final List<String> tableTitle;
  final List<String> tableValue;

  final Map<String, String> fields;

  Slugger(this.slug, this.tableTitle, this.tableValue, this.rawId, this.fields);
}

class User implements Slugger {
  int id;
  String? phone;
  String? email;
  String? name, location, truckno, image;
  String role,category;

  User({
    this.id = 0,
    this.phone,
    this.location,
    this.name,
    this.email,
    this.truckno,
    this.image,
    this.role = "",
    this.category="",
  });

  bool get isAdmin => role == "admin" || role == "operator";
  bool get isSuperAdmin => role == "admin";
  bool get isStaff => role == "admin" || role == "user";

  @override
  List<String> get tableTitle => [
    "Id",
    "Name",
    "Phone",
    "Location",
    "Role",
    "Email",
  ];

  @override
  List<String> get tableValue => [
    id.toString(),
    name ?? "",
    phone ?? "",
    location ?? "",
    role,
    email ?? "",
  ];

  @override
  String get slug => "$name,$phone,$email,$location,$truckno,$role,$category";

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      phone: json["phone"],
      role: json["role"],
      image: json["image"],
      location: json["address"],
      category: json["category"],
      name: json["fullname"],
      email: json["email"],
      truckno: json["truckno"],
    );
  }

  @override
  String get rawId => "#$id";

  @override
  Map<String, String> get fields {
    return {
      "Id": id.toString(),
      "Full Name": name ?? "",
      "Role": role,
      "Phone": phone ?? "",
      "Email": email ?? "",
      "Location": location ?? "",
  "Category": category,
    };
  }
}

class Location implements Slugger {
  int id;
  String? name;
  String? lga;
  String? state, code;
  String? facilityType;
  bool isActive;
  String? address, phone;
  double? lat, lng;

  Location({
    this.id = 0,
    this.name = "",
    this.lga = "",
    this.state = "",
    this.code = "",
    this.facilityType = "",
    this.address,
    this.phone,
    this.lat,
    this.lng,
    this.isActive = true,
  });

  String get desc => "$name, $lga, $state";

  @override
  List<String> get tableTitle => [
    "Id",
    "Name",
    "Code",
    "Status",
    "LGA",
    "State",
  ];

  @override
  List<String> get tableValue => [
    rawId,
    name ?? "",
    code ?? "",
    isActive ? "Active" : "Inactive",
    lga ?? "",
    state ?? "",
  ];

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json["id"],
      lga: json["lga"],
      state: json["state"],
      name: json["name"],
      code: json["code"],
      isActive: json["isactive"],
      facilityType: json["type"] ?? "Hospital",
      address: json["address"],
      phone: json["phone"],
      lat: json["lat"] != null ? double.tryParse(json["lat"].toString()) : 0,
      lng: json["lng"] != null ? double.tryParse(json["lng"].toString()) : 0,
    );
  }

  @override
  String get slug => "$desc,${isActive ? "Active" : "Inactive"}";

  @override
  String get rawId => "#$id";

  @override
  Map<String, String> get fields {
    return {
      "Id": id.toString(),
      "Name": name ?? "",
      "LGA": lga ?? "",
      "State": state ?? "",
      "Status": isActive ? "Active" : "Inactive",
      "Facility Type": facilityType ?? "",
      "Code": code ?? "",
      "Address": address ?? "",
      "Phone": phone ?? "",
      "Coordinates":
          "${lat != null ? lat.toString() : ""},${lng != null ? lng.toString() : ""}",
    };
  }
}

class StateLocation implements Slugger {
  int id;
  String? name, code;
  bool? isActive;

  StateLocation({
    this.id = 0,
    this.name = "",
    this.code = "",
    this.isActive = false,
  });

  String get desc => "$name, $code, $isActive";

  @override
  List<String> get tableTitle => ["Id", "Name", "Status"];

  @override
  List<String> get tableValue => [
    id.toString(),
    name ?? "",
    (isActive ?? false) ? "Active" : "Inactive",
  ];

  @override
  String get rawId => "#$id";

  factory StateLocation.fromJson(Map<String, dynamic> json) {
    return StateLocation(
      id: json["id"],
      name: json["name"],
      code: json["code"],
      isActive: json["isactive"] ?? false,
    );
  }

  @override
  Map<String, String> get fields {
    return {
      "Id": id.toString(),
      "Status": (isActive ?? false) ? "Active" : "Inactive",
      "Name": name ?? "",
      "Code": code ?? "",
    };
  }

  @override
  String get slug => desc;
}

class Vehicle implements Slugger {
  int id;
  String? name, regno, type;
  String? image, driver, category;
  bool isActive;

  Vehicle({
    this.id = 0,
    this.name = "",
    this.regno = "",
    this.type = "",
    this.image = "",
    this.driver = "",
    this.category = "",
    this.isActive = true,
  });

  String get desc => "$name $regno $type";

  @override
  List<String> get tableTitle => [
    "Id",
    "Make & Model",
    "Truck No",
    "Type",
    "Status",
    "Driver",
  ];

  @override
  List<String> get tableValue => [
    rawId,
    name ?? "",
    regno ?? "",
    type ?? "",
    isActive ? "Active" : "Inactive",
    driver ?? "N/A",
  ];

  @override
  String get rawId => "#$id";

  @override
  Map<String, String> get fields {
    return {
      "Id": id.toString(),
      "Make & Model": name ?? "",
      "Plate No": regno ?? "",
      "Type": type ?? "",
      "Status": isActive ? "Active" : "Inactive",
      "Category": category ?? "N/A",
      "Assigned Driver": driver ?? "N/A",
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json["id"],
      name: json["name"],
      regno: json["regno"],
      type: json["type"],
      image: json["image"],
      isActive: json["isactive"],
      category: json["category"],
      driver: json["driver"],
    );
  }

  @override
  String get slug =>
      "$desc,${isActive ? "Active" : "Inactive"},${driver ?? "N/A"},$category";
}

class Delivery implements Slugger {
  int id;
  int driverId, ownerId, vehicleId;
  String? driver, owner, truckno;
  String waybill;
  DateTime? startDate;
  DateTime createdAt;
  List<String> stops, picture;
  List<DateTime?> stopsDate;
  List<List<String>> items;
  List<List<String>?> receiver;
  double amt;
  bool isCanceled;
  String? pickup, pickupName, pickupContact, pickupSignature, invoiceno;
  String? commodityType, deliveryType;

  static const nv = [null, "", "[]", [], "null"];

  bool get isDelivered =>
      stopsDate.isNotEmpty &&
      stopsDate.length == stops.length &&
      !stopsDate.any((e) => nv.contains(e)) &&
      !isCanceled;
  bool get isNotDelivered =>
      !(stopsDate.isNotEmpty &&
          stopsDate.length == stops.length &&
          !stopsDate.any((e) => nv.contains(e))) &&
      !isCanceled;
  bool get hasStarted =>
      startDate != null && startDate!.isBefore(DateTime.now()) && !isCanceled;
  bool get hasNotStarted =>
      !(startDate != null && startDate!.isBefore(DateTime.now())) &&
      !isCanceled;
  String get start => startDate == null
      ? ""
      : DateFormat("dd/MM/yyyy hh:mm:aa").format(startDate!);
  String get created => DateFormat("dd/MM/yyyy hh:mm:aa").format(createdAt);
  List<String?> get formattedStopsDate => stopsDate
      .map(
        (e) => e == null ? null : DateFormat("dd/MM/yyyy hh:mm:aa").format(e),
      )
      .toList();

  List<String> get undeliveredStops {
    List<String> g = List.from(stops);
    final h = List.from(formattedStopsDate);
    return h.isEmpty
        ? stops
        : g.map((e) => (nv.contains(h[g.indexOf(e)])) ? e : "").toList();
  }

  @override
  String get rawId => "#$waybill";

  @override
  List<String> get tableTitle => [
    "Waybill",
    "Pickup",
    "Stops",
    "Creator",
    "Driver",
    "Status",
  ];

  String get status {
    String stats = "New";
    if (hasNotStarted) {
      stats = "New";
    } else if (isDelivered) {
      stats = "Completed";
    } else if (hasStarted && isNotDelivered) {
      stats = "Track";
    } else if (hasStarted && isNotDelivered) {
      stats = "In Progress";
    } else if (isCanceled) {
      stats = "Cancelled";
    }
    return stats;
  }

  @override
  List<String> get tableValue {
    return [
      waybill,
      pickup ?? "",
      stops.join(" , "),
      owner ?? "",
      driver ?? "",
      status,
    ];
  }

  @override
  String get slug =>
      "$waybill,$driver,$owner,$pickup,${stops.toString()},$truckno,${items.toString()},$status,$commodityType,$deliveryType";

  Delivery({
    this.id = 0,
    this.waybill = "0",
    this.driverId = 0,
    this.vehicleId = 0,
    this.picture = const [],
    this.driver,
    this.pickup,
    this.startDate,
    this.owner,
    this.amt = 0,
    this.truckno,
    this.ownerId = 0,
    this.isCanceled = false,
    this.stops = const [],
    this.stopsDate = const [],
    this.items = const [],
    this.receiver = const [],
    this.invoiceno = "",
    this.pickupName = "",
    this.pickupContact = "",
    this.pickupSignature = "",
    this.commodityType,
    this.deliveryType,
    required this.createdAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json["id"],
      waybill: json["waybill"],
      driverId: json["driverid"],
      vehicleId: json["vehicleid"] ?? 0,
      ownerId: json["ownerid"],
      pickup: json["pickup"],
      driver: json["drivername"],
      owner: json["ownername"],
      isCanceled: json["iscanceled"],
      pickupName: json["pickupname"],
      pickupContact: json["pickupphone"],
      pickupSignature: json["pickupsignature"],
      invoiceno: json["invoiceno"],
      amt: json["amount"] ?? 0,
      truckno: json["truckno"] ?? "",
      commodityType: json["commoditytype"],
      deliveryType: json["deliverytype"],
      
      picture: json["picture"] == null
          ? []
          : (jsonDecode(json["picture"]) as List<dynamic>?)
                    ?.map((e) => (e.toString()))
                    .toList() ??
                [],
      createdAt: DateTime.parse(json["createdat"]),
      startDate: DateTime.tryParse(json["startdate"] ?? ""),
      stops: json["stops"] == null
          ? []
          : (jsonDecode(json["stops"]) as List<dynamic>?)
                    ?.map((e) => (e.toString()))
                    .toList() ??
                [],
      items: json["items"] == null
          ? []
          : (jsonDecode(json["items"]) as List<dynamic>?)
                    ?.map(
                      (e) => (e as List<dynamic>)
                          .map((e) => e.toString())
                          .toList(),
                    )
                    .toList() ??
                [],
      receiver: json["receiver"] == null
          ? []
          : (jsonDecode(json["receiver"]) as List<dynamic>?)
                    ?.map(
                      (e) => (e == null || e == "" || e == "null")
                          ? null
                          : ((e as List<dynamic>)
                                .map((e) => e.toString())
                                .toList()),
                    )
                    .toList() ??
                [],
      stopsDate: json["stopsdate"] == null
          ? []
          : (jsonDecode(json["stopsdate"]) as List<dynamic>?)
                    ?.map(
                      (e) => (e == null || e == "" || e == "null")
                          ? null
                          : DateTime.parse(e),
                    )
                    .toList() ??
                [],
    );
  }

  @override
  Map<String, String> get fields {
    final stopsJoined = stops.isNotEmpty ? stops.join(", ") : "";
    final stopsDatesJoined = formattedStopsDate
        .map((e) => e ?? "")
        .where((e) => e.isNotEmpty)
        .join(", ");
    final itemsJoined = items.isNotEmpty
        ? items.map((it) => it.join(", ")).join("; ")
        : "";
    final picturesJoined = picture.isNotEmpty ? picture.join(", ") : "";

    return {
      "Waybill": waybill,
      "Owner": owner ?? "",
      "Driver": driver ?? "",
      "Truckno": truckno ?? "",
      "Pickup": pickup ?? "",
      "Stops": stopsJoined,
      "Created At": created,
      "Status": status,
      "Start Date": start,
      "Stops Dates": stopsDatesJoined,

      "End Date": isDelivered
          ? (formattedStopsDate.isNotEmpty ? formattedStopsDate.last ?? "" : "")
          : "",
      "Pictures": picturesJoined,
      "Commodity Type": commodityType ?? "",
      "Delivery Type": deliveryType ?? ""
    };
  }
}
