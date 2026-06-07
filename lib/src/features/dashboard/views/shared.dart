import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:transborder_logistics/src/features/auth/controllers/excel.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';

import 'package:transborder_logistics/src/global/services/barrel.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';
import 'package:transborder_logistics/src/global/ui/widgets/fields/custom_dropdown.dart';
import 'package:transborder_logistics/src/global/ui/widgets/fields/custom_textfield.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/others.dart';
import 'package:transborder_logistics/src/src_barrel.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

import 'package:transborder_logistics/src/features/dashboard/controllers/var_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/views/driver/var_form_screen.dart';
import '../../../global/model/barrel.dart';
import 'package:transborder_logistics/src/features/dashboard/models/var_data.dart';

class DeliveryInfo extends StatelessWidget {
  const DeliveryInfo(this.delivery, {super.key});
  final Delivery delivery;

  Color get _statusColor {
    if (delivery.isCanceled) return AppColors.primaryColor;
    if (delivery.isDelivered) return AppColors.green;
    if (delivery.hasStarted) return AppColors.accentColor;
    return AppColors.yellow;
  }

  String get _statusLabel {
    if (delivery.isCanceled) return 'Cancelled';
    if (delivery.isDelivered) return 'Completed';
    if (delivery.hasStarted && delivery.isNotDelivered) return 'In Progress';
    return 'New';
  }

  dynamic get _statusIcon {
    if (delivery.isCanceled) return HugeIcons.strokeRoundedCancelCircle;
    if (delivery.isDelivered) return HugeIcons.strokeRoundedCheckmarkCircle02;
    if (delivery.hasStarted) return HugeIcons.strokeRoundedTruck;
    return HugeIcons.strokeRoundedAlertCircle;
  }

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      border: Border.all(color: AppColors.borderColor),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onPressed: () => Get.to(WaybillDetailPage(delivery)),
      radius: 14,
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.07),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AppIcon(_statusIcon, color: _statusColor, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.bold('#${delivery.waybill}', fontSize: 13),
                      if (delivery.commodityType?.isNotEmpty ?? false)
                        AppText.thin(
                          delivery.commodityType!,
                          fontSize: 10,
                          color: AppColors.lightTextColor,
                          maxlines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      AppText.medium(_statusLabel, fontSize: 11, color: _statusColor),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Route row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.green.withOpacity(0.3), width: 2),
                      ),
                    ),
                    Container(width: 1.5, height: 20, color: AppColors.borderColor),
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3), width: 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.thin(delivery.pickup ?? 'N/A', fontSize: 12, maxlines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 12),
                      AppText.thin(
                        delivery.stops.isNotEmpty ? delivery.stops.last : 'N/A',
                        fontSize: 12,
                        maxlines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderColor)),
            ),
            child: Row(
              children: [
                AppIcon(HugeIcons.strokeRoundedContainerTruck01, size: 13, color: AppColors.lightTextColor),
                const SizedBox(width: 4),
                AppText.thin(delivery.truckno ?? 'N/A', fontSize: 11, color: AppColors.lightTextColor),
                const SizedBox(width: 12),
                AppIcon(HugeIcons.strokeRoundedUser, size: 13, color: AppColors.lightTextColor),
                const SizedBox(width: 4),
                Expanded(
                  child: AppText.thin(
                    delivery.driver ?? 'N/A',
                    fontSize: 11,
                    color: AppColors.lightTextColor,
                    maxlines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Status pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (delivery.isCanceled
                        ? AppColors.primaryColor
                        : delivery.isDelivered
                            ? AppColors.green
                            : delivery.hasStarted
                                ? AppColors.accentColor
                                : AppColors.yellow).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AppText.medium(
                    delivery.isCanceled ? 'Cancelled' :
                    delivery.isDelivered ? 'Completed' :
                    delivery.hasStarted ? 'In Transit' : 'New',
                    fontSize: 10,
                    color: delivery.isCanceled
                        ? AppColors.primaryColor
                        : delivery.isDelivered
                            ? AppColors.green
                            : delivery.hasStarted
                                ? AppColors.accentColor
                                : AppColors.yellow,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class DriverInfo extends StatelessWidget {
  const DriverInfo(this.user, {super.key});
  final User user;

  @override
  Widget build(BuildContext context) {
    return RawInfo(
      title: user.name,
      desc: user.role,
      subtitle: user.location,
      chipTitle:
          Get.find<DashboardController>().allUndeliveredDeliveries
              .map((e) => e.driverId)
              .contains(user.id)
          ? "Busy"
          : "Available",
      image: user.image ?? "",
      vb: () {
        Get.bottomSheet(
          AddResource<User>("Drivers", obj: user),
          isScrollControlled: true,
        );
      },
    );
  }
}

class UserInfo extends StatelessWidget {
  const UserInfo(this.user, {super.key});
  final User user;

  @override
  Widget build(BuildContext context) {
    return RawInfo(
      title: user.name,
      desc: user.role,
      subtitle: user.location,
      chipTitle:
          Get.find<DashboardController>().allUndeliveredDeliveries
              .map((e) => e.driverId)
              .contains(user.id)
          ? "Busy"
          : "Available",
      image: user.image ?? "",
      vb: () {
        Get.bottomSheet(
          AddResource<User>("Users", obj: user),
          isScrollControlled: true,
        );
      },
    );
  }
}

class VehicleInfo extends StatelessWidget {
  const VehicleInfo(this.vehicle, {super.key});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return RawInfo(
      title: vehicle.name,
      desc: vehicle.type,
      subtitle: vehicle.regno,
      chipTitle: vehicle.isActive ? "Available" : "Inactive",
      image: vehicle.image ?? "",
      vb: () {
        Get.bottomSheet(
          AddResource<Vehicle>("Vehicles", obj: vehicle),
          isScrollControlled: true,
        );
      },
    );
  }
}

class RawInfo extends StatelessWidget {
  const RawInfo({
    this.title,
    this.chipTitle = "Available",
    this.desc,
    this.subtitle,
    this.image = "",
    this.vb,
    super.key,
  });
  final String? title, desc, subtitle;
  final String image;
  final String chipTitle;
  final VoidCallback? vb;

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      border: Border.all(color: AppColors.borderColor),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      onPressed: vb,
      radius: 12,
      child: Row(
        children: [
          CurvedImage(
            image == "" ? "" : "${AppUrls.baseURL}/upload/upload/$image",
            w: 48,
            h: 48,
            fit: BoxFit.cover,
          ),
          Ui.boxWidth(12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.medium(title ?? "N/A", fontSize: 12),
                AppText.thin(
                  desc?.capitalize ?? "",
                  fontSize: 10,
                  color: AppColors.lightTextColor,
                ),
                AppText.medium(
                  subtitle ?? "N/A",
                  fontSize: 10,
                  color: AppColors.lightTextColor,
                ),
              ],
            ),
          ),
          Ui.boxWidth(24),
          DriverStatusChip(chipTitle),
        ],
      ),
    );
  }
}

class LocationInfo extends StatelessWidget {
  const LocationInfo(this.user, {super.key});
  final Location user;

  @override
  Widget build(BuildContext context) {
    return RawInfo(
      title: user.name,
      desc: user.facilityType,
      subtitle: "${user.lga}, ${user.state}",
      vb: () {
        Get.bottomSheet(
          AddResource<Location>("Facilities", obj: user),
          isScrollControlled: true,
        );
        // Get.to(WaybillDetailPage(delivery));
      },
    );
  }
}

class StateInfo extends StatelessWidget {
  const StateInfo(this.sloc, {super.key});
  final StateLocation sloc;

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      border: Border.all(color: AppColors.borderColor),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      onPressed: () {
        Get.bottomSheet(
          AddResource<StateLocation>("Location", obj: sloc),
          isScrollControlled: true,
        );
      },
      radius: 12,
      child: Row(
        children: [
          AppIcon(HugeIcons.strokeRoundedLocation05),
          Ui.boxWidth(12),
          Expanded(child: AppText.medium(sloc.name , fontSize: 12)),
          Ui.boxWidth(24),
          DriverStatusChip(sloc.isActive! ? "Available" : "Inactive"),
        ],
      ),
    );
  }
}

class VarRecordInfo extends StatelessWidget {
  const VarRecordInfo(this.record, {super.key});
  final VarRecord record;

  Color get _statusColor => record.isClosed
      ? AppColors.green
      : record.tripEnded
          ? AppColors.accentColor
          : AppColors.yellow;

  String get _statusLabel => record.isClosed
      ? 'Closed'
      : record.tripEnded
          ? 'Trip Ended'
          : 'Pending';

  @override
  Widget build(BuildContext context) {
    final hasTemp = record.temperaturerange.isNotEmpty;
    final hasCommodities = record.commodityDetails.isNotEmpty;
    final hasReverse = record.reverseLogistics?.isNotEmpty ?? false;
    final isSignedOff = record.signOff.receivedBy.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Get.find<VarController>().populateFromVar(record);
        Get.bottomSheet(
          AddResource<VarRecord>("VAR Records", obj: record),
          isScrollControlled: true,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryColorBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.07),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppIcon(HugeIcons.strokeRoundedDocumentCode,
                        size: 14, color: _statusColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.bold(
                          record.joborderno.isEmpty ? '—' : record.joborderno,
                          fontSize: 13,
                        ),
                        if (record.dateofarrival.isNotEmpty)
                          AppText.thin(record.dateofarrival,
                              fontSize: 10, color: AppColors.lightTextColor),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 5, height: 5,
                        decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      AppText.medium(_statusLabel, fontSize: 10, color: _statusColor),
                    ]),
                  ),
                ],
              ),
            ),

            // ── Route ─────────────────────────────────────────────────
            if (record.originName.isNotEmpty || record.destinationName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Row(
                  children: [
                    Column(children: [
                      Container(width: 8, height: 8,
                        decoration: BoxDecoration(color: AppColors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.green.withOpacity(0.3), width: 2))),
                      Container(width: 1, height: 14, color: AppColors.borderColor),
                      Container(width: 8, height: 8,
                        decoration: BoxDecoration(color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3), width: 2))),
                    ]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.thin(
                            record.originName.isNotEmpty ? record.originName : '#${record.originid}',
                            fontSize: 11, maxlines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 10),
                          AppText.thin(
                            record.destinationName.isNotEmpty ? record.destinationName : '#${record.destinationid}',
                            fontSize: 11, maxlines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // ── Summary badges ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                children: [
                  if (record.driverName.isNotEmpty) ...[
                    AppIcon(HugeIcons.strokeRoundedUser, size: 12, color: AppColors.lightTextColor),
                    const SizedBox(width: 4),
                    Expanded(child: AppText.thin(record.driverName,
                      fontSize: 11, color: AppColors.lightTextColor,
                      maxlines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                  if (hasCommodities)
                    _badge('${record.commodityDetails.length} items',
                        AppColors.accentColor),
                  if (hasTemp) ...[
                    const SizedBox(width: 6),
                    _badge(record.temperaturerange, const Color(0xFF2196F3)),
                  ],
                  if (hasReverse) ...[
                    const SizedBox(width: 6),
                    _badge('Reverse', AppColors.yellow),
                  ],
                  if (isSignedOff) ...[
                    const SizedBox(width: 6),
                    _badge('✓ Signed', AppColors.green),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: AppText.medium(label, fontSize: 10, color: color),
    );
  }
}


class DriverStatusChip extends StatelessWidget {
  const DriverStatusChip(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    final isAvailable = status.toLowerCase() == 'available';
    final color = isAvailable ? AppColors.green : AppColors.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          AppText.medium(status, fontSize: 11, color: color),
        ],
      ),
    );
  }
}

