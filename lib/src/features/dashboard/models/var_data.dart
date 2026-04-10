import 'dart:convert';

import 'package:transborder_logistics/src/global/model/user.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sub-models (used in both submit payload and read-back)
// ─────────────────────────────────────────────────────────────────────────────

class CommodityRow {
  String vaccine;
  String batchNo;
  String expiryDate;
  String qtyDispatched;
  String qtyReceived;
  String vvmStatus;

  CommodityRow({
    this.vaccine = '',
    this.batchNo = '',
    this.expiryDate = '',
    this.qtyDispatched = '',
    this.qtyReceived = '',
    this.vvmStatus = '',
  });

  factory CommodityRow.fromJson(Map<String, dynamic> json) => CommodityRow(
    vaccine: json['vaccine_item']?.toString() ?? '',
    batchNo: json['batch_no']?.toString() ?? '',
    expiryDate: json['expiry_date']?.toString() ?? '',
    qtyDispatched: json['qty_dispatched']?.toString() ?? '',
    qtyReceived: json['qty_received']?.toString() ?? '',
    vvmStatus: json['vvm_status']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'vaccine_item': vaccine,
    'batch_no': batchNo,
    'expiry_date': expiryDate,
    'qty_dispatched': qtyDispatched,
    'qty_received': qtyReceived,
    'vvm_status': vvmStatus,
  };
}

class TempRecord {
  String monitoringPoint;
  String temperatureCelsius;
  String dateTime;

  TempRecord({
    this.monitoringPoint = '',
    this.temperatureCelsius = '',
    this.dateTime = '',
  });

  factory TempRecord.fromJson(Map<String, dynamic> json) => TempRecord(
    monitoringPoint: json['monitoring_point']?.toString() ?? '',
    temperatureCelsius: json['temperature_c']?.toString() ?? '',
    dateTime: json['date_time']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'monitoring_point': monitoringPoint,
    'temperature_c': temperatureCelsius,
    'date_time': dateTime,
  };
}

class ReverseLogisticsRow {
  String item;
  String quantity;
  String condition;
  String destination;

  ReverseLogisticsRow({
    this.item = '',
    this.quantity = '',
    this.condition = '',
    this.destination = '',
  });

  factory ReverseLogisticsRow.fromJson(Map<String, dynamic> json) =>
      ReverseLogisticsRow(
        item: json['item_retrieved']?.toString() ?? '',
        quantity: json['quantity']?.toString() ?? '',
        condition: json['condition']?.toString() ?? '',
        destination: json['destination']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
    'item_retrieved': item,
    'quantity': quantity,
    'condition': condition,
    'destination': destination,
  };
}

/// Nested sign-off block: { dispatched_by, delivered_by, received_by }
class SignOff {
  String dispatchedBy;
  String deliveredBy;
  String receivedBy;

  SignOff({
    this.dispatchedBy = '',
    this.deliveredBy = '',
    this.receivedBy = '',
  });

