import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/global/services/barrel.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/others.dart';
import 'package:transborder_logistics/src/src_barrel.dart';

import '../../../global/model/barrel.dart';

class DeliveryInfo extends StatelessWidget {
  const DeliveryInfo(this.delivery, {super.key});
  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      border: Border.all(color: AppColors.borderColor),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Ui.padding(
            padding: 12,
            child: Row(
              children: [
                AppText.medium("#${delivery.waybill}", fontSize: 14),
                const Spacer(),
                if (!delivery.hasStarted) WaybillStatusChip("New"),
                if (delivery.isDelivered) WaybillStatusChip("Finished"),
                if (delivery.hasStarted && !delivery.isDelivered)
                  GestureDetector(
                    onTap: () {
                      //todo
                    },
                    child: WaybillStatusChip("Track"),
                  ),
                if (delivery.hasStarted && !delivery.isDelivered)
                  WaybillStatusChip("Ongoing"),
              ],
            ),
          ),
          AppDivider(),

          Ui.padding(
            padding: 12,
            child: Row(
              children: [
                Expanded(
                  child: InfoValue(
                    "Pick up location",
                    delivery.pickup ?? "N/A",
                  ),
                ),
                Ui.boxWidth(24),
                Expanded(
                  child: InfoValue("Delivery Location", delivery.stops[0]),
                ),
              ],
            ),
          ),

          Ui.padding(
            padding: 12,
            child: Row(
              children: [
                Expanded(child: InfoValue("Vehicle Reg No", delivery.truckno)),
                Ui.boxWidth(24),
                Expanded(child: InfoValue("Driver", delivery.driver)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WaybillStatusChip extends StatelessWidget {
  const WaybillStatusChip(this.title, {super.key});
  final String title;

  static List<String> status = [
    "New",
    "Track",
    "Ongoing",
    "Finished",
    "Canceled",
  ];
  static List<dynamic> statusIcon = [
    HugeIcons.strokeRoundedAlertCircle,
    HugeIcons.strokeRoundedRoute03,
    HugeIcons.strokeRoundedArrowLeftRight,
    HugeIcons.strokeRoundedCheckmarkCircle02,
    HugeIcons.strokeRoundedCancelCircle,
  ];
  static List<Color> statusTitleColor = [
    Color(0xFFFFB400),
    Color(0xFF229EFF),
    Color(0xFF229EFF),
    Color(0xFF00D743),
    Color(0xFFFF3B30),
  ];
  static List<Color> statusTitleBg = [
    Color(0xFFFFF8E6),
    Color(0xFFE9F5FF),
    Color(0xFFE9F5FF),
    Color(0xFFE6FBEC),
    Color(0xFFFFEBEA),
  ];

  @override
  Widget build(BuildContext context) {
    final i = status.indexOf(title);
    return CurvedContainer(
      color: statusTitleBg[i],
      radius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon[i], size: 16, color: statusTitleColor[i]),
          Ui.boxWidth(4),
          AppText.medium(title, fontSize: 12, color: statusTitleColor[i]),
        ],
      ),
    );
  }
}

class WaybillDetailPage extends StatelessWidget {
  const WaybillDetailPage(this.delivery, {super.key});
  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    final appService = Get.find<AppService>();
    return SinglePageScaffold(
      title: "#${delivery.waybill}",

      child: SingleChildScrollView(
        child: Column(
          children: [
            CurvedContainer(
              border: Border.all(color: AppColors.borderColor),
              child: Column(
                children: [
                  Ui.padding(
                    padding: 12,
                    child: Row(
                      children: [
                        AppIcon(
                          HugeIcons.strokeRoundedBus03,
                          color: AppColors.lightTextColor,
                        ),
                        Ui.boxWidth(16),
                        AppText.medium("Waybill", fontSize: 14),
                        const Spacer(),
                        if (!delivery.hasStarted) WaybillStatusChip("New"),
                        if (delivery.isDelivered) WaybillStatusChip("Finished"),
                        if (delivery.hasStarted && !delivery.isDelivered)
                          GestureDetector(
                            onTap: () {
                              //todo
                            },
                            child: WaybillStatusChip("Track"),
                          ),
                        if (delivery.hasStarted && !delivery.isDelivered)
                          WaybillStatusChip("Ongoing"),
                      ],
                    ),
                  ),
                  Ui.align(
                    align: Alignment.centerRight,
                    child: SizedBox(
                      width: Ui.width(context) - 56,
                      child: AppDivider(),
                    ),
                  ),

                  Ui.padding(
                    padding: 12,
                    child: Row(
                      children: [
                        Expanded(
                          child: InfoValue("Trip", delivery.id.toString()),
                        ),
                        Ui.boxWidth(24),
                        Expanded(
                          child: InfoValue("Vehicle Reg No", delivery.truckno),
                        ),
                      ],
                    ),
                  ),

                  Ui.padding(
                    padding: 12,
                    child: Row(
                      children: [
                        Expanded(
                          child: InfoValue("Trip", delivery.id.toString()),
                        ),
                        Ui.boxWidth(24),
                        Expanded(
                          child: InfoValue("Vehicle Reg No", delivery.truckno),
                        ),
                      ],
                    ),
                  ),

                  Ui.padding(
                    padding: 12,
                    child: Row(
                      children: [
                        Expanded(child: InfoValue("Driver", delivery.driver)),
                        Ui.boxWidth(24),
                        CurvedImage("", w: 24, h: 24),
                      ],
                    ),
                  ),

                  Ui.padding(
                    padding: 12,
                    child: Row(
                      children: [
                        Expanded(
                          child: InfoValue("Pick up Location", delivery.pickup),
                        ),
                        Ui.boxWidth(24),
                        AppIcon(
                          HugeIcons.strokeRoundedLocation05,
                          color: delivery.hasStarted
                              ? Color(0xFF229EFF)
                              : AppColors.lightTextColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Ui.boxHeight(16),
            //items
            Ui.boxHeight(16),
            if (appService.currentUser.value.role == "admin")
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleIcon(HugeIcons.strokeRoundedDownload01),
                  Ui.boxWidth(16),
                  CircleIcon(HugeIcons.strokeRoundedShare08),
                  Ui.boxWidth(16),
                  CircleIcon(HugeIcons.strokeRoundedPrinter),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class CircleIcon extends StatelessWidget {
  const CircleIcon(this.icon, {this.onTap, super.key});
  final dynamic icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primaryColor,
        child: Center(child: AppIcon(icon, color: AppColors.white)),
      ),
    );
  }
}

class InfoValue extends StatelessWidget {
  const InfoValue(this.label, this.value, {super.key});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,

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