class VarRecordStatusChip extends StatelessWidget {
  const VarRecordStatusChip(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppChip(
      title.toLowerCase() == "trip_ended" ? "trip ended" : title.toLowerCase(),
      bgColors: [
        AppColors.borderColor.withValues(alpha: 0.2), // pending
        Color(0xFFFFF4E5), // trip_ended
        Color(0xFFE6FBEC), // closed
      ],
      titles: ["pending", "trip ended", "closed"],
      titleColors: [AppColors.textColor, Color(0xFFFF9800), Color(0xFF00D743)],
      icons: [
        HugeIcons.strokeRoundedClock01,
        HugeIcons.strokeRoundedContainerTruck01,
        HugeIcons.strokeRoundedCheckmarkCircle01,
      ],
    );
  }
}

class WaybillStatusChip extends StatelessWidget {
  const WaybillStatusChip(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppChip(title);
  }
}

class AppChip extends StatelessWidget {
  const AppChip(
    this.title, {
    this.titles = const [
      "New",
      "Track",
      "In Progress",
      "Completed",
      "Cancelled",
    ],
    this.icons = const [
      HugeIcons.strokeRoundedAlertCircle,
      HugeIcons.strokeRoundedRoute03,
      HugeIcons.strokeRoundedArrowLeftRight,
      HugeIcons.strokeRoundedCheckmarkCircle02,
      HugeIcons.strokeRoundedCancelCircle,
    ],
    this.titleColors = const [
      Color(0xFFFFB400),
      Color(0xFF229EFF),
      Color(0xFF229EFF),
      Color(0xFF00D743),
      Color(0xFFFF3B30),
    ],
    this.bgColors = const [
      Color(0xFFFFF8E6),
      Color(0xFFE9F5FF),
      Color(0xFFE9F5FF),
      Color(0xFFE6FBEC),
      Color(0xFFFFEBEA),
    ],
    super.key,
  });
  final String title;
  final List<String> titles;
  final List<dynamic> icons;
  final List<Color> titleColors;
  final List<Color> bgColors;

  @override
  Widget build(BuildContext context) {
    final i = titles.indexOf(title);
    return CurvedContainer(
      color: bgColors[i],
      radius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(icons[i], size: 16, color: titleColors[i]),
            Ui.boxWidth(4),
            AppText.medium(title, fontSize: 12, color: titleColors[i]),
          ],
        ),
      ),
    );
  }
}

class WaybillDetailPage extends StatelessWidget {
  const WaybillDetailPage(this.delivery, {super.key});
  final Delivery delivery;

  Color get _statusColor {
    if (delivery.isCanceled) return AppColors.primaryColor;
    if (delivery.isDelivered) return AppColors.green;
    if (delivery.hasStarted) return const Color(0xFF2196F3);
    return AppColors.yellow;
  }

  String get _statusLabel {
    if (delivery.isCanceled) return 'Cancelled';
    if (delivery.isDelivered) return 'Completed';
    if (delivery.hasStarted) return 'In Progress';
    return 'New';
  }

  int get _progressStep {
    if (delivery.isCanceled) return 0;
    if (delivery.isDelivered) return 4;
    if (delivery.hasStarted) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final appService = Get.find<AppService>();
    final WidgetsToImageController wsController = WidgetsToImageController();

    final wbContent = _buildWaybillContent(context, appService);

    final shareBody = WidgetsToImage(
      controller: wsController,
      child: Container(
        color: AppColors.primaryColorBackground,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [wbContent],
        ),
      ),
    );

