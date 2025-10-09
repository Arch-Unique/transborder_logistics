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

class AppContainer extends StatelessWidget {
  const AppContainer(this.title, this.actions, {super.key});
  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final div = Ui.align(
      align: Alignment.centerRight,
      child: SizedBox(width: Ui.width(context) - 56, child: AppDivider()),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
          border: Border.all(color: AppColors.borderColor),
          margin: EdgeInsets.symmetric(horizontal: 16),
          radius: 12,
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (c, i) {
              return actions[i];
            },
            separatorBuilder: (c, i) {
              return div;
            },
            itemCount: actions.length,
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
    super.key,
  });
  final dynamic icon;
  final Widget title;
  final Widget desc;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcon(icon),
        Ui.boxWidth(12),
        title,
        Ui.boxWidth(12),
        Expanded(child: desc),
      ],
    );
  }

  static AppContainerItem text(dynamic icon, String title, String desc) {
    return AppContainerItem(
      icon,
      title: AppText.medium(title, fontSize: 14),
      desc: AppText.thin(desc, fontSize: 12, color: AppColors.lightTextColor),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appService = Get.find<AppService>();
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          UserProfilePic(),
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
            if (appService.currentUser.value.role == "driver")
              AppContainerItem.text(
                HugeIcons.strokeRoundedRegister,
                "Truck Reg No",
                appService.currentUser.value.truckno ?? "N/A",
              ),
            // AppContainerItem.text(HugeIcons.strokeRoundedMail01, "Email", appService.currentUser.value.email ?? "N/A"),
          ]),
          Ui.boxHeight(24),
          AppContainer("ABOUT", [
            AppContainerItem.icon(
              HugeIcons.strokeRoundedHelpCircle,
              "Full Name",
              appService.currentUser.value.name ?? "N/A",
            ),
            AppContainerItem.icon(
              HugeIcons.left,
              "Email",
              appService.currentUser.value.email ?? "N/A",
            ),
            AppContainerItem.icon(
              HugeIcons.strokeRoundedMail01,
              "Account Type",
              appService.currentUser.value.role.capitalize ?? "",
            ),
            AppContainerItem.text(
              HugeIcons.strokeRoundedMail01,
              "Contact",
              appService.currentUser.value.phone ?? "N/A",
            ),
            if (appService.currentUser.value.role == "driver")
              AppContainerItem.text(
                HugeIcons.strokeRoundedMail01,
                "Truck Reg No",
                appService.currentUser.value.truckno ?? "N/A",
              ),
            // AppContainerItem.text(HugeIcons.strokeRoundedMail01, "Email", appService.currentUser.value.email ?? "N/A"),
          ]),
        ],
      ),
    );
  }
}