  factory SignOff.fromJson(Map<String, dynamic>? json) => SignOff(
    dispatchedBy: json?['dispatched_by']?.toString() ?? '',
    deliveredBy: json?['delivered_by']?.toString() ?? '',
    receivedBy: json?['received_by']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'dispatched_by': dispatchedBy,
    'delivered_by': deliveredBy,
    'received_by': receivedBy,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// VarData — submit payload sent to POST /api/var/submit
// ─────────────────────────────────────────────────────────────────────────────

class VarData {
  final int deliveryid;
  final int driverid;
  final int vehicleid;
  final int originid;
  final int destinationid;
  final String joborderno;
  final String dateofarrival;
  final String temperaturerange;
  final List<CommodityRow> commodityDetails;
  final List<TempRecord> temperatureMonitoring;
  final List<ReverseLogisticsRow>? reverseLogistics;
  final SignOff signOff;

  const VarData({
    this.deliveryid = 0,
    required this.driverid,
    required this.vehicleid,
    required this.originid,
    required this.destinationid,
    required this.joborderno,
    required this.dateofarrival,
    required this.temperaturerange,
    required this.commodityDetails,
    required this.temperatureMonitoring,
    this.reverseLogistics,
    required this.signOff,
  });

  Map<String, dynamic> toJson() => {
    'deliveryid': deliveryid,
    'driverid': driverid,
    'vehicleid': vehicleid,
    'originid': originid,
    'destinationid': destinationid,
    'joborderno': joborderno,
    'dateofarrival': dateofarrival,
    'temperaturerange': temperaturerange,
    'commodity_details': commodityDetails.map((e) => e.toJson()).toList(),
    'temperature_monitoring': temperatureMonitoring
        .map((e) => e.toJson())
        .toList(),
    if (reverseLogistics != null && reverseLogistics!.isNotEmpty)
      'reverse_logistics': reverseLogistics!.map((e) => e.toJson()).toList(),
    'sign_off': signOff.toJson(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// VarRecord — read-back from GET /api/var or GET /api/var/:id
// Implements Slugger so it works with ResourceHistoryPage/Table/ItemDetail.
// ─────────────────────────────────────────────────────────────────────────────

class VarRecord implements Slugger {
  final int id;
  final int deliveryid;
  final int driverid;
  final int vehicleid;
  final int originid;
  final int destinationid;
  final String joborderno;
  final String dateofarrival;
  final String temperaturerange;
  final List<CommodityRow> commodityDetails;
  final List<TempRecord> temperatureMonitoring;
  final List<ReverseLogisticsRow> reverseLogistics;
  final SignOff signOff;
  final String createdAt;
  final String status;
  final bool deliveryComplete;
  final String waybill;

  // Resolved display names (populated by controller after join with other lists)
  final String driverName;
  final String vehicleName;
  final String originName;
  final String destinationName;

  bool get tripEnded => status == 'trip_ended' || deliveryComplete;
  bool get isClosed => status == 'closed';

  VarRecord({
    this.id = 0,
    this.deliveryid = 0,
    this.driverid = 0,
    this.vehicleid = 0,
    this.originid = 0,
    this.destinationid = 0,
    this.joborderno = '',
    this.dateofarrival = '',
    this.temperaturerange = '',
    this.commodityDetails = const [],
    this.temperatureMonitoring = const [],
    this.reverseLogistics = const [],
    SignOff? signOff,
    this.createdAt = '',
    this.status = 'pending',
    this.deliveryComplete = false,
    this.waybill = '',
    this.driverName = '',
    this.vehicleName = '',
    this.originName = '',
    this.destinationName = '',
  }) : signOff = signOff ?? SignOff();

  factory VarRecord.fromJson(Map<String, dynamic> json) {
    List<CommodityRow> parseCommodity(dynamic raw) {
      if (raw == null) return [];
      try {
        return (jsonDecode(raw) as List)
            .map(
              (e) => CommodityRow.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      } catch (e) {
        return [];
      }
    }

    List<TempRecord> parseTemp(dynamic raw) {
      if (raw == null) return [];
      try {
        return (jsonDecode(raw) as List)
            .map(
              (e) => TempRecord.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      } catch (e) {
        return [];
      }
    }

    List<ReverseLogisticsRow> parseReverse(dynamic raw) {
      if (raw == null) return [];
      try {
        return (jsonDecode(raw) as List)
            .map(
              (e) => ReverseLogisticsRow.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      } catch (e) {
        return [];
      }
    }

    return VarRecord(
      id: json['id'] ?? 0,
      deliveryid: json['deliveryid'] ?? 0,
      driverid: json['driverid'] ?? 0,
      vehicleid: json['vehicleid'] ?? 0,
      originid: json['originid'] ?? 0,
      destinationid: json['destinationid'] ?? 0,
      joborderno: json['joborderno']?.toString() ?? '',
      dateofarrival: json['dateofarrival']?.toString() ?? '',
      temperaturerange: json['temperaturerange']?.toString() ?? '',
      commodityDetails: parseCommodity(json['commodity_details']),
      temperatureMonitoring: parseTemp(json['temperature_monitoring']),
      reverseLogistics: parseReverse(json['reverse_logistics']),
      waybill: json['waybill']?.toString() ?? '',
      signOff: json['sign_off'] == null
          ? null
          : SignOff.fromJson(
              jsonDecode(json['sign_off']) as Map<String, dynamic>?,
            ),
      createdAt:
          json['createdat']?.toString() ?? json['createdAt']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      deliveryComplete:
          json['delivery_complete'] == true || json['delivery_complete'] == 1,
    );
  }

  // ── Slugger implementation ─────────────────────────────────────────────────

  @override
  String get rawId => '#$id';

  @override
  String get slug =>
      '$joborderno,$dateofarrival,$driverName,$vehicleName,$originName,$destinationName,${signOff.receivedBy}';

  @override
  List<String> get tableTitle => [
    'ID',
    'Job Order',
    'Arrival Date',
    'Driver',
    'Origin',
    'Destination',
    'Status',
  ];

  @override
  List<String> get tableValue => [
    rawId,
    joborderno.isEmpty ? '—' : joborderno,
    dateofarrival.isEmpty ? '—' : dateofarrival,
    driverName.isEmpty ? '#$driverid' : driverName,
    originName.isEmpty ? '#$originid' : originName,
    destinationName.isEmpty ? '#$destinationid' : destinationName,
    isClosed ? 'Closed' : (tripEnded ? 'Trip Ended' : 'Pending'),
  ];

  @override
  Map<String, String> get fields => {
    'ID': id.toString(),
    'Job Order No.': joborderno,
    'Date of Arrival': dateofarrival,
    'Temperature Range': temperaturerange,
    'Driver': driverName.isEmpty ? '#$driverid' : driverName,
    'Vehicle': vehicleName.isEmpty ? '#$vehicleid' : vehicleName,
    'Origin': originName.isEmpty ? '#$originid' : originName,
    'Destination': destinationName.isEmpty
        ? '#$destinationid'
        : destinationName,
    'Commodities': commodityDetails.length.toString(),
    'Temp Records': temperatureMonitoring.length.toString(),
    
    'Status': status,
    'Reverse Logistics': reverseLogistics.length.toString(),
    'Dispatched By': signOff.dispatchedBy,
    'Delivered By': signOff.deliveredBy,
    'Received By': signOff.receivedBy,
    'Submitted At': createdAt,
  };
}