    return SinglePageScaffold(
      title: '#${delivery.waybill}',
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Ui.isBigScreen(context)
                  ? Ui.width(context) / 2
                  : Ui.width(context) - 16,
            ),
            child: Column(
              children: [
                shareBody,
                if (delivery.items.isNotEmpty)
                  _buildItemsSection(context),
                const SizedBox(height: 16),
                _buildActionButtons(context, appService, wsController),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Professional waybill body ────────────────────────────────────────────

  Widget _buildWaybillContent(BuildContext context, AppService appService) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColorBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWaybillHeader(context),
            _buildWaybillId(context),
            _buildProgressTracker(),
            _buildDivider(),
            _buildTripDetails(context),
            _buildDivider(),
            _buildRouteTimeline(),
            if ((delivery.commodityType?.isNotEmpty ?? false) || delivery.items.isNotEmpty) ...[
              _buildDivider(),
              _buildCommoditySection(),
            ],
            _buildDivider(),
            _buildSignatureSection(context, appService),
            _buildWaybillFooter(),
          ],
        ),
      ),
    );
  }

  // ── Header with branding ─────────────────────────────────────────────────

  Widget _buildWaybillHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.primaryColor,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: AppIcon(HugeIcons.strokeRoundedContainerTruck01,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bold('Transborder Logistics',
                    fontSize: 16, color: Colors.white),
                AppText.thin('Precise. Progressive. People.',
                    fontSize: 11, color: Colors.white.withOpacity(0.8)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: QrImageView(
              data: delivery.waybill,
              size: 52,
              foregroundColor: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Waybill ID + status ──────────────────────────────────────────────────

  Widget _buildWaybillId(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: AppColors.surfaceColor,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bold('#${delivery.waybill}',
                    fontSize: 18),
                const SizedBox(height: 3),
                AppText.thin(
                  '${delivery.commodityType?.isNotEmpty ?? false ? delivery.commodityType! : "General Cargo"}'
                  ' · Issued ${delivery.created.split(' ').first}',
                  fontSize: 11,
                  color: AppColors.lightTextColor,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _statusColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                      color: _statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                AppText.medium(_statusLabel,
                    fontSize: 12, color: _statusColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress tracker ─────────────────────────────────────────────────────

  Widget _buildProgressTracker() {
    final steps = ['Assigned', 'Picked up', 'In transit', 'Delivered', 'Confirmed'];
    final step = _progressStep;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: AppColors.surfaceColor,
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final lineIdx = i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: lineIdx < step
                    ? AppColors.primaryColor
                    : AppColors.borderColor,
              ),
            );
          }
          final idx = i ~/ 2;
          final isDone = idx < step;
          final isActive = idx == step;
          return Column(
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.primaryColor
                      : isActive
                          ? const Color(0xFF2196F3)
                          : AppColors.surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone
                        ? AppColors.primaryColor
                        : isActive
                            ? const Color(0xFF2196F3)
                            : AppColors.borderColor,
                    width: 2,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : isActive
                        ? const Icon(Icons.local_shipping,
                            color: Colors.white, size: 12)
                        : null,
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 56,
                child: Text(
                  steps[idx],
                  style: TextStyle(
                    fontSize: 9,
                    color: isDone || isActive
                        ? AppColors.textColor
                        : AppColors.lightTextColor,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── Trip details grid ────────────────────────────────────────────────────

  Widget _buildTripDetails(BuildContext context) {
    final driver = Get.find<DashboardController>()
        .allDrivers
        .firstWhereOrNull((e) => e.id == delivery.driverId);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Trip Details'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _infoBlock('Trip ID', '#${delivery.id}')),
              Expanded(child: _infoBlock('Waybill No.', delivery.waybill)),
              Expanded(child: _infoBlock('Vehicle Reg', delivery.truckno ?? 'N/A')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _infoBlock('Driver', delivery.driver ?? 'N/A')),
              Expanded(child: _infoBlock('Requested By', delivery.owner ?? 'N/A')),
              Expanded(child: _infoBlock('Issue Date', delivery.created.split(' ').first)),
            ],
          ),
          if (delivery.hasStarted) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _infoBlock('Pickup Date', delivery.start.split(' ').first)),
                if (delivery.invoiceno?.isNotEmpty ?? false)
                  Expanded(child: _infoBlock('Invoice No.', delivery.invoiceno!)),
                if (delivery.deliveryType?.isNotEmpty ?? false)
                  Expanded(child: _infoBlock('Delivery Type', delivery.deliveryType!)),
              ],
            ),
          ],
          if (driver != null && !(Delivery.nv.contains(driver.image))) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                CurvedImage(
                  '${AppUrls.baseURL}/upload/upload/${driver.image}',
                  w: 32, h: 32, fit: BoxFit.cover,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.medium(delivery.driver ?? '', fontSize: 12),
                    AppText.thin('Assigned Driver', fontSize: 10,
                        color: AppColors.lightTextColor),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Route timeline ───────────────────────────────────────────────────────

  Widget _buildRouteTimeline() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Route'),
          const SizedBox(height: 12),
          // Pickup
          _routeStop(
            dotColor: AppColors.green,
            label: 'Pickup Location',
            location: delivery.pickup ?? 'N/A',
            meta: delivery.pickupName?.isNotEmpty ?? false
                ? delivery.pickupName!
                : null,
            date: delivery.hasStarted ? delivery.start : null,
            isLast: false,
            signature: delivery.pickupSignature,
          ),
          // Stops
          ...List.generate(delivery.stops.length, (j) {
            final isLast = j == delivery.stops.length - 1;
            final receiverData = delivery.receiver.elementAtOrNull(j);
            final stopDate = delivery.formattedStopsDate.elementAtOrNull(j);
            final picture = delivery.picture.elementAtOrNull(j);
            return _routeStop(
              dotColor: AppColors.primaryColor,
              label: 'Delivery Location ${delivery.stops.length > 1 ? j + 1 : ''}',
              location: delivery.stops[j],
              meta: receiverData != null && receiverData.isNotEmpty
                  ? receiverData[0]
                  : null,
              date: stopDate,
              isLast: isLast,
              picture: picture,
              signature: receiverData != null && receiverData.length > 2
                  ? receiverData[2]
                  : null,
            );
          }),
        ],
      ),
    );
  }

  Widget _routeStop({
    required Color dotColor,
    required String label,
    required String location,
    String? meta,
    String? date,
    String? picture,
    String? signature,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14, height: 14,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(
                    color: dotColor.withOpacity(0.3), width: 3),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: AppColors.borderColor,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.thin(label, fontSize: 10,
                    color: AppColors.lightTextColor),
                const SizedBox(height: 2),
                AppText.medium(location, fontSize: 13),
                if (meta != null && meta.isNotEmpty)
                  AppText.thin(meta, fontSize: 11,
                      color: AppColors.lightTextColor),
                if (date != null && date.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppIcon(HugeIcons.strokeRoundedClock01,
                          size: 12, color: AppColors.accentColor),
                      const SizedBox(width: 4),
                      AppText.thin(date, fontSize: 11,
                          color: AppColors.accentColor),
                    ],
                  ),
                ],
                if (picture != null && !Delivery.nv.contains(picture)) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      '${AppUrls.baseURL}/upload/upload/$picture',
                      height: 120,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ],
                if (signature != null && !Delivery.nv.contains(signature)) ...[
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.network(
                      '${AppUrls.baseURL}/upload/upload/$signature',
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Commodity section ────────────────────────────────────────────────────

  Widget _buildCommoditySection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Commodity'),
          const SizedBox(height: 12),
          if (delivery.commodityType?.isNotEmpty ?? false)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppText.medium(delivery.commodityType!,
                  fontSize: 12, color: AppColors.primaryColor),
            ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: _sectionLabel('Items')),
              if (delivery.amt > 0)
                AppText.medium(delivery.amt.toCurrency(), fontSize: 13),
            ]),
          ),
          ...delivery.items.asMap().entries.map((e) {
            final isLast = e.key == delivery.items.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderColor),
                  bottom: isLast
                      ? BorderSide.none
                      : BorderSide(color: AppColors.borderColor),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: AppText.thin('${e.key + 1}', fontSize: 11,
                          color: AppColors.lightTextColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: AppText.medium(e.value[0], fontSize: 12)),
                  AppText.thin(e.value.length > 1 ? e.value[1] : '',
                      fontSize: 11, color: AppColors.lightTextColor),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Signature section ────────────────────────────────────────────────────

  Widget _buildSignatureSection(BuildContext context, AppService appService) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Acknowledgement'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _signBox(
                label: 'Dispatched by',
                name: delivery.owner ?? 'N/A',
                date: delivery.created.split(' ').first,
                signatureUrl: null,
                isSigned: true,
              )),
              const SizedBox(width: 12),
              Expanded(child: _signBox(
                label: 'Received by',
                name: delivery.isDelivered
                    ? (delivery.receiver.firstOrNull?.firstOrNull ?? 'N/A')
                    : '—',
                date: delivery.isDelivered
                    ? (delivery.formattedStopsDate.firstOrNull ?? 'Pending')
                    : 'Pending delivery',
                signatureUrl: delivery.isDelivered &&
                        (delivery.receiver.firstOrNull?.length ?? 0) > 2
                    ? '${AppUrls.baseURL}/upload/upload/${delivery.receiver.first![2]}'
                    : null,
                isSigned: delivery.isDelivered,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _signBox({
    required String label,
    required String name,
    required String date,
    String? signatureUrl,
    required bool isSigned,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.thin(label.toUpperCase(),
              fontSize: 9, color: AppColors.lightTextColor),
          const SizedBox(height: 8),
          Container(
            height: 44,
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: AppColors.borderColor)),
            ),
            child: signatureUrl != null
                ? Image.network(signatureUrl, height: 40, fit: BoxFit.contain)
                : AppText.thin(isSigned ? '✓ Signed' : 'Signature',
                    fontSize: 11, color: AppColors.lightTextColor),
          ),
          const SizedBox(height: 6),
          AppText.medium(name, fontSize: 12),
          AppText.thin(date, fontSize: 10, color: AppColors.lightTextColor),
        ],
      ),
    );
  }

  // ── Footer ───────────────────────────────────────────────────────────────

  Widget _buildWaybillFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: AppColors.surfaceColor,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.medium('Transborder Logistics Ltd.',
                    fontSize: 11),
                AppText.thin(
                  'This document is system-generated and valid without a physical stamp.',
                  fontSize: 9,
                  color: AppColors.lightTextColor,
                ),
              ],
            ),
          ),
          AppText.thin('transborderlogistics.net',
              fontSize: 9, color: AppColors.lightTextColor),
        ],
      ),
    );
  }

  // ── Action buttons ───────────────────────────────────────────────────────

  Widget _buildActionButtons(BuildContext context, AppService appService,
      WidgetsToImageController wsController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Admin actions row
          if (appService.currentUser.value.role == 'admin')
            Row(
              children: [
                if (delivery.hasNotStarted && delivery.isNotDelivered)
                  _actionBtn(
                    icon: HugeIcons.strokeRoundedEdit01,
                    label: 'Edit Trip',
                    onTap: () => Get.bottomSheet(
                      AddResource<Delivery>('Trips', obj: delivery),
                      isScrollControlled: true,
                    ),
                  ),
                if (delivery.hasNotStarted && delivery.isNotDelivered)
                  const SizedBox(width: 10),
                if (delivery.isNotDelivered && !delivery.isCanceled)
                  _actionBtn(
                    icon: HugeIcons.strokeRoundedDelete01,
                    label: 'Cancel Trip',
                    isDestructive: true,
                    onTap: () => Get.bottomSheet(
                      AppBottomSheet(
                        'Cancel Trip', 'Confirm',
                        msg: 'Are you sure you want to cancel this trip? This action is irreversible.',
                        onTap: () async {
                          try {
                            await Get.find<DashboardController>()
                                .appRepo
                                .cancelDelivery(
                              delivery.waybill,
                              delivery.vehicleId,
                              delivery.id,
                            );
                            Get.back();
                            await Get.find<DashboardController>().initApp();
                            Get.find<DashboardController>().refreshResource();
                            Get.back();
                          } catch (e) {
                            print(e);
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          // Download / Share button
          SizedBox(
            width: double.infinity,
            child: _actionBtn(
              icon: HugeIcons.strokeRoundedDownload01,
              label: 'Download Waybill',
              isPrimary: true,
              fullWidth: true,
              onTap: () async {
                Get.bottomSheet(
                  _WaybillShareSheet(
                    wsController: wsController,
                    waybill: delivery.waybill,
                  ),
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required dynamic icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
    bool isDestructive = false,
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primaryColor
              : isDestructive
                  ? AppColors.primaryColor.withOpacity(0.08)
                  : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary
                ? AppColors.primaryColor
                : isDestructive
                    ? AppColors.primaryColor.withOpacity(0.3)
                    : AppColors.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: fullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            AppIcon(icon,
                size: 16,
                color: isPrimary
                    ? Colors.white
                    : isDestructive
                        ? AppColors.primaryColor
                        : AppColors.textColor),
            const SizedBox(width: 8),
            AppText.medium(label,
                fontSize: 13,
                color: isPrimary
                    ? Colors.white
                    : isDestructive
                        ? AppColors.primaryColor
                        : AppColors.textColor),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return AppText.medium(text.toUpperCase(),
        fontSize: 10, color: AppColors.lightTextColor);
  }

  Widget _infoBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.thin(label, fontSize: 10, color: AppColors.lightTextColor),
        const SizedBox(height: 3),
        AppText.medium(value, fontSize: 12),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColors.borderColor, height: 1);
  }
}

// ── Waybill share bottom sheet ───────────────────────────────────────────────

class _WaybillShareSheet extends StatelessWidget {
  const _WaybillShareSheet({
    required this.wsController,
    required this.waybill,
  });
  final WidgetsToImageController wsController;
  final String waybill;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColorBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          AppText.bold('Download Waybill', fontSize: 16),
          AppText.thin('#$waybill', fontSize: 12,
              color: AppColors.lightTextColor),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ShareOption(
                icon: HugeIcons.strokeRoundedImage01,
                label: 'Save as PNG',
                color: AppColors.accentColor,
                onTap: () async {
                  try {
                    Get.back();
                    final bytes = await wsController.capturePng(pixelRatio: 6);
                    if (bytes != null) {
                      final file = await UtilFunctions.saveToTempFile(bytes);
                      if (GetPlatform.isMobile) {
                        await SharePlus.instance.share(
                          ShareParams(
                            title: 'Waybill #$waybill',
                            files: [XFile(file.path)],
                          ),
                        );
                      } else {
                        final path = await saveFileDesktop(
                          file.readAsBytesSync(),
                          'Waybill_$waybill.png',
                        );
                        if (path != null) {
                          Ui.showInfo('Saved to $path');
                        }
                      }
                    }
                  } catch (e) {
                    print(e);
                  }
                },
              ),
              const SizedBox(width: 16),
              _ShareOption(
                icon: HugeIcons.strokeRoundedShare08,
                label: 'Share',
                color: AppColors.green,
                onTap: () async {
                  try {
                    Get.back();
                    final bytes = await wsController.capturePng(pixelRatio: 6);
                    if (bytes != null) {
                      final file = await UtilFunctions.saveToTempFile(bytes);
                      await SharePlus.instance.share(
                        ShareParams(
                          title: 'Waybill #$waybill',
                          text: 'Please find attached waybill #$waybill from Transborder Logistics.',
                          files: [XFile(file.path)],
                        ),
                      );
                    }
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          SafeArea(child: const SizedBox()),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final dynamic icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Center(child: AppIcon(icon, color: color, size: 26)),
          ),
          const SizedBox(height: 8),
          AppText.medium(label, fontSize: 12),
        ],
      ),
    );
  }
}


class SignatureView extends StatefulWidget {
  const SignatureView(this.tec, this.label, {this.size, super.key});
  final Rx<Uint8List> tec;
  final String label;
  final double? size;

  @override
  State<SignatureView> createState() => _SignatureViewState();
}

class _SignatureViewState extends State<SignatureView> {
  bool isCaptured = false;
  Uint8List? bytes;

  GlobalKey<SfSignaturePadState> signaturePadKey = GlobalKey();

  @override
  void initState() {
    if (widget.tec.value.isNotEmpty) {
      isCaptured = true;
      bytes = widget.tec.value;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.only(left: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.thin(widget.label),
          Ui.boxHeight(8),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.lightTextColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  height: 84,
                  clipBehavior: Clip.hardEdge,
                  width: Ui.width(context) - 72,
                  child: bytes != null
                      ? Image.memory(bytes!)
                      : SfSignaturePad(
                          key: signaturePadKey,
                          backgroundColor: AppColors.white,
                        ),
                ),
              ),
              Ui.boxWidth(8),
              Column(
                children: [
                  CircleIcon(
                    HugeIcons.strokeRoundedCamera01,
                    radius: 12,
                    size: 16,
                    bg: AppColors.green,
                    onTap: () async {
                      ui.Image image = await signaturePadKey.currentState!
                          .toImage();
                      var data = await image.toByteData(
                        format: ui.ImageByteFormat.png,
                      );
                      final dd = data!.buffer.asUint8List();

                      widget.tec.value = dd;
                      Ui.showInfo("Signature captured");
                      setState(() {
                        bytes = dd;
                        isCaptured = true;
                      });
                    },
                  ),
                  Ui.boxHeight(20),
                  CircleIcon(
                    HugeIcons.strokeRoundedDelete02,
                    radius: 12,
                    size: 16,
                    onTap: () {
                      if (isCaptured) {
                        widget.tec.value = Uint8List(0);
                        setState(() {
                          isCaptured = false;
                          bytes = null;
                        });
                      } else {
                        signaturePadKey.currentState!.clear();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          // Ui.boxHeight(24),
          // AppButton.row(
          //   "Capture",
          //   () async {
          //     ui.Image image = await signaturePadKey.currentState!.toImage();
          //     var data = await image.toByteData(format: ui.ImageByteFormat.png);
          //     final dd = data!.buffer.asUint8List();

          //     widget.tec.value = dd;
          //     Ui.showInfo("Signature captured");
          //     setState(() {
          //       bytes = dd;
          //       isCaptured = true;
          //     });
          //   },
          //   "Clear",
          //   () {
          //     if (isCaptured) {
          //       setState(() {
          //         isCaptured = false;
          //         bytes = null;
          //       });
          //     } else {
          //       signaturePadKey.currentState!.clear();
          //     }
          //   },
          // ),
          // Ui.boxHeight(24),
        ],
      ),
    );
    if (widget.size == null) {
      return content;
    }
    return SizedBox(width: widget.size!, child: content);
  }
}

class CircleIcon extends StatelessWidget {
  CircleIcon(
    this.icon, {
    this.onTap,
    this.radius = 20,
    this.size = 24,
    this.bg = AppColors.primaryColor,
    this.ic,
    super.key,
  });
  final dynamic icon;
  final VoidCallback? onTap;
  final double? radius;
  final double? size;
  Color? bg, ic;

  @override
  Widget build(BuildContext context) {
    ic = ic ?? AppColors.white;
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: Center(
          child: AppIcon(icon, color: ic!, size: size!),
        ),
      ),
    );
  }
}

class InfoValue extends StatelessWidget {
  const InfoValue(this.label, this.value, {this.isStart = false, super.key});

  final String label;
  final String? value;
  final bool isStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isStart
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,

      mainAxisSize: MainAxisSize.min,
      children: [
        AppText.thin(label, color: AppColors.lightTextColor, fontSize: 10),
        AppText.medium(
          value ?? "N/A",
          fontSize: 12,
          overflow: TextOverflow.ellipsis,
          maxlines: 1,
        ),
      ],
    );
  }
}

class AppContainer extends StatelessWidget {
  const AppContainer(
    this.title,
    this.actions, {
    this.margin = 36,
    this.hasBorder = true,
    super.key,
  });
  final String title;
  final double margin;
  final bool hasBorder;
  final List<Widget> actions;

  List<Widget> intersperseWithDivider(List<Widget> widgets, Widget divider) {
    if (widgets.isEmpty) return [];
    final result = <Widget>[];
    for (var i = 0; i < widgets.length; i++) {
      if (i > 0) result.add(divider);
      result.add(widgets[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final div = Ui.align(
      align: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsetsGeometry.only(left: margin),
        child: AppDivider(),
      ),
    );
    final actionWidgets = List.generate(actions.length, (i) {
      return Padding(
        padding: EdgeInsets.only(
          top: i == 0 ? 12 : 8.0,
          bottom: i == actions.length - 1 ? 12 : 8,
          left: 8,
          right: 16,
        ),
        child: actions[i],
      );
    });
    final actionList = intersperseWithDivider(actionWidgets, div);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty)
          Ui.align(
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, bottom: 12),
              child: AppText.medium(
                title,
                fontSize: 10,
                color: AppColors.lightTextColor,
              ),
            ),
          ),
        CurvedContainer(
          border: hasBorder ? Border.all(color: AppColors.borderColor) : null,
          radius: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Row(), ...actionList],
          ),
        ),
      ],
    );
  }
}

