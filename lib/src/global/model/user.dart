import 'dart:convert';

import 'package:intl/intl.dart';

abstract class Slugger {
  final String slug;

  Slugger(this.slug);
}

class User implements Slugger {
  int id;
  String? phone;
  String? email;
  String? name, location, truckno, image;
  String role;

  User({
    this.id = 0,
    this.phone,
    this.location,
    this.name,
    this.email,
    this.truckno,
    this.image,
    this.role = "",
  });

  bool get isAdmin => role == "admin";
  bool get isStaff => role == "admin" || role == "user";

  static List<String> get tableTitle => [
    "Name",
    "Phone",
    "Location",
    "Role",
    "TruckNo",
  ];
  List<String> get tableValue => [
    name ?? "",
    phone ?? "",
    location ?? "",
    role,
    truckno ?? "",
  ];

  @override
  String get slug => "$name,$phone,$email,$location,$truckno,$role";

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      phone: json["phone"],
      role: json["role"],
      image: json["image"],
      location: json["address"],
      name: json["fullname"],
      email: json["email"],
      truckno: json["truckno"],
    );
  }

}

class Location implements Slugger {
  int id;
  String? name;
  String? lga;
  String? state;
  String? facilityType;

  Location({this.id = 0, this.name = "", this.lga = "", this.state = "",this.facilityType=""});

  String get desc => "$name, $lga, $state";

  static List<String> get tableTitle => ["Name", "LGA", "State"];
  List<String> get tableValue => [name ?? "", lga ?? "", state ?? ""];

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json["id"],
      lga: json["lga"],
      state: json["state"],
      name: json["name"],
      facilityType: json["type"] ?? "Hospital"
    );
  }
  
  @override
  String get slug => desc;
}

class StateLocation implements Slugger {
  int id;
  String? name;
  bool? isActive;

  StateLocation({this.id = 0, this.name = "", this.isActive = false});

  String get desc => "$name, $isActive";

  static List<String> get tableTitle => ["Name", "Active"];
  List<String> get tableValue => [name ?? "", isActive.toString()];

  factory StateLocation.fromJson(Map<String, dynamic> json) {
    return StateLocation(
      id: json["id"],
      name: json["name"],
      isActive: json["isactive"] ?? false
    );
  }
  
  @override
  String get slug => desc;
}

class Delivery implements Slugger{
  int id;
  int driverId, ownerId;
  String? driver, owner, truckno;
  String waybill;
  DateTime? startDate;
  DateTime createdAt;
  List<String> stops, picture;
  List<DateTime?> stopsDate;
  List<List<String>> items;
  double amt;
  String? pickup;

  bool get isDelivered =>
      stopsDate.isNotEmpty &&
      stopsDate.length == stops.length &&
      !stopsDate.contains(null);
  bool get hasStarted =>
      startDate != null && startDate!.isBefore(DateTime.now());
  String get start => startDate == null
      ? ""
      : DateFormat("dd/MM/yyyy hh:mm:aa").format(startDate!);
  String get created => DateFormat("dd/MM/yyyy hh:mm:aa").format(createdAt);
  List<String?> get formattedStopsDate => stopsDate
      .map(
        (e) => e == null ? null : DateFormat("dd/MM/yyyy hh:mm:aa").format(e),
      )
      .toList();

  static List<String> get tableTitle => [
    "Waybill",
    "Creator",
    "Driver",
    "Pickup",
    "Stops",
    "Created At",
    "Start Date",
    "End Date",
  ];
  List<String> get tableValue => [
    waybill,
    owner ?? "",
    driver ?? "",
    pickup ?? "",
    stops[0],
    created,
    start,
    isDelivered ? formattedStopsDate[0] ?? "" : "",
  ];

  @override
  String get slug =>
      "$waybill,$driver,$owner,$pickup,${stops.toString()},$truckno,${items.toString()}";

  Delivery({
    this.id = 0,
    this.waybill = "",
    this.driverId = 0,
    this.picture = const [],
    this.driver,
    this.pickup,
    this.startDate,
    this.owner,
    this.amt = 0,
    this.truckno,
    this.ownerId = 0,
    this.stops = const [],
    this.stopsDate = const [],
    this.items = const [],
    required this.createdAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json["id"],
      waybill: json["waybill"],
      driverId: json["driverid"],
      ownerId: json["ownerid"],
      pickup: json["pickup"],
      driver: json["drivername"],
      owner: json["ownername"],
      amt: json["amount"] ?? 0,
      truckno: json["truckno"] ?? "",
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
}