class AppContainerItem extends StatelessWidget {
  const AppContainerItem(
    this.icon, {
    required this.title,
    required this.desc,
    this.onTap,
    this.color,
    super.key,
  });
  final dynamic icon;
  final Color? color;
  final Widget title;
  final VoidCallback? onTap;
  final Widget desc;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          AppIcon(icon, color: color ?? AppColors.lightTextColor, size: 16),
          Ui.boxWidth(12),
          title,
          Ui.boxWidth(12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [desc],
            ),
          ),
        ],
      ),
    );
  }

  static AppContainerItem text(dynamic icon, String title, String desc) {
    return AppContainerItem(
      icon,
      title: AppText.medium(title, fontSize: 14),
      desc: AppText.thin(desc, fontSize: 12, color: AppColors.lightTextColor),
    );
  }

  static AppContainerItem icony(dynamic icon, String title) {
    return AppContainerItem(
      icon,
      title: AppText.medium(title, fontSize: 14),
      desc: AppIcon(HugeIcons.strokeRoundedArrowUpRight03),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appService = Get.find<AppService>();
    final tecs = List.generate(2, (i) => TextEditingController());
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            children: [
              UserProfilePic(
                url:
                    "${AppUrls.baseURL}/upload/upload/${appService.currentUser.value.image}",
              ),
              Ui.boxHeight(24),
              AppContainer("ACCOUNT", [
                AppContainerItem.text(
                  HugeIcons.strokeRoundedUser,
                  "Full Name",
                  appService.currentUser.value.name ?? "N/A",
                ),
                AppContainerItem.text(
                  HugeIcons.strokeRoundedMail01,
                  "Email",
                  appService.currentUser.value.email ?? "N/A",
                ),
                AppContainerItem.text(
                  HugeIcons.strokeRoundedUserEdit01,
                  "Account Type",
                  appService.currentUser.value.role.capitalize ?? "",
                ),
                AppContainerItem.text(
                  HugeIcons.strokeRoundedSmartPhone01,
                  "Contact",
                  appService.currentUser.value.phone ?? "N/A",
                ),
                // if (appService.currentUser.value.role == "driver")
                //   AppContainerItem.text(
                //     HugeIcons.strokeRoundedRegister,
                //     "Truck Reg No",
                //     appService.currentUser.value.truckno ?? "N/A",
                //   ),
                // AppContainerItem.text(HugeIcons.strokeRoundedMail01, "Email", appService.currentUser.value.email ?? "N/A"),
              ]),
              Ui.boxHeight(24),
              AppContainer("CHANGE PIN", [
                AppContainerItem(
                  HugeIcons.strokeRoundedLockPassword,
                  title: AppText.medium("Reset PIN", fontSize: 14),
                  desc: SizedBox(),
                  onTap: () async {
                    Get.bottomSheet(
                      AppBottomSheet(
                        "Reset PIN",
                        "Reset",
                        onTap: () async {
                          if (tecs[0].text == tecs[1].text &&
                              tecs[0].text.length == 4) {
                            //change password
                            final b = await Get.find<DashboardController>()
                                .appRepo
                                .resetPassword(tecs[0].text);
                            if (b) {
                              Get.back();
                              Ui.showInfo("PIn Successfully changed");
                            }
                          } else {
                            Ui.showError("PIN does not match");
                          }
                        },
                        actions: [
                          CustomTextField(
                            "****",
                            tecs[0],
                            varl: FPL.number,
                            label: "New PIN",
                          ),
                          CustomTextField(
                            "****",
                            tecs[1],
                            varl: FPL.number,
                            label: "Confirm PIN",
                          ),
                        ],
                      ),
                      isScrollControlled: true,
                    );
                  },
                ),
              ]),
              Ui.boxHeight(24),
              AppContainer("ABOUT", [
                InkWell(
                  onTap: () async {
                    await launchUrl(Uri.parse("https://wa.me/+23470672246467"));
                  },
                  child: AppContainerItem.icony(
                    HugeIcons.strokeRoundedHelpCircle,
                    "Help Center",
                  ),
                ),
                InkWell(
                  onTap: () async {
                    // await launchUrl(Uri.parse("https://wa.me/+23470672246467"));
                  },
                  child: AppContainerItem.icony(
                    HugeIcons.strokeRoundedLeftToRightListBullet,
                    "Terms Of Use",
                  ),
                ),
                InkWell(
                  onTap: () async {
                    // await launchUrl(Uri.parse("https://wa.me/+23470672246467"));
                  },
                  child: AppContainerItem.icony(
                    HugeIcons.strokeRoundedMail01,
                    "Privacy Policy",
                  ),
                ),
              ]),
              Ui.boxHeight(24),
              AppContainer("EXIT", [
                AppContainerItem(
                  HugeIcons.strokeRoundedDoor01,
                  title: AppText.medium(
                    "Log Out",
                    color: AppColors.primaryColor,
                    fontSize: 14,
                  ),
                  desc: SizedBox(),
                  color: AppColors.primaryColor,
                  onTap: () async {
                    Get.bottomSheet(
                      AppBottomSheet(
                        "Log Out",
                        "Confirm",
                        msg: "Are you sure you want to log out ?",
                        onTap: () async {
                          await appService.logout();
                          Get.offAllNamed(AppRoutes.auth);
                        },
                      ),
                    );
                  },
                ),
              ]),
              Ui.boxHeight(72),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet(
    this.title,
    this.btnText, {
    this.onTap,
    this.actions = const [],
    this.msg,
    super.key,
  });
  final String title, btnText;
  final String? msg;
  final VoidCallback? onTap;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: CurvedContainer(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 0, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppText.medium(title),
            Ui.boxHeight(24),
            if (msg != null)
              AppText.thin(msg!, fontSize: 12, color: AppColors.lightTextColor),
            if (actions.isNotEmpty) AppContainer("", actions, margin: 0),
            Row(),
            Ui.boxHeight(24),
            SizedBox(
              width: Ui.width(context) / 3,
              child: AppButton(onPressed: onTap, text: btnText),
            ),
            Ui.boxHeight(24),
          ],
        ),
      ),
    );
  }
}

class FieldValue extends StatelessWidget {
  const FieldValue(this.title, {required this.child, super.key});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [AppText.medium(title, fontSize: 14), Ui.boxWidth(8), child],
      ),
    );
  }
}

class AddResource<T> extends StatelessWidget {
  const AddResource(this.title, {this.obj, super.key});
  final String title;
  final T? obj;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    RxList<String> facilities = <String>[].obs;
    Rx<User> curDriver = User().obs;
    RxBool isActive = false.obs;
    RxBool driverVehicle = false.obs;
    RxString loc = "Kano".obs;
    RxString image = "".obs;
    final List<TextEditingController> tecs = List.generate(
      10,
      (i) => TextEditingController(),
    );
    RxString locState =
        (controller.curLoc.value == "All" ? "Kano" : controller.curLoc.value)
            .obs;

    if (obj != null) {
      if (title.toLowerCase() == "users" || title.toLowerCase() == "drivers") {
        final user = obj as User;
        tecs[0].text = user.name ?? "";
        tecs[1].text = user.email ?? "";
        tecs[2].text = user.phone ?? "";
        tecs[3].text = user.role;
        image.value = user.image ?? "";
        tecs[4].text = user.location ?? "Kano";
        tecs[5].text = user.category;
      }

      if (title.toLowerCase() == "facilities" ||
          title.toLowerCase() == "loading points") {
        final user = obj as Location;
        tecs[0].text = user.name ?? "";
        tecs[1].text = user.lga ?? "";
        tecs[2].text = user.facilityType ?? "";
        tecs[3].text = user.state ?? "Kano";
        locState.value = tecs[3].text;
        tecs[4].text = user.code ?? "";
        tecs[5].text = user.address ?? "";
        tecs[6].text = user.phone ?? "";
        tecs[7].text = user.lat?.toString() ?? "";
        tecs[8].text = user.lng?.toString() ?? "";
      }

      if (title.toLowerCase() == "location") {
        final user = obj as StateLocation;
        tecs[0].text = user.name;
        tecs[1].text = user.code;
        isActive.value = user.isActive ?? false;
      }

      if (title.toLowerCase() == "vehicles") {
        final vehicle = obj as Vehicle;
        tecs[0].text = vehicle.name ?? "";
        tecs[1].text = vehicle.regno ?? "";
        tecs[2].text = vehicle.type ?? "";
        tecs[3].text = vehicle.driver ?? "";
        tecs[4].text = vehicle.category ?? "";
        isActive.value = vehicle.isActive;

        image.value = vehicle.image ?? "";
        curDriver.value =
            controller.allDrivers.firstWhereOrNull(
              (e) => e.name == tecs[3].text,
            ) ??
            User();
      }

      if (title.toLowerCase() == "trips") {
        final delivery = obj as Delivery;
        tecs[0].text = delivery.pickup ?? "";
        facilities.value = delivery.stops;
        tecs[2].text = delivery.driver ?? "";
        tecs[3].text = delivery.truckno ?? "";
        tecs[4].text = delivery.waybill;
        tecs[1].text = delivery.invoiceno ?? "";
        tecs[5].text = delivery.commodityType ?? "Drug Revolving Fund (DRF)";
        tecs[6].text = delivery.deliveryType ?? "Last Mile Delivery (LMD)";
      }

      if (title.toLowerCase() == "var records") {
        final varCtrl = Get.find<VarController>();
        final varRec = obj as VarRecord;
        varCtrl.populateFromVar(varRec);
        tecs[4].text = varRec.waybill;
        facilities.value = varCtrl.stops.isNotEmpty
            ? List.from(varCtrl.stops)
            : [""];
      }
    } else {
      if (title.toLowerCase() == "trips" ||
          title.toLowerCase() == "var records" ||
          title.toLowerCase() == "varrecords") {
        controller
            .generateWayBill(
              controller.allActiveStateLocations.firstWhere(
                (test) => test.name == locState.value,
              ),
              title.toLowerCase() == "trips" ? "TBL" : "VAR",
            )
            .then((v) {
              tecs[4].text = v;
            });
        facilities.value = [""];
      }
    }

    return SingleChildScrollView(
      child: AppBottomSheet(
        obj == null ? "Add $title" : "Edit $title",
        obj == null ? "Add" : "Edit",
        onTap: () async {
          try {
            if (title.toLowerCase() == "trips") {
              if (UtilFunctions.validateTecs(tecs.sublist(0, 4))) {
                if (obj == null) {
                  //add trip
                  await controller.addDelivery(
                    tecs[4].text,
                    facilities,
                    controller.allDrivers
                        .firstWhere((d) => d.name == tecs[2].text)
                        .id,
                    controller.allVehicles
                        .firstWhere((v) => v.desc == tecs[3].text)
                        .id,
                    tecs[0].text,
                    tecs[3].text,
                    tecs[1].text,
                    tecs[5].text,
                    tecs[6].text,
                  );
                } else {
                  //edit trip
                  final trip = obj as Delivery;
                  await controller.appRepo.updateDelivery(
                    tecs[4].text,
                    facilities,
                    controller.allDrivers
                        .firstWhere((d) => d.name == tecs[2].text)
                        .id,
                    controller.allVehicles
                        .firstWhere((v) => v.desc == tecs[3].text)
                        .id,
                    tecs[0].text,
                    tecs[3].text,
                    tecs[1].text,
                    tecs[5].text,
                    tecs[6].text,
                    trip.id,
                  );
                }
                Ui.showInfo("Successfully saved");
              } else {
                throw "All Fields are mandatory to fill";
              }
            } else if (title.toLowerCase() == "users" ||
                title.toLowerCase() == "drivers") {
              if (title.toLowerCase() == "drivers") {
                tecs[3].text = "driver";
              }
              if (UtilFunctions.validateTecs(tecs.sublist(0, 5))) {
                if (obj == null) {
                  //add user
                  await controller.addUser(
                    tecs[0].text,
                    tecs[1].text,
                    tecs[2].text,
                    tecs[3].text,
                    tecs[4].text,
                    tecs[5].text,
                    image: image.value,
                  );
                } else {
                  //edit user
                  final user = obj as User;
                  await controller.editUser(
                    tecs[0].text,
                    tecs[1].text,
                    tecs[2].text,
                    tecs[3].text,
                    tecs[4].text,
                    tecs[5].text,
                    user.id,
                    image: image.value,
                  );
                }
                Ui.showInfo("Successfully saved");
              } else {
                throw "All Fields are mandatory to fill";
              }
            } else if (title.toLowerCase() == "facilities" ||
                title.toLowerCase() == "loading points") {
              if (title.toLowerCase() == "loading points") {
                tecs[2].text = "Loading Point";
              }
              if (UtilFunctions.validateTecs(tecs.sublist(0, 4))) {
                if (obj == null) {
                  //add user
                  await controller.addLocation(
                    tecs[0].text,
                    tecs[3].text,
                    tecs[1].text,
                    tecs[2].text,
                    tecs[4].text,
                    tecs[5].text,
                    tecs[6].text,
                    double.tryParse(tecs[7].text) ?? 0,
                    double.tryParse(tecs[8].text) ?? 0,
                  );
                } else {
                  //edit user
                  final user = obj as Location;
                  await controller.editLocation(
                    tecs[0].text,
                    tecs[3].text,
                    tecs[1].text,
                    tecs[2].text,
                    tecs[4].text,
                    tecs[5].text,
                    tecs[6].text,
                    double.tryParse(tecs[7].text) ?? 0,
                    double.tryParse(tecs[8].text) ?? 0,
                    user.id,
                  );
                }

                Ui.showInfo("Successfully saved");
              } else {
                throw "All Fields are mandatory to fill";
              }
            } else if (title.toLowerCase() == "vehicles") {
              if (UtilFunctions.validateTecs(tecs.sublist(0, 2))) {
                if (obj == null) {
                  //add vehicle
                  await controller.appRepo.addVehicle(
                    tecs[0].text,
                    tecs[1].text,
                    tecs[2].text,
                    isActive.value,
                    tecs[4].text,
                    driver: (curDriver.value.name?.isEmpty ?? true)
                        ? null
                        : curDriver.value.name,
                    driverid: curDriver.value.id == 0
                        ? null
                        : curDriver.value.id,
                    image: image.value,
                  );
                } else {
                  //edit vehicle
                  final vehicle = obj as Vehicle;
                  await controller.appRepo.updateVehicle(
                    tecs[0].text,
                    tecs[1].text,
                    tecs[2].text,
                    isActive.value,
                    tecs[4].text,
                    vehicle.id,
                    driver: (curDriver.value.name?.isEmpty ?? true)
                        ? null
                        : curDriver.value.name,
                    driverid: curDriver.value.id == 0
                        ? null
                        : curDriver.value.id,
                    image: image.value,
                  );
                }

                Ui.showInfo("Successfully saved");
              } else {
                throw "All Fields are mandatory to fill";
              }
            } else if (title.toLowerCase() == "var records" ||
                title.toLowerCase() == "varrecords") {
              final varCtrl = Get.find<VarController>();
              if (varCtrl.selectedDriverId.value == 0 ||
                  varCtrl.selectedVehicleId.value == 0 ||
                  varCtrl.pickup.value.isEmpty ||
                  varCtrl.stops.isEmpty ||
                  varCtrl.stops.first.isEmpty) {
                throw "Please complete the Trip Details (Driver, Vehicle, Origin, Destination).";
              }
              if (obj == null) {
                await varCtrl.createVar({
                  'waybill': tecs[4].text,
                  'pickup': varCtrl.pickup.value,
                  'stops': varCtrl.stops.map((e) => e).toList(),
                  'truckno': varCtrl.truckNo.text.trim(),
                  'commoditytype': varCtrl.commodityType.value,
                  'deliverytype': 'Last Mile Delivery (LMD)',
                });
              } else {
                final varRec = obj as VarRecord;
                await varCtrl.updateVar(varRec.id, {
                  'waybill': tecs[4].text,
                  'pickup': varCtrl.pickup.value,
                  'stops': varCtrl.stops.map((e) => e).toList(),
                  'truckno': varCtrl.truckNo.text.trim(),
                  'commoditytype': varCtrl.commodityType.value,
                  'deliverytype': 'Last Mile Delivery (LMD)',
                });
              }
            } else if (title.toLowerCase() == "location") {
              if (obj == null) {
                await controller.addStateLocation(
                  tecs[0].text,
                  isActive.value,
                  tecs[1].text,
                );
              } else {
                final user = obj as StateLocation;
                await controller.editStateLocation(
                  tecs[0].text,
                  isActive.value,
                  tecs[1].text,
                  user.id,
                );
              }
            }
            await controller.initApp();
            controller.refreshResource();

            Get.back();
            controller.currentModelIndex.value = 0;
          } catch (e) {
            Ui.showError(e.toString());
          }
        },
        actions: [
          //TRIP or VAR (State and Waybill common fields)
          if (title.toLowerCase() == "trips" ||
              title.toLowerCase() == "var records" ||
              title.toLowerCase() == "varrecords") ...[
            if (controller.curLoc.value == "All")
              CustomDropdown.city(
                cities: [
                  ...controller.allActiveStateLocations.map(
                    (e) => e.name ?? "",
                  ),
                ],
                hint: "Add State",
                label: "State",
                selectedValue: "Kano",
                onChanged: (v) {
                  loc.value = v ?? "Kano";
                  controller
                      .generateWayBill(
                        controller.allActiveStateLocations.firstWhere(
                          (test) => test.name == v,
                        ),
                        title.toLowerCase() == "trips" ? "TBL" : "VAR",
                      )
                      .then((v) {
                        tecs[4].text = v;
                      });
                },
              ),
            CustomTextField(
              "Waybill",
              tecs[4],
              label: "Waybill",
              readOnly: true,
            ),
          ],
          //TRIP specifically
          if (title.toLowerCase() == "trips") ...[
            Obx(() {
              if (loc.value != "Kano") {
                return SizedBox();
              }
              return CustomDropdown.city(
                cities: [
                  "Drug Revolving Fund (DRF)",
                  "Basic Health Care Provision Fund (BHCPF)",
                  "Kano State Contributory Health Management Agency (KSCHMA)",
                  "Maternal & Child Health Care (MNCH)",
                  "Family Planning (FP)",
                  "IMPACT Project",
                ],
                hint: "Add Commodity Type",
                label: "Commodity Type",
                selectedValue: tecs[5].text.isEmpty
                    ? "Drug Revolving Fund (DRF)"
                    : tecs[5].text,
                onChanged: (v) {
                  tecs[5].text = v ?? "Drug Revolving Fund (DRF)";
                },
              );
            }),
            CustomDropdown.city(
              cities: ["Last Mile Delivery (LMD)", "Proxy Delivery"],
              hint: "Add Delivery Type",
              label: "Delivery Type",
              selectedValue: tecs[6].text.isEmpty
                  ? "Last Mile Delivery (LMD)"
                  : tecs[6].text,
              onChanged: (v) {
                tecs[6].text = v ?? "Last Mile Delivery (LMD)";
              },
            ),
            Obx(() {
              return CustomDropdown.city(
                cities: controller.allLoadingPoints
                    .where((e) => e.state == loc.value)
                    .map((e) => e.desc)
                    .toList(),
                hint: "Add Loading Point",
                label: "Loading Point",
                selectedValue: tecs[0].text,
                onChanged: (v) {
                  tecs[0].text = v ?? "";
                },
              );
            }),
            Obx(() {
              final gf = List.generate(facilities.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i == facilities.length - 1 ? 0 : 8.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomDropdown.city(
                          cities: controller.allFacilities
                              .map((e) => e.desc)
                              .toList(),
                          hint: "Add Facility",
                          label: "Facility ${i + 1}",
                          selectedValue: facilities[i],
                          onChanged: (v) {
                            if (facilities.contains(v)) {
                              facilities[i] = "";
                              Ui.showError("Facility already selected");
                            } else {
                              facilities[i] = v ?? "";
                            }
                          },
                        ),
                      ),
                      Ui.boxWidth(8),
                      CircleIcon(
                        HugeIcons.strokeRoundedAdd01,
                        onTap: () {
                          facilities.add("");
                        },
                        radius: 12,
                        size: 16,
                      ),
                      if (facilities.length > 1) Ui.boxWidth(8),

                      if (facilities.length > 1)
                        CircleIcon(
                          HugeIcons.strokeRoundedMinusSign,
                          onTap: () {
                            facilities.removeAt(i);
                          },
                          radius: 12,
                          size: 16,
                        ),
                    ],
                  ),
                );
              });
              return Column(children: gf);
            }),

            Obx(() {
              print(driverVehicle.value);
              return CustomDropdown.city(
                cities: controller.allDrivers.map((e) => e.name ?? "").toList(),
                hint: "Add Driver",
                label: "Driver",
                selectedValue: tecs[2].text,
                onChanged: (v) {
                  tecs[2].text = v ?? "";
                  tecs[3].text =
                      controller.allVehicles
                          .firstWhereOrNull((test) => test.driver == v)
                          ?.desc ??
                      tecs[3].text;
                  driverVehicle.value = !driverVehicle.value;
                },
              );
            }),
            Obx(() {
              print(driverVehicle.value);
              return CustomDropdown.city(
                cities: controller.allVehicles
                    .where((test) => test.isActive)
                    .map((e) => e.desc)
                    .toList(),
                hint: "Add Vehicle",
                label: "Vehicle",
                selectedValue: tecs[3].text,
                onChanged: (v) {
                  tecs[3].text = v ?? "";
                  tecs[2].text =
                      controller.allVehicles
                          .firstWhereOrNull((test) => test.name == v)
                          ?.driver ??
                      tecs[2].text;
                  driverVehicle.value = !driverVehicle.value;
                },
              );
            }),
            CustomTextField("Add Invoice No", tecs[1], label: "Invoice No"),
          ],
          //USER OR VEHICLE
          if (title.toLowerCase() == "users" ||
              title.toLowerCase() == "drivers" ||
              title.toLowerCase() == "vehicles")
            InkWell(
              onTap: () async {
                final f = await Get.bottomSheet<String>(ChooseCam());
                print(f);
                image.value = f ?? image.value;
              },
              child: Obx(() {
                return UserProfilePic(
                  url: image.value.isEmpty
                      ? ""
                      : UtilFunctions.isFile(image.value)
                      ? image.value
                      : "${AppUrls.baseURL}/upload/upload/${image.value}",
                );
              }),
            ),

          //USER
          if (title.toLowerCase() == "users") ...[
            CustomTextField("Add user", tecs[0], label: "Name"),
            CustomTextField("Add email", tecs[1], label: "Email"),
            CustomTextField("Add phone", tecs[2], label: "Phone"),
            CustomDropdown.city(
              cities: ["driver", "admin", "operator"],
              hint: "Add account type",
              label: "Account type",
              selectedValue: tecs[3].text,
              onChanged: (v) {
                tecs[3].text = v ?? "";
              },
            ),
            CustomDropdown.city(
              cities: [
                "All",
                ...controller.allActiveStateLocations.map((e) => e.name),
              ],
              hint: "Add location",
              label: "Location",
              selectedValue: tecs[4].text,
              onChanged: (v) {
                tecs[4].text = v ?? "";
              },
            ),
          ],

          //DRIVER
          if (title.toLowerCase() == "drivers") ...[
            CustomTextField("Add name", tecs[0], label: "Name"),
            CustomTextField("Add email", tecs[1], label: "Email"),
            CustomTextField("Add phone", tecs[2], label: "Phone"),
            CustomDropdown.city(
              cities: ["TBL", "Commercial"],
              hint: "Category",
              label: "Category",
              selectedValue: tecs[5].text,
              onChanged: (v) {
                tecs[5].text = v ?? "";
              },
            ),
            CustomDropdown.city(
              cities: [
                ...controller.allActiveStateLocations.map((e) => e.name),
              ],
              hint: "Add location",
              label: "Location",
              selectedValue: tecs[4].text,
              onChanged: (v) {
                tecs[4].text = v ?? "";
              },
            ),
          ],

          //Location
          if (title.toLowerCase() == "facilities")
            CustomDropdown.city(
              cities: ["Hospital", "Clinic", "Loading Point"],
              hint: "",
              label: "Facilty Type",
              selectedValue: tecs[2].text,
              onChanged: (v) {
                tecs[2].text = v ?? "";
              },
            ),
          if (title.toLowerCase() == "facilities" ||
              title.toLowerCase() == "loading points") ...[
            CustomTextField("Add name", tecs[0], label: "Name"),
            CustomTextField("Add Facility Code", tecs[4], label: "Code"),
            CustomDropdown.city(
              cities: [
                ...controller.allActiveStateLocations.map((e) => e.name),
              ],
              hint: "Add State",
              label: "State",
              selectedValue: tecs[3].text,
              onChanged: (v) {
                tecs[3].text = v ?? "";
                locState.value = v ?? "Kano";
                tecs[1].text =
                    (lgas
                            .where(
                              (e) =>
                                  e["state"] ==
                                  (locState.value.isEmpty
                                      ? "Kano"
                                      : locState.value),
                            )
                            .first["lgas"]
                        as List<String>)[0];
              },
            ),
            Obx(() {
              return CustomDropdown.city(
                cities:
                    lgas
                            .where(
                              (e) =>
                                  e["state"] ==
                                  (locState.value.isEmpty
                                      ? "Kano"
                                      : locState.value),
                            )
                            .first["lgas"]
                        as List<String>,
                hint: "Select LGA",
                label: "LGA",
                selectedValue: tecs[1].text,
                onChanged: (v) {
                  tecs[1].text = v ?? "";
                },
              );
            }),
            CustomTextField("1 John Street", tecs[5], label: "Address"),
            CustomTextField(
              "+2347012345678",
              tecs[6],
              label: "Phone Number",
              varl: FPL.phone,
            ),
            CustomTextField(
              "6.33333",
              tecs[7],
              label: "Latitude",
              varl: FPL.number,
            ),
            CustomTextField(
              "3.6666",
              tecs[8],
              label: "Longitude",
              varl: FPL.number,
            ),
          ],
          //VEHICLE
          if (title.toLowerCase() == "vehicles") ...[
            CustomTextField("Vehicle Name", tecs[0], label: "Make & Model"),
            CustomTextField("Reg Number", tecs[1], label: "Plate number"),
            CustomDropdown.city(
              cities: ["Bus", "Truck", "Pickup"],
              hint: "Vehicle Type",
              label: "Vehicle Type",
              selectedValue: tecs[2].text,
              onChanged: (v) {
                tecs[2].text = v ?? "";
              },
            ),
            CustomDropdown.city(
              cities: ["TBL", "Commercial"],
              hint: "Category",
              label: "Category",
              selectedValue: tecs[4].text,
              onChanged: (v) {
                tecs[4].text = v ?? "";
              },
            ),
            Obx(() {
              print(driverVehicle.value);
              return CustomDropdown.city(
                cities:
                    controller.allDrivers
                        // .where(
                        //   (e) => !controller.allVehicles.any(
                        //     (v) => v.driver == e.name,
                        //   ),
                        // )
                        .map((e) => e.name ?? "")
                        .toList()
                      ..insert(0, ""),
                hint: "Add Driver",
                label: "Assign Driver",
                selectedValue: tecs[3].text,
                onChanged: (v) {
                  if (v != null && v.isNotEmpty) {
                    final assignedVehicle = controller.allVehicles
                        .firstWhereOrNull((va) => va.driver == v);
                    if (assignedVehicle != null) {
                      Ui.showError(
                        "Driver already assigned to ${assignedVehicle.desc}",
                      );
                      tecs[3].text = curDriver.value.name ?? "";
                      driverVehicle.value = !driverVehicle.value;
                      return;
                    }
                  }
                  tecs[3].text = v ?? curDriver.value.name ?? "";
                  curDriver.value = v == null
                      ? User()
                      : controller.allDrivers.firstWhereOrNull(
                              (e) => e.name == v,
                            ) ??
                            User();

                  driverVehicle.value = !driverVehicle.value;
                },
              );
            }),
            Row(
              children: [
                AppText.medium("Enabled", fontSize: 14),
                Spacer(),
                Obx(() {
                  return Switch(
                    value: isActive.value,
                    activeThumbColor: AppColors.green,
                    onChanged: (v) {
                      isActive.value = v;
                    },
                  );
                }),
              ],
            ),
          ],
		  if (title.toLowerCase() == "location") ...[
            CustomTextField("Add name", tecs[0], label: "Name"),
            CustomTextField("Add Code", tecs[1], label: "Code"),
            Row(
              children: [
                AppText.medium("Enabled", fontSize: 14),
                Spacer(),
                Obx(() {
                  return Switch(
                    value: isActive.value,
                    activeThumbColor: AppColors.green,
                    onChanged: (v) {
                      isActive.value = v;
                    },
                  );
                }),
              ],
            ),
          ],
          //Location
          // if (title.toLowerCase() == "loading points")
          //   CustomTextField("Add name", tecs[0], label: "Name"),
          // if (title.toLowerCase() == "loading points")
          //   CustomTextField("Add address", tecs[1], label: "Address"),
          // if (title.toLowerCase() == "loading points")
          //   CustomDropdown.city(
          //     cities: ["Hospital", "Clinic","Loading Point"],
          //     hint: "",
          //     label: "Facilty Type",
          //     selectedValue: tecs[2].text,
          //     onChanged: (v) {
          //       tecs[2].text = v ?? "";
          //     },
          //   ),
          // if (title.toLowerCase() == "loading points")
          //   CustomDropdown.city(
          //     cities: ["Kano", "Kaduna"],
          //     hint: "Add State",
          //     label: "State",
          //     selectedValue: tecs[2].text,
          //     onChanged: (v) {
          //       tecs[3].text = v ?? "";
          //     },
          //   ),
          if (title.toLowerCase() == "var records" ||
              title.toLowerCase() == "varrecords")
            ...buildVarFormFields(context),
        ],
      ),
    );
  }
}

class FilterResource<T> extends StatelessWidget {
  const FilterResource(this.title, {this.obj = const [], super.key});
  final String title;
  final List<T> obj;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final tecs = List.generate(6, (i) => <String>[]);

    return SingleChildScrollView(
      child: AppBottomSheet(
        "Filter $title",
        "Apply",
        onTap: () async {
          try {
            tecs.removeWhere((element) => element.isEmpty);
            controller.curFilters.value = tecs;

            Get.back();
          } catch (e) {
            Ui.showError(e.toString());
          }
        },
        actions: [
          //TRIP
          if (title.toLowerCase() == "trips") ...[
            CustomDropdown.cities(
              cities: (obj as List<Delivery>)
                  .map((e) => e.pickup ?? "")
                  .toSet()
                  .toList(),
              hint: "Select Pickup",
              label: "Pickup",
              selectedValue: tecs[0],
              onChanged: (v) {
                tecs[0] = (v as List).map((e) => e.toString()).toList();
              },
            ),
            CustomDropdown.cities(
              cities: (obj as List<Delivery>)
                  .map((e) => e.stops)
                  .expand((x) => x)
                  .toSet()
                  .toList(),
              hint: "Select Stops",
              label: "Stops",
              selectedValue: tecs[1],
              onChanged: (v) {
                tecs[1] = (v as List).map((e) => e.toString()).toList();
              },
            ),
            CustomDropdown.cities(
              cities: (obj as List<Delivery>)
                  .map((e) => e.owner ?? '')
                  .toSet()
                  .toList(),
              hint: "Select Creator",
              label: "Creator",
              selectedValue: tecs[2],
              onChanged: (v) {
                tecs[2] = (v as List).map((e) => e.toString()).toList();
              },
            ),
            CustomDropdown.cities(
              cities: (obj as List<Delivery>)
                  .map((e) => e.driver ?? '')
                  .toSet()
                  .toList(),
              hint: "Select Driver",
              label: "Driver",
              selectedValue: tecs[3],
              onChanged: (v) {
                tecs[3] = (v as List).map((e) => e.toString()).toList();
              },
            ),
            CustomDropdown.cities(
              cities: (obj as List<Delivery>)
                  .map((e) => e.status)
                  .toSet()
                  .toList(),
              hint: "Select Status",
              label: "Status",
              selectedValue: tecs[4],
              onChanged: (v) {
                tecs[4] = (v as List).map((e) => e.toString()).toList();
              },
            ),
          ],

          //USER
          if (title.toLowerCase() == "users" ||
              title.toLowerCase() == "drivers") ...[
            CustomDropdown.cities(
              cities: (obj as List<User>)
                  .map((e) => e.location ?? "")
                  .toSet()
                  .toList(),
              hint: "Select Location",
              label: "Location",
              selectedValue: tecs[0],
              onChanged: (v) {
                tecs[0] = (v as List).map((e) => e.toString()).toList();
              },
            ),
            if (title.toLowerCase() == "users")
              CustomDropdown.cities(
                cities: (obj as List<User>).map((e) => e.role).toSet().toList(),
                hint: "Select Role",
                label: "Role",
                selectedValue: tecs[1],
                onChanged: (v) {
                  tecs[1] = (v as List).map((e) => e.toString()).toList();
                },
              ),
          ],

          //VEHICLE
          if (title.toLowerCase() == "vehicles") ...[
            CustomDropdown.cities(
              cities: (obj as List<Vehicle>)
                  .map((e) => e.type ?? "")
                  .toSet()
                  .toList(),
              hint: "Select Vehicle Type",
              label: "Vehicle Type",
              selectedValue: tecs[0],
              onChanged: (v) {
                tecs[0] = (v as List).map((e) => e.toString()).toList();
              },
            ),
            CustomDropdown.cities(
              cities: (obj as List<Vehicle>)
                  .map((e) => e.driver ?? "")
                  .toSet()
                  .toList(),
              hint: "Select Driver",
              label: "Driver",
              selectedValue: tecs[1],
              onChanged: (v) {
                tecs[1] = (v as List).map((e) => e.toString()).toList();
              },
            ),
            CustomDropdown.cities(
              cities: (obj as List<Vehicle>)
                  .map((e) => e.isActive ? "Active" : "Inactive")
                  .toSet()
                  .toList(),
              hint: "Select Status",
              label: "Status",
              selectedValue: tecs[2],
              onChanged: (v) {
                tecs[2] = (v as List).map((e) => e.toString()).toList();
              },
            ),
          ],

          //state locations
          if (title.toLowerCase() == "location") ...[
            CustomDropdown.cities(
              cities: (obj as List<StateLocation>)
                  .map((e) => e.name)
                  .toSet()
                  .toList(),
              hint: "Select State",
              label: "State",
              selectedValue: tecs[0],
              onChanged: (v) {
                tecs[0] = (v as List).map((e) => e.toString()).toList();
              },
            ),
          ],

          //loading point and facilities
          if (title.toLowerCase() == "facilities" ||
              title.toLowerCase() == "loading points") ...[
            CustomDropdown.cities(
              cities: (obj as List<Location>)
                  .map((e) => e.lga ?? "")
                  .toSet()
                  .toList(),
              hint: "Select LGA",
              label: "LGA",
              selectedValue: tecs[0],
              onChanged: (v) {
                tecs[0] = (v as List).map((e) => e.toString()).toList();
              },
            ),
            CustomDropdown.cities(
              cities: (obj as List<Location>)
                  .map((e) => e.state ?? "")
                  .toSet()
                  .toList(),
              hint: "Select State",
              label: "State",
              selectedValue: tecs[1],
              onChanged: (v) {
                tecs[1] = (v as List).map((e) => e.toString()).toList();
              },
            ),
            CustomDropdown.cities(
              cities: (obj as List<Location>)
                  .map((e) => e.isActive ? "Active" : "Inactive")
                  .toSet()
                  .toList(),
              hint: "Select Status",
              label: "Status",
              selectedValue: tecs[2],
              onChanged: (v) {
                tecs[2] = (v as List).map((e) => e.toString()).toList();
              },
            ),
          ],
        ],
      ),
    );
  }
}

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    Rx<Delivery> dlv = Delivery(createdAt: DateTime.now()).obs;
    final controller = Get.find<DashboardController>();
    return SinglePageScaffold(
      title: "WayBill QR Scanner",
      child: Center(
        child: MobileScanner(
          onDetect: (result) {
            String? qrcode = result.barcodes.isEmpty
                ? null
                : result.barcodes.first.rawValue;
            if (qrcode == null || qrcode.isEmpty) {
              Ui.showError("No QR Code found");
              return;
            }
            final waybill = qrcode;
            dlv.value =
                (controller.appRepo.appService.currentUser.value.isAdmin
                        ? controller.allCustomerDeliveries
                        : controller.allDeliveries)
                    .where((test) => test.waybill == waybill)
                    .firstOrNull ??
                Delivery(createdAt: DateTime.now());
            if (dlv.value.id == 0) {
              Ui.showError("No Delivery Found for $waybill");
              return;
            }
            Ui.showInfo("Scanned Code: $qrcode");
            Get.to(WaybillDetailPage(dlv.value));
          },
          fit: BoxFit.cover,
          controller: MobileScannerController(
            facing: CameraFacing.back,
            torchEnabled: false,
          ),
        ),
      ),
    );
  }
}

const lgas = [
  {
    "state": "Abia",
    "lgas": [
      "Aba North",
      "Aba South",
      "Arochukwu",
      "Bende",
      "Ikawuno",
      "Ikwuano",
      "Isiala-Ngwa North",
      "Isiala-Ngwa South",
      "Isuikwuato",
      "Umu Nneochi",
      "Obi Ngwa",
      "Obioma Ngwa",
      "Ohafia",
      "Ohaozara",
      "Osisioma",
      "Ugwunagbo",
      "Ukwa West",
      "Ukwa East",
      "Umuahia North",
      "Umuahia South",
    ],
  },
  {
    "state": "Adamawa",
    "lgas": [
      "Demsa",
      "Fufore",
      "Ganye",
      "Girei",
      "Gombi",
      "Guyuk",
      "Hong",
      "Jada",
      "Lamurde",
      "Madagali",
      "Maiha",
      "Mayo-Belwa",
      "Michika",
      "Mubi-North",
      "Mubi-South",
      "Numan",
      "Shelleng",
      "Song",
      "Toungo",
      "Yola North",
      "Yola South",
    ],
  },
  {
    "state": "Akwa Ibom",
    "lgas": [
      "Abak",
      "Eastern-Obolo",
      "Eket",
      "Esit-Eket",
      "Essien-Udim",
      "Etim-Ekpo",
      "Etinan",
      "Ibeno",
      "Ibesikpo-Asutan",
      "Ibiono-Ibom",
      "Ika",
      "Ikono",
      "Ikot-Abasi",
      "Ikot-Ekpene",
      "Ini",
      "Itu",
      "Mbo",
      "Mkpat-Enin",
      "Nsit-Atai",
      "Nsit-Ibom",
      "Nsit-Ubium",
      "Obot-Akara",
      "Okobo",
      "Onna",
      "Oron",
      "Oruk Anam",
      "Udung-Uko",
      "Ukanafun",
      "Urue-Offong/Oruko",
      "Uruan",
      "Uyo",
    ],
  },
  {
    "state": "Anambra",
    "lgas": [
      "Aguata",
      "Anambra East",
      "Anambra West",
      "Anaocha",
      "Awka North",
      "Awka South",
      "Ayamelum",
      "Dunukofia",
      "Ekwusigo",
      "Idemili-North",
      "Idemili-South",
      "Ihiala",
      "Njikoka",
      "Nnewi-North",
      "Nnewi-South",
      "Ogbaru",
      "Onitsha-North",
      "Onitsha-South",
      "Orumba-North",
      "Orumba-South",
    ],
  },
  {
    "state": "Bauchi",
    "lgas": [
      "Alkaleri",
      "Bauchi",
      "Bogoro",
      "Damban",
      "Darazo",
      "Dass",
      "Gamawa",
      "Ganjuwa",
      "Giade",
      "Itas\/Gadau",
      "Jama'Are",
      "Katagum",
      "Kirfi",
      "Misau",
      "Ningi",
      "Shira",
      "Tafawa-Balewa",
      "Toro",
      "Warji",
      "Zaki",
    ],
  },
  {
    "state": "Benue",
    "lgas": [
      "Ado",
      "Agatu",
      "Apa",
      "Buruku",
      "Gboko",
      "Guma",
      "Gwer-East",
      "Gwer-West",
      "Katsina-Ala",
      "Konshisha",
      "Kwande",
      "Logo",
      "Makurdi",
      "Ogbadibo",
      "Ohimini",
      "Oju",
      "Okpokwu",
      "Otukpo",
      "Tarka",
      "Ukum",
      "Ushongo",
      "Vandeikya",
    ],
  },
  {
    "state": "Borno",
    "lgas": [
      "Abadam",
      "Askira-Uba",
      "Bama",
      "Bayo",
      "Biu",
      "Chibok",
      "Damboa",
      "Dikwa",
      "Gubio",
      "Guzamala",
      "Gwoza",
      "Hawul",
      "Jere",
      "Kaga",
      "Kala\/Balge",
      "Konduga",
      "Kukawa",
      "Kwaya-Kusar",
      "Mafa",
      "Magumeri",
      "Maiduguri",
      "Marte",
      "Mobbar",
      "Monguno",
      "Ngala",
      "Nganzai",
      "Shani",
    ],
  },
  {
    "state": "Bayelsa",
    "lgas": [
      "Brass",
      "Ekeremor",
      "Kolokuma\/Opokuma",
      "Nembe",
      "Ogbia",
      "Sagbama",
      "Southern-Ijaw",
      "Yenagoa",
    ],
  },
  {
    "state": "Cross River",
    "lgas": [
      "Abi",
      "Akamkpa",
      "Akpabuyo",
      "Bakassi",
      "Bekwarra",
      "Biase",
      "Boki",
      "Calabar-Municipal",
      "Calabar-South",
      "Etung",
      "Ikom",
      "Obanliku",
      "Obubra",
      "Obudu",
      "Odukpani",
      "Ogoja",
      "Yakurr",
      "Yala",
    ],
  },
  {
    "state": "Delta",
    "lgas": [
      "Aniocha North",
      "Aniocha-North",
      "Aniocha-South",
      "Bomadi",
      "Burutu",
      "Ethiope-East",
      "Ethiope-West",
      "Ika-North-East",
      "Ika-South",
      "Isoko-North",
      "Isoko-South",
      "Ndokwa-East",
      "Ndokwa-West",
      "Okpe",
      "Oshimili-North",
      "Oshimili-South",
      "Patani",
      "Sapele",
      "Udu",
      "Ughelli-North",
      "Ughelli-South",
      "Ukwuani",
      "Uvwie",
      "Warri South-West",
      "Warri North",
      "Warri South",
    ],
  },
  {
    "state": "Ebonyi",
    "lgas": [
      "Abakaliki",
      "Afikpo-North",
      "Afikpo South (Edda)",
      "Ebonyi",
      "Ezza-North",
      "Ezza-South",
      "Ikwo",
      "Ishielu",
      "Ivo",
      "Izzi",
      "Ohaukwu",
      "Onicha",
    ],
  },
  {
    "state": "Edo",
    "lgas": [
      "Akoko Edo",
      "Egor",
      "Esan-Central",
      "Esan-North-East",
      "Esan-South-East",
      "Esan-West",
      "Etsako-Central",
      "Etsako-East",
      "Etsako-West",
      "Igueben",
      "Ikpoba-Okha",
      "Oredo",
      "Orhionmwon",
      "Ovia-North-East",
      "Ovia-South-West",
      "Owan East",
      "Owan-West",
      "Uhunmwonde",
    ],
  },
  {
    "state": "Ekiti",
    "lgas": [
      "Ado-Ekiti",
      "Efon",
      "Ekiti-East",
      "Ekiti-South-West",
      "Ekiti-West",
      "Emure",
      "Gbonyin",
      "Ido-Osi",
      "Ijero",
      "Ikere",
      "Ikole",
      "Ilejemeje",
      "Irepodun\/Ifelodun",
      "Ise-Orun",
      "Moba",
      "Oye",
    ],
  },
  {
    "state": "Enugu",
    "lgas": [
      "Aninri",
      "Awgu",
      "Enugu-East",
      "Enugu-North",
      "Enugu-South",
      "Ezeagu",
      "Igbo-Etiti",
      "Igbo-Eze-North",
      "Igbo-Eze-South",
      "Isi-Uzo",
      "Nkanu-East",
      "Nkanu-West",
      "Nsukka",
      "Oji-River",
      "Udenu",
      "Udi",
      "Uzo-Uwani",
    ],
  },
  {
    "state": "Federal Capital Territory",
    "lgas": ["Abuja", "Kwali", "Kuje", "Gwagwalada", "Bwari", "Abaji"],
  },
  {
    "state": "Gombe",
    "lgas": [
      "Akko",
      "Balanga",
      "Billiri",
      "Dukku",
      "Funakaye",
      "Gombe",
      "Kaltungo",
      "Kwami",
      "Nafada",
      "Shongom",
      "Yamaltu\/Deba",
    ],
  },
  {
    "state": "Imo",
    "lgas": [
      "Aboh-Mbaise",
      "Ahiazu-Mbaise",
      "Ehime-Mbano",
      "Ezinihitte",
      "Ideato-North",
      "Ideato-South",
      "Ihitte\/Uboma",
      "Ikeduru",
      "Isiala-Mbano",
      "Isu",
      "Mbaitoli",
      "Ngor-Okpala",
      "Njaba",
      "Nkwerre",
      "Nwangele",
      "Obowo",
      "Oguta",
      "Ohaji-Egbema",
      "Okigwe",
      "Onuimo",
      "Orlu",
      "Orsu",
      "Oru-East",
      "Oru-West",
      "Owerri-Municipal",
      "Owerri-North",
      "Owerri-West",
    ],
  },
  {
    "state": "Jigawa",
    "lgas": [
      "Auyo",
      "Babura",
      "Biriniwa",
      "Birnin-Kudu",
      "Buji",
      "Dutse",
      "Gagarawa",
      "Garki",
      "Gumel",
      "Guri",
      "Gwaram",
      "Gwiwa",
      "Hadejia",
      "Jahun",
      "Kafin-Hausa",
      "Kaugama",
      "Kazaure",
      "Kiri kasama",
      "Maigatari",
      "Malam Madori",
      "Miga",
      "Ringim",
      "Roni",
      "Sule-Tankarkar",
      "Taura",
      "Yankwashi",
    ],
  },
  {
    "state": "Kebbi",
    "lgas": [
      "Aleiro",
      "Arewa-Dandi",
      "Argungu",
      "Augie",
      "Bagudo",
      "Birnin-Kebbi",
      "Bunza",
      "Dandi",
      "Fakai",
      "Gwandu",
      "Jega",
      "Kalgo",
      "Koko-Besse",
      "Maiyama",
      "Ngaski",
      "Sakaba",
      "Shanga",
      "Suru",
      "Wasagu/Danko",
      "Yauri",
      "Zuru",
    ],
  },
  {
    "state": "Kaduna",
    "lgas": [
      "Birnin Gwari",
      "Chikun",
      "Giwa",
      "Igabi",
      "Ikara",
      "Jaba",
      "Jema A",
      "Kachia",
      "Kaduna North",
      "Kaduna South",
      "Kagarko",
      "Kajuru",
      "Kaura",
      "Kauru",
      "Kubau",
      "Kudan",
      "Lere",
      "Makarfi",
      "Sabon Gari",
      "Sanga",
      "Soba",
      "Zangon Kataf",
      "Zaria",
    ],
  },
  {
    "state": "Kano",
    "lgas": [
      "Ajingi",
      "Albasu",
      "Bagwai",
      "Bebeji",
      "Bichi",
      "Bunkure",
      "Dala",
      "Dambatta",
      "Dawakin Kudu",
      "Dawakin Tofa",
      "Doguwa",
      "Fagge",
      "Gabasawa",
      "Garko",
      "Garun Mallam",
      "Gaya",
      "Gezawa",
      "Gwale",
      "Gwarzo",
      "Kabo",
      "Kano Municipal",
      "Karaye",
      "Kibiya",
      "Kiru",
      "Kumbotso",
      "Kunchi",
      "Kura",
      "Madobi",
      "Makoda",
      "Minjibir",
      "Nasarawa",
      "Rano",
      "Rimin Gado",
      "Rogo",
      "Shanono",
      "Sumaila",
      "Takai",
      "Tarauni",
      "Tofa",
      "Tsanyawa",
      "Tudun Wada",
      "Ungogo",
      "Warawa",
      "Wudil",
    ],
  },

  {
    "state": "Kogi",
    "lgas": [
      "Adavi",
      "Ajaokuta",
      "Ankpa",
      "Dekina",
      "Ibaji",
      "Idah",
      "Igalamela-Odolu",
      "Ijumu",
      "Kabba\/Bunu",
      "Kogi",
      "Lokoja",
      "Mopa-Muro",
      "Ofu",
      "Ogori\/Magongo",
      "Okehi",
      "Okene",
      "Olamaboro",
      "Omala",
      "Oyi",
      "Yagba-East",
      "Yagba-West",
    ],
  },
  {
    "state": "Katsina",
    "lgas": [
      "Bakori",
      "Batagarawa",
      "Batsari",
      "Baure",
      "Bindawa",
      "Charanchi",
      "Dan-Musa",
      "Dandume",
      "Danja",
      "Daura",
      "Dutsi",
      "Dutsin-Ma",
      "Faskari",
      "Funtua",
      "Ingawa",
      "Jibia",
      "Kafur",
      "Kaita",
      "Kankara",
      "Kankia",
      "Katsina",
      "Kurfi",
      "Kusada",
      "Mai-Adua",
      "Malumfashi",
      "Mani",
      "Mashi",
      "Matazu",
      "Musawa",
      "Rimi",
      "Sabuwa",
      "Safana",
      "Sandamu",
      "Zango",
    ],
  },
  {
    "state": "Kwara",
    "lgas": [
      "Asa",
      "Baruten",
      "Edu",
      "Ekiti (Araromi/Opin)",
      "Ilorin-East",
      "Ilorin-South",
      "Ilorin-West",
      "Isin",
      "Kaiama",
      "Moro",
      "Offa",
      "Oke-Ero",
      "Oyun",
      "Pategi",
    ],
  },
  {
    "state": "Lagos",
    "lgas": [
      "Agege",
      "Ajeromi-Ifelodun",
      "Alimosho",
      "Amuwo-Odofin",
      "Apapa",
      "Badagry",
      "Epe",
      "Eti-Osa",
      "Ibeju-Lekki",
      "Ifako-Ijaiye",
      "Ikeja",
      "Ikorodu",
      "Kosofe",
      "Lagos-Island",
      "Lagos-Mainland",
      "Mushin",
      "Ojo",
      "Oshodi-Isolo",
      "Shomolu",
      "Surulere",
      "Yewa-South",
    ],
  },
  {
    "state": "Nasarawa",
    "lgas": [
      "Akwanga",
      "Awe",
      "Doma",
      "Karu",
      "Keana",
      "Keffi",
      "Kokona",
      "Lafia",
      "Nasarawa",
      "Nasarawa-Eggon",
      "Obi",
      "Wamba",
      "Toto",
    ],
  },
  {
    "state": "Niger",
    "lgas": [
      "Agaie",
      "Agwara",
      "Bida",
      "Borgu",
      "Bosso",
      "Chanchaga",
      "Edati",
      "Gbako",
      "Gurara",
      "Katcha",
      "Kontagora",
      "Lapai",
      "Lavun",
      "Magama",
      "Mariga",
      "Mashegu",
      "Mokwa",
      "Moya",
      "Paikoro",
      "Rafi",
      "Rijau",
      "Shiroro",
      "Suleja",
      "Tafa",
      "Wushishi",
    ],
  },
  {
    "state": "Ogun",
    "lgas": [
      "Abeokuta-North",
      "Abeokuta-South",
      "Ado-Odo\/Ota",
      "Ewekoro",
      "Ifo",
      "Ijebu-East",
      "Ijebu-North",
      "Ijebu-North-East",
      "Ijebu-Ode",
      "Ikenne",
      "Imeko-Afon",
      "Ipokia",
      "Obafemi-Owode",
      "Odeda",
      "Odogbolu",
      "Ogun-Waterside",
      "Remo-North",
      "Shagamu",
      "Yewa North",
    ],
  },
  {
    "state": "Ondo",
    "lgas": [
      "Akoko North-East",
      "Akoko North-West",
      "Akoko South-West",
      "Akoko South-East",
      "Akure-North",
      "Akure-South",
      "Ese-Odo",
      "Idanre",
      "Ifedore",
      "Ilaje",
      "Ile-Oluji-Okeigbo",
      "Irele",
      "Odigbo",
      "Okitipupa",
      "Ondo West",
      "Ondo-East",
      "Ose",
      "Owo",
    ],
  },
  {
    "state": "Osun",
    "lgas": [
      "Atakumosa West",
      "Atakumosa East",
      "Ayedaade",
      "Ayedire",
      "Boluwaduro",
      "Boripe",
      "Ede South",
      "Ede North",
      "Egbedore",
      "Ejigbo",
      "Ife North",
      "Ife South",
      "Ife-Central",
      "Ife-East",
      "Ifelodun",
      "Ila",
      "Ilesa-East",
      "Ilesa-West",
      "Irepodun",
      "Irewole",
      "Isokan",
      "Iwo",
      "Obokun",
      "Odo-Otin",
      "Ola Oluwa",
      "Olorunda",
      "Oriade",
      "Orolu",
      "Osogbo",
    ],
  },
  {
    "state": "Oyo",
    "lgas": [
      "Afijio",
      "Akinyele",
      "Atiba",
      "Atisbo",
      "Egbeda",
      "Ibadan North",
      "Ibadan North-East",
      "Ibadan North-West",
      "Ibadan South-East",
      "Ibadan South-West",
      "Ibarapa-Central",
      "Ibarapa-East",
      "Ibarapa-North",
      "Ido",
      "Ifedayo",
      "Irepo",
      "Iseyin",
      "Itesiwaju",
      "Iwajowa",
      "Kajola",
      "Lagelu",
      "Ogo-Oluwa",
      "Ogbomosho-North",
      "Ogbomosho-South",
      "Olorunsogo",
      "Oluyole",
      "Ona-Ara",
      "Orelope",
      "Ori-Ire",
      "Oyo-West",
      "Oyo-East",
      "Saki-East",
      "Saki-West",
      "Surulere",
    ],
  },
  {
    "state": "Plateau",
    "lgas": [
      "Barkin-Ladi",
      "Bassa",
      "Bokkos",
      "Jos-East",
      "Jos-North",
      "Jos-South",
      "Kanam",
      "Kanke",
      "Langtang-North",
      "Langtang-South",
      "Mangu",
      "Mikang",
      "Pankshin",
      "Qua'an Pan",
      "Riyom",
      "Shendam",
      "Wase",
    ],
  },
  {
    "state": "Rivers",
    "lgas": [
      "Abua\/Odual",
      "Ahoada-East",
      "Ahoada-West",
      "Akuku Toru",
      "Andoni",
      "Asari-Toru",
      "Bonny",
      "Degema",
      "Eleme",
      "Emuoha",
      "Etche",
      "Gokana",
      "Ikwerre",
      "Khana",
      "Obio\/Akpor",
      "Ogba-Egbema-Ndoni",
      "Ogba\/Egbema\/Ndoni",
      "Ogu\/Bolo",
      "Okrika",
      "Omuma",
      "Opobo\/Nkoro",
      "Oyigbo",
      "Port-Harcourt",
      "Tai",
    ],
  },
  {
    "state": "Sokoto",
    "lgas": [
      "Binji",
      "Bodinga",
      "Dange-Shuni",
      "Gada",
      "Goronyo",
      "Gudu",
      "Gwadabawa",
      "Illela",
      "Kebbe",
      "Kware",
      "Rabah",
      "Sabon Birni",
      "Shagari",
      "Silame",
      "Sokoto-North",
      "Sokoto-South",
      "Tambuwal",
      "Tangaza",
      "Tureta",
      "Wamako",
      "Wurno",
      "Yabo",
    ],
  },
  {
    "state": "Taraba",
    "lgas": [
      "Ardo-Kola",
      "Bali",
      "Donga",
      "Gashaka",
      "Gassol",
      "Ibi",
      "Jalingo",
      "Karim-Lamido",
      "Kurmi",
      "Lau",
      "Sardauna",
      "Takum",
      "Ussa",
      "Wukari",
      "Yorro",
      "Zing",
    ],
  },
  {
    "state": "Yobe",
    "lgas": [
      "Bade",
      "Bursari",
      "Damaturu",
      "Fika",
      "Fune",
      "Geidam",
      "Gujba",
      "Gulani",
      "Jakusko",
      "Karasuwa",
      "Machina",
      "Nangere",
      "Nguru",
      "Potiskum",
      "Tarmuwa",
      "Yunusari",
      "Yusufari",
    ],
  },
  {
    "state": "Zamfara",
    "lgas": [
      "Anka",
      "Bakura",
      "Birnin Magaji/Kiyaw",
      "Bukkuyum",
      "Bungudu",
      "Gummi",
      "Gusau",
      "Isa",
      "Kaura-Namoda",
      "Kiyawa",
      "Maradun",
      "Maru",
      "Shinkafi",
      "Talata-Mafara",
      "Tsafe",
      "Zurmi",
    ],
  },
];