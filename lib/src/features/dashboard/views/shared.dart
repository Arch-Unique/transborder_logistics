import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/global/services/barrel.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';
import 'package:transborder_logistics/src/global/ui/widgets/fields/custom_dropdown.dart';
import 'package:transborder_logistics/src/global/ui/widgets/fields/custom_textfield.dart';
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
      onPressed: () {
        Get.to(WaybillDetailPage(delivery));
      },
      radius: 12,
      child: Column(
        children: [
          Ui.padding(
            padding: 12,
            child: Row(
              children: [
                AppText.medium("#${delivery.waybill}", fontSize: 14),
                Spacer(),
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
                  Ui.boxWidth(8),
                if (delivery.hasStarted && !delivery.isDelivered)
                  WaybillStatusChip("Ongoing"),
              ],
            ),
          ),
          AppDivider(),

          Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 0, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: InfoValue(
                    "Pick up location",
                    delivery.pickup ?? "N/A",
                    isStart: true,
                  ),
                ),
                Ui.boxWidth(24),
                Expanded(
                  child: InfoValue("Delivery Location", delivery.stops[0]),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: InfoValue(
                    "Vehicle Reg No",
                    delivery.truckno,
                    isStart: true,
                  ),
                ),
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

class DriverInfo extends StatelessWidget {
  const DriverInfo(this.user, {super.key});
  final User user;

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      border: Border.all(color: AppColors.borderColor),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      onPressed: () {
        Get.bottomSheet(AddResource<User>("Users", obj: user));
        // Get.to(WaybillDetailPage(delivery));
      },
      radius: 12,
      child: Row(
        children: [
          CurvedImage("", w: 48, h: 48),
          Ui.boxWidth(12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.medium(user.name ?? "N/A", fontSize: 12),
                AppText.thin(
                  user.role.capitalize ?? "",
                  fontSize: 10,
                  color: AppColors.lightTextColor,
                ),
                AppText.medium(
                  user.truckno ?? "N/A",
                  fontSize: 10,
                  color: AppColors.lightTextColor,
                ),
              ],
            ),
          ),
          Ui.boxWidth(24),
          DriverStatusChip("Available"),
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
    return CurvedContainer(
      border: Border.all(color: AppColors.borderColor),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      onPressed: () {
        Get.bottomSheet(AddResource<Location>("Facilities", obj: user));
        // Get.to(WaybillDetailPage(delivery));
      },
      radius: 12,
      child: Row(
        children: [
          CurvedImage("", w: 48, h: 48),
          Ui.boxWidth(12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.medium(user.name ?? "N/A", fontSize: 12),
                AppText.thin(
                  user.facilityType ?? "",
                  fontSize: 10,
                  color: AppColors.lightTextColor,
                ),
                AppText.medium(
                  "${user.lga}, ${user.state}",
                  fontSize: 10,
                  color: AppColors.lightTextColor,
                ),
              ],
            ),
          ),
          Ui.boxWidth(24),
          DriverStatusChip("Available"),
        ],
      ),
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
        // Get.to(WaybillDetailPage(delivery));
      },
      radius: 12,
      child: Row(
        children: [
          AppIcon(HugeIcons.strokeRoundedLocation05),
          Ui.boxWidth(12),
          Expanded(child: AppText.medium(sloc.name ?? "N/A", fontSize: 12)),
          Ui.boxWidth(24),
          DriverStatusChip(sloc.isActive! ? "Available" : "Inactive"),
        ],
      ),
    );
  }
}

class DriverStatusChip extends StatelessWidget {
  const DriverStatusChip(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppChip(
      title,
      bgColors: [Color(0xFFE6FBEC), Color(0xFFFFEBEA), Color(0xFFE9F5FF)],
      titles: ["Available", "Inactive", "Busy"],
      titleColors: [Color(0xFF00D743), Color(0xFFFF3B30), Color(0xFF229EFF)],
      icons: [
        HugeIcons.strokeRoundedCheckmarkCircle02,
        HugeIcons.strokeRoundedCancelCircle,
        HugeIcons.strokeRoundedArrowLeftRight,
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
    this.titles = const ["New", "Track", "Ongoing", "Finished", "Canceled"],
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icons[i], size: 16, color: titleColors[i]),
          Ui.boxWidth(4),
          AppText.medium(title, fontSize: 12, color: titleColors[i]),
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
              radius: 12,
              margin: EdgeInsets.all(16),
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
                          Ui.boxWidth(8),
                        if (delivery.hasStarted && !delivery.isDelivered)
                          WaybillStatusChip("Ongoing"),
                      ],
                    ),
                  ),
                  Ui.align(
                    align: Alignment.centerRight,
                    child: SizedBox(
                      width: Ui.width(context) - 88,
                      child: AppDivider(),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      vertical: 0,
                      horizontal: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InfoValue(
                            "Request Date",
                            delivery.start,
                            isStart: true,
                          ),
                        ),
                        Ui.boxWidth(24),
                        Expanded(
                          child: InfoValue("Request By", delivery.owner),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InfoValue(
                            "Trip",
                            delivery.id.toString(),
                            isStart: true,
                          ),
                        ),
                        Ui.boxWidth(24),
                        Expanded(
                          child: InfoValue("Vehicle Reg No", delivery.truckno),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      vertical: 0,
                      horizontal: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InfoValue(
                            "Driver",
                            delivery.driver,
                            isStart: true,
                          ),
                        ),
                        Ui.boxWidth(24),
                        CurvedImage("", w: 24, h: 24),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InfoValue(
                            "Pick up Location",
                            delivery.pickup,
                            isStart: true,
                          ),
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

                  Padding(
                    padding: EdgeInsetsGeometry.only(
                      top: 0,
                      bottom: 12,
                      left: 12,
                      right: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InfoValue(
                            "Delivery Location",
                            delivery.stops[0],
                            isStart: true,
                          ),
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
            //items
            if (delivery.items.isNotEmpty)
              Padding(
                padding: EdgeInsetsGeometry.only(
                  top: 0,
                  bottom: 12,
                  left: 16,
                  right: 16,
                ),
                child: AppContainer("ITEMS", [
                  ...delivery.items.map(
                    (e) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText.medium(e[0], fontSize: 12),
                        AppText.thin(
                          e[1],
                          fontSize: 10,
                          color: AppColors.lightTextColor,
                        ),
                      ],
                    ),
                  ),
                ]),
              ),

            if (delivery.items.isNotEmpty)
              Padding(
                padding: EdgeInsetsGeometry.only(
                  top: 0,
                  bottom: 12,
                  left: 16,
                  right: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.thin(
                      "TOTAL AMOUNT",
                      fontSize: 10,
                      color: AppColors.lightTextColor,
                    ),
                    AppText.medium(delivery.amt.toCurrency(), fontSize: 10),
                  ],
                ),
              ),
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

            if (appService.currentUser.value.role == "driver" &&
                !delivery.isDelivered)
              SizedBox(
                width: Ui.width(context) / 3,
                child: AppButton(
                  onPressed: () {
                    if (!delivery.hasStarted) {
                      Get.bottomSheet(
                        AppBottomSheet(
                          "Confirm Start",
                          "Confirm",
                          msg: "Are you sure you want to start the trip",
                        ),
                      );
                    } else {
                      Get.bottomSheet(
                        AppBottomSheet(
                          "Confirm Delivery",
                          "Confirm",
                          onTap: () {
                            Ui.showError("Hello World");
                          },
                          actions: [
                            CustomTextField(
                              "Add Name",
                              TextEditingController(),
                              label: "Name of receiver",
                            ),
                            CustomTextField(
                              "Add Contact",
                              TextEditingController(),
                              label: "Contact",
                            ),

                            FieldValue(
                              "Proof Image",
                              child: InkWell(
                                child: AppText.thin(
                                  "Select image >",
                                  color: AppColors.lightTextColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  text: !delivery.hasStarted ? "Start Trip" : "End Trip",
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CircleIcon extends StatelessWidget {
  const CircleIcon(
    this.icon, {
    this.onTap,
    this.radius = 20,
    this.size = 24,
    this.bg = AppColors.primaryColor,
    this.ic = AppColors.white,
    super.key,
  });
  final dynamic icon;
  final VoidCallback? onTap;
  final double? radius;
  final double? size;
  final Color? bg, ic;

  @override
  Widget build(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    final div = Ui.align(
      align: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsetsGeometry.only(left: margin),
        child: AppDivider(),
      ),
    );
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (c, i) {
              return Padding(
                padding: EdgeInsets.only(
                  top: i == 0 ? 12 : 8.0,
                  bottom: i == actions.length - 1 ? 8 : 4,
                  left: 8,
                  right: 16,
                ),
                child: actions[i],
              );
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
                    onTap: () async {},
                    actions: [
                      CustomTextField(
                        "****",
                        TextEditingController(),
                        varl: FPL.password,
                        label: "New PIN",
                      ),
                      CustomTextField(
                        "****",
                        TextEditingController(),
                        varl: FPL.password,
                        label: "Confirm PIN",
                      ),
                    ],
                  ),
                );
              },
            ),
          ]),
          Ui.boxHeight(24),
          AppContainer("ABOUT", [
            AppContainerItem.icony(
              HugeIcons.strokeRoundedHelpCircle,
              "Help Center",
            ),
            AppContainerItem.icony(
              HugeIcons.strokeRoundedLeftToRightListBullet,
              "Terms Of Use",
            ),
            AppContainerItem.icony(
              HugeIcons.strokeRoundedMail01,
              "Privacy Policy",
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
    return CurvedContainer(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
        children: [AppText.medium(title, fontSize: 14), child],
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
    final List<TextEditingController> tecs = List.generate(
      10,
      (i) => TextEditingController(),
    );
    if (obj != null) {
      if (title.toLowerCase() == "users") {
        final user = obj as User;
        tecs[0].text = user.name ?? "";
        tecs[1].text = user.email ?? "";
        tecs[2].text = user.phone ?? "";
        tecs[3].text = user.role;
        tecs[4].text = user.location ?? "Kano";
      }

      if (title.toLowerCase() == "facilities" ||
          title.toLowerCase() == "loading points") {
        final user = obj as Location;
        tecs[0].text = user.name ?? "";
        tecs[1].text = user.lga ?? "";
        tecs[2].text = user.facilityType ?? "";
        tecs[3].text = user.state ?? "Kano";
      }
    }
    final controller = Get.find<DashboardController>();

    return AppBottomSheet(
      obj == null ? "Add $title" : "Edit $title",
      obj == null ? "Add" : "Edit",
      onTap: () {},
      actions: [
        //TRIP
        if (title.toLowerCase() == "trips")
          CustomDropdown.city(
            cities: controller.allLoadingPoints.map((e) => e.slug).toList(),
            hint: "Add Loading Point",
            label: "Loading Point",
            selectedValue: tecs[1].text,
            onChanged: (v) {
              tecs[0].text = v ?? "";
            },
          ),
        if (title.toLowerCase() == "trips")
          CustomDropdown.city(
            cities: controller.allFacilities.map((e) => e.slug).toList(),
            hint: "Add Facility",
            label: "Facility",
            selectedValue: tecs[2].text,
            onChanged: (v) {
              tecs[1].text = v ?? "";
            },
          ),
        if (title.toLowerCase() == "trips")
          CustomDropdown.city(
            cities: controller.allDrivers.map((e) => e.name ?? "").toList(),
            hint: "Add Driver",
            label: "Driver",
            selectedValue: tecs[2].text,
            onChanged: (v) {
              tecs[2].text = v ?? "";
            },
          ),
        // if (title.toLowerCase() == "trips")
        // CustomDropdown.city(
        //   cities: controller.allDrivers.map((e) => e.name ?? "").toList(),
        //   hint: "Add Vehicle",
        //   label: "Vehicle",
        //   selectedValue: tecs[4].text,
        //   onChanged: (v) {
        //     tecs[3].text = v ?? "";
        //   },
        // ),

        //USER
        if (title.toLowerCase() == "users")
          CustomTextField("Add user", tecs[0], label: "Name"),
        if (title.toLowerCase() == "users")
          CustomTextField("Add email", tecs[1], label: "Email"),
        if (title.toLowerCase() == "users")
          CustomTextField("Add phone", tecs[2], label: "Phone"),
        if (title.toLowerCase() == "users")
          CustomDropdown.city(
            cities: ["driver", "admin", "operator"],
            hint: "Add account type",
            label: "Account type",
            selectedValue: tecs[3].text,
            onChanged: (v) {
              tecs[3].text = v ?? "";
            },
          ),
        if (title.toLowerCase() == "users")
          CustomDropdown.city(
            cities: ["Kano", "Kaduna"],
            hint: "Add location",
            label: "Location",
            selectedValue: tecs[4].text,
            onChanged: (v) {
              tecs[4].text = v ?? "";
            },
          ),

        //DRIVER
        if (title.toLowerCase() == "drivers")
          CustomTextField("Add name", tecs[0], label: "Name"),
        if (title.toLowerCase() == "drivers")
          CustomTextField("Add email", tecs[1], label: "Email"),
        if (title.toLowerCase() == "drivers")
          CustomTextField("Add phone", tecs[2], label: "Phone"),
        if (title.toLowerCase() == "drivers")
          CustomDropdown.city(
            cities: ["Kano", "Kaduna"],
            hint: "Add location",
            label: "Location",
            selectedValue: tecs[3].text,
            onChanged: (v) {
              tecs[3].text = v ?? "";
            },
          ),

        //Location
        if (title.toLowerCase() == "facilities" ||
            title.toLowerCase() == "loading points")
          CustomTextField("Add name", tecs[0], label: "Name"),
        if (title.toLowerCase() == "facilities" ||
            title.toLowerCase() == "loading points")
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
            title.toLowerCase() == "loading points")
          CustomDropdown.city(
            cities: ["Kano", "Kaduna"],
            hint: "Add State",
            label: "State",
            selectedValue: tecs[3].text,
            onChanged: (v) {
              tecs[3].text = v ?? "";
            },
          ),
        if (title.toLowerCase() == "facilities" ||
            title.toLowerCase() == "loading points")
          CustomDropdown.city(
            cities: lgas
                .where((e) => e["state"] == (tecs[3].text.isEmpty ? "Kano": tecs[3].text))
                .map((e) => e["name"] as String)
                .toList(),
            hint: "",
            label: "LGA",
            selectedValue: tecs[1].text,
            onChanged: (v) {
              tecs[1].text = v ?? "";
            },
          ),

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
      ],
    );
  }
}


const lgas = [
    // {
    //     "state": "Abia",
    //     "lgas": [
    //         "Aba North",
    //         "Aba South",
    //         "Arochukwu",
    //         "Bende",
    //         "Ikawuno",
    //         "Ikwuano",
    //         "Isiala-Ngwa North",
    //         "Isiala-Ngwa South",
    //         "Isuikwuato",
    //         "Umu Nneochi",
    //         "Obi Ngwa",
    //         "Obioma Ngwa",
    //         "Ohafia",
    //         "Ohaozara",
    //         "Osisioma",
    //         "Ugwunagbo",
    //         "Ukwa West",
    //         "Ukwa East",
    //         "Umuahia North",
    //         "Umuahia South"
    //     ]
    // },
    // {
    //     "state": "Adamawa",
    //     "lgas": [
    //         "Demsa",
    //         "Fufore",
    //         "Ganye",
    //         "Girei",
    //         "Gombi",
    //         "Guyuk",
    //         "Hong",
    //         "Jada",
    //         "Lamurde",
    //         "Madagali",
    //         "Maiha",
    //         "Mayo-Belwa",
    //         "Michika",
    //         "Mubi-North",
    //         "Mubi-South",
    //         "Numan",
    //         "Shelleng",
    //         "Song",
    //         "Toungo",
    //         "Yola North",
    //         "Yola South"
    //     ]
    // },
    // {
    //     "state": "Akwa Ibom",
    //     "lgas": [
    //         "Abak",
    //         "Eastern-Obolo",
    //         "Eket",
    //         "Esit-Eket",
    //         "Essien-Udim",
    //         "Etim-Ekpo",
    //         "Etinan",
    //         "Ibeno",
    //         "Ibesikpo-Asutan",
    //         "Ibiono-Ibom",
    //         "Ika",
    //         "Ikono",
    //         "Ikot-Abasi",
    //         "Ikot-Ekpene",
    //         "Ini",
    //         "Itu",
    //         "Mbo",
    //         "Mkpat-Enin",
    //         "Nsit-Atai",
    //         "Nsit-Ibom",
    //         "Nsit-Ubium",
    //         "Obot-Akara",
    //         "Okobo",
    //         "Onna",
    //         "Oron",
    //         "Oruk Anam",
    //         "Udung-Uko",
    //         "Ukanafun",
    //         "Urue-Offong/Oruko",
    //         "Uruan",
    //         "Uyo"
    //     ]
    // },
    // {
    //     "state": "Anambra",
    //     "lgas": [
    //         "Aguata",
    //         "Anambra East",
    //         "Anambra West",
    //         "Anaocha",
    //         "Awka North",
    //         "Awka South",
    //         "Ayamelum",
    //         "Dunukofia",
    //         "Ekwusigo",
    //         "Idemili-North",
    //         "Idemili-South",
    //         "Ihiala",
    //         "Njikoka",
    //         "Nnewi-North",
    //         "Nnewi-South",
    //         "Ogbaru",
    //         "Onitsha-North",
    //         "Onitsha-South",
    //         "Orumba-North",
    //         "Orumba-South"
    //     ]
    // },
    // {
    //     "state": "Bauchi",
    //     "lgas": [
    //         "Alkaleri",
    //         "Bauchi",
    //         "Bogoro",
    //         "Damban",
    //         "Darazo",
    //         "Dass",
    //         "Gamawa",
    //         "Ganjuwa",
    //         "Giade",
    //         "Itas\/Gadau",
    //         "Jama'Are",
    //         "Katagum",
    //         "Kirfi",
    //         "Misau",
    //         "Ningi",
    //         "Shira",
    //         "Tafawa-Balewa",
    //         "Toro",
    //         "Warji",
    //         "Zaki"
    //     ]
    // },
    // {
    //     "state": "Benue",
    //     "lgas": [
    //         "Ado",
    //         "Agatu",
    //         "Apa",
    //         "Buruku",
    //         "Gboko",
    //         "Guma",
    //         "Gwer-East",
    //         "Gwer-West",
    //         "Katsina-Ala",
    //         "Konshisha",
    //         "Kwande",
    //         "Logo",
    //         "Makurdi",
    //         "Ogbadibo",
    //         "Ohimini",
    //         "Oju",
    //         "Okpokwu",
    //         "Otukpo",
    //         "Tarka",
    //         "Ukum",
    //         "Ushongo",
    //         "Vandeikya"
    //     ]
    // },
    // {
    //     "state": "Borno",
    //     "lgas": [
    //         "Abadam",
    //         "Askira-Uba",
    //         "Bama",
    //         "Bayo",
    //         "Biu",
    //         "Chibok",
    //         "Damboa",
    //         "Dikwa",
    //         "Gubio",
    //         "Guzamala",
    //         "Gwoza",
    //         "Hawul",
    //         "Jere",
    //         "Kaga",
    //         "Kala\/Balge",
    //         "Konduga",
    //         "Kukawa",
    //         "Kwaya-Kusar",
    //         "Mafa",
    //         "Magumeri",
    //         "Maiduguri",
    //         "Marte",
    //         "Mobbar",
    //         "Monguno",
    //         "Ngala",
    //         "Nganzai",
    //         "Shani"
    //     ]
    // },
    // {
    //     "state": "Bayelsa",
    //     "lgas": [
    //         "Brass",
    //         "Ekeremor",
    //         "Kolokuma\/Opokuma",
    //         "Nembe",
    //         "Ogbia",
    //         "Sagbama",
    //         "Southern-Ijaw",
    //         "Yenagoa"
    //     ]
    // },
    // {
    //     "state": "Cross River",
    //     "lgas": [
    //         "Abi",
    //         "Akamkpa",
    //         "Akpabuyo",
    //         "Bakassi",
    //         "Bekwarra",
    //         "Biase",
    //         "Boki",
    //         "Calabar-Municipal",
    //         "Calabar-South",
    //         "Etung",
    //         "Ikom",
    //         "Obanliku",
    //         "Obubra",
    //         "Obudu",
    //         "Odukpani",
    //         "Ogoja",
    //         "Yakurr",
    //         "Yala"
    //     ]
    // },
    // {
    //     "state": "Delta",
    //     "lgas": [
    //         "Aniocha North",
    //         "Aniocha-North",
    //         "Aniocha-South",
    //         "Bomadi",
    //         "Burutu",
    //         "Ethiope-East",
    //         "Ethiope-West",
    //         "Ika-North-East",
    //         "Ika-South",
    //         "Isoko-North",
    //         "Isoko-South",
    //         "Ndokwa-East",
    //         "Ndokwa-West",
    //         "Okpe",
    //         "Oshimili-North",
    //         "Oshimili-South",
    //         "Patani",
    //         "Sapele",
    //         "Udu",
    //         "Ughelli-North",
    //         "Ughelli-South",
    //         "Ukwuani",
    //         "Uvwie",
    //         "Warri South-West",
    //         "Warri North",
    //         "Warri South"
    //     ]
    // },
    // {
    //     "state": "Ebonyi",
    //     "lgas": [
    //         "Abakaliki",
    //         "Afikpo-North",
    //         "Afikpo South (Edda)",
    //         "Ebonyi",
    //         "Ezza-North",
    //         "Ezza-South",
    //         "Ikwo",
    //         "Ishielu",
    //         "Ivo",
    //         "Izzi",
    //         "Ohaukwu",
    //         "Onicha"
    //     ]
    // },
    // {
    //     "state": "Edo",
    //     "lgas": [
    //         "Akoko Edo",
    //         "Egor",
    //         "Esan-Central",
    //         "Esan-North-East",
    //         "Esan-South-East",
    //         "Esan-West",
    //         "Etsako-Central",
    //         "Etsako-East",
    //         "Etsako-West",
    //         "Igueben",
    //         "Ikpoba-Okha",
    //         "Oredo",
    //         "Orhionmwon",
    //         "Ovia-North-East",
    //         "Ovia-South-West",
    //         "Owan East",
    //         "Owan-West",
    //         "Uhunmwonde"
    //     ]
    // },
    // {
    //     "state": "Ekiti",
    //     "lgas": [
    //         "Ado-Ekiti",
    //         "Efon",
    //         "Ekiti-East",
    //         "Ekiti-South-West",
    //         "Ekiti-West",
    //         "Emure",
    //         "Gbonyin",
    //         "Ido-Osi",
    //         "Ijero",
    //         "Ikere",
    //         "Ikole",
    //         "Ilejemeje",
    //         "Irepodun\/Ifelodun",
    //         "Ise-Orun",
    //         "Moba",
    //         "Oye"
    //     ]
    // },
    // {
    //     "state": "Enugu",
    //     "lgas": [
    //         "Aninri",
    //         "Awgu",
    //         "Enugu-East",
    //         "Enugu-North",
    //         "Enugu-South",
    //         "Ezeagu",
    //         "Igbo-Etiti",
    //         "Igbo-Eze-North",
    //         "Igbo-Eze-South",
    //         "Isi-Uzo",
    //         "Nkanu-East",
    //         "Nkanu-West",
    //         "Nsukka",
    //         "Oji-River",
    //         "Udenu",
    //         "Udi",
    //         "Uzo-Uwani"
    //     ]
    // },
    // {
    //     "state": "Federal Capital Territory",
    //     "lgas": [
    //         "Abuja",
    //         "Kwali",
    //         "Kuje",
    //         "Gwagwalada",
    //         "Bwari",
    //         "Abaji"
    //     ]
    // },
    // {
    //     "state": "Gombe",
    //     "lgas": [
    //         "Akko",
    //         "Balanga",
    //         "Billiri",
    //         "Dukku",
    //         "Funakaye",
    //         "Gombe",
    //         "Kaltungo",
    //         "Kwami",
    //         "Nafada",
    //         "Shongom",
    //         "Yamaltu\/Deba"
    //     ]
    // },
    // {
    //     "state": "Imo",
    //     "lgas": [
    //         "Aboh-Mbaise",
    //         "Ahiazu-Mbaise",
    //         "Ehime-Mbano",
    //         "Ezinihitte",
    //         "Ideato-North",
    //         "Ideato-South",
    //         "Ihitte\/Uboma",
    //         "Ikeduru",
    //         "Isiala-Mbano",
    //         "Isu",
    //         "Mbaitoli",
    //         "Ngor-Okpala",
    //         "Njaba",
    //         "Nkwerre",
    //         "Nwangele",
    //         "Obowo",
    //         "Oguta",
    //         "Ohaji-Egbema",
    //         "Okigwe",
    //         "Onuimo",
    //         "Orlu",
    //         "Orsu",
    //         "Oru-East",
    //         "Oru-West",
    //         "Owerri-Municipal",
    //         "Owerri-North",
    //         "Owerri-West"
    //     ]
    // },
    // {
    //     "state": "Jigawa",
    //     "lgas": [
    //         "Auyo",
    //         "Babura",
    //         "Biriniwa",
    //         "Birnin-Kudu",
    //         "Buji",
    //         "Dutse",
    //         "Gagarawa",
    //         "Garki",
    //         "Gumel",
    //         "Guri",
    //         "Gwaram",
    //         "Gwiwa",
    //         "Hadejia",
    //         "Jahun",
    //         "Kafin-Hausa",
    //         "Kaugama",
    //         "Kazaure",
    //         "Kiri kasama",
    //         "Maigatari",
    //         "Malam Madori",
    //         "Miga",
    //         "Ringim",
    //         "Roni",
    //         "Sule-Tankarkar",
    //         "Taura",
    //         "Yankwashi"
    //     ]
    // },
    // {
    //     "state": "Kebbi",
    //     "lgas": [
    //         "Aleiro",
    //         "Arewa-Dandi",
    //         "Argungu",
    //         "Augie",
    //         "Bagudo",
    //         "Birnin-Kebbi",
    //         "Bunza",
    //         "Dandi",
    //         "Fakai",
    //         "Gwandu",
    //         "Jega",
    //         "Kalgo",
    //         "Koko-Besse",
    //         "Maiyama",
    //         "Ngaski",
    //         "Sakaba",
    //         "Shanga",
    //         "Suru",
    //         "Wasagu/Danko",
    //         "Yauri",
    //         "Zuru"
    //     ]
    // },
   
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
            "Zaria"
        ]
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
            "Wudil"
        ]
    },
    // {
    //     "state": "Kogi",
    //     "lgas": [
    //         "Adavi",
    //         "Ajaokuta",
    //         "Ankpa",
    //         "Dekina",
    //         "Ibaji",
    //         "Idah",
    //         "Igalamela-Odolu",
    //         "Ijumu",
    //         "Kabba\/Bunu",
    //         "Kogi",
    //         "Lokoja",
    //         "Mopa-Muro",
    //         "Ofu",
    //         "Ogori\/Magongo",
    //         "Okehi",
    //         "Okene",
    //         "Olamaboro",
    //         "Omala",
    //         "Oyi",
    //         "Yagba-East",
    //         "Yagba-West"
    //     ]
    // },
    // {
    //     "state": "Katsina",
    //     "lgas": [
    //         "Bakori",
    //         "Batagarawa",
    //         "Batsari",
    //         "Baure",
    //         "Bindawa",
    //         "Charanchi",
    //         "Dan-Musa",
    //         "Dandume",
    //         "Danja",
    //         "Daura",
    //         "Dutsi",
    //         "Dutsin-Ma",
    //         "Faskari",
    //         "Funtua",
    //         "Ingawa",
    //         "Jibia",
    //         "Kafur",
    //         "Kaita",
    //         "Kankara",
    //         "Kankia",
    //         "Katsina",
    //         "Kurfi",
    //         "Kusada",
    //         "Mai-Adua",
    //         "Malumfashi",
    //         "Mani",
    //         "Mashi",
    //         "Matazu",
    //         "Musawa",
    //         "Rimi",
    //         "Sabuwa",
    //         "Safana",
    //         "Sandamu",
    //         "Zango"
    //     ]
    // },
    // {
    //     "state": "Kwara",
    //     "lgas": [
    //         "Asa",
    //         "Baruten",
    //         "Edu",
    //         "Ekiti (Araromi/Opin)",
    //         "Ilorin-East",
    //         "Ilorin-South",
    //         "Ilorin-West",
    //         "Isin",
    //         "Kaiama",
    //         "Moro",
    //         "Offa",
    //         "Oke-Ero",
    //         "Oyun",
    //         "Pategi"
    //     ]
    // },
    // {
    //     "state": "Lagos",
    //     "lgas": [
    //         "Agege",
    //         "Ajeromi-Ifelodun",
    //         "Alimosho",
    //         "Amuwo-Odofin",
    //         "Apapa",
    //         "Badagry",
    //         "Epe",
    //         "Eti-Osa",
    //         "Ibeju-Lekki",
    //         "Ifako-Ijaiye",
    //         "Ikeja",
    //         "Ikorodu",
    //         "Kosofe",
    //         "Lagos-Island",
    //         "Lagos-Mainland",
    //         "Mushin",
    //         "Ojo",
    //         "Oshodi-Isolo",
    //         "Shomolu",
    //         "Surulere",
    //         "Yewa-South"
    //     ]
    // },
    // {
    //     "state": "Nasarawa",
    //     "lgas": [
    //         "Akwanga",
    //         "Awe",
    //         "Doma",
    //         "Karu",
    //         "Keana",
    //         "Keffi",
    //         "Kokona",
    //         "Lafia",
    //         "Nasarawa",
    //         "Nasarawa-Eggon",
    //         "Obi",
    //         "Wamba",
    //         "Toto"
    //     ]
    // },
    // {
    //     "state": "Niger",
    //     "lgas": [
    //         "Agaie",
    //         "Agwara",
    //         "Bida",
    //         "Borgu",
    //         "Bosso",
    //         "Chanchaga",
    //         "Edati",
    //         "Gbako",
    //         "Gurara",
    //         "Katcha",
    //         "Kontagora",
    //         "Lapai",
    //         "Lavun",
    //         "Magama",
    //         "Mariga",
    //         "Mashegu",
    //         "Mokwa",
    //         "Moya",
    //         "Paikoro",
    //         "Rafi",
    //         "Rijau",
    //         "Shiroro",
    //         "Suleja",
    //         "Tafa",
    //         "Wushishi"
    //     ]
    // },
    // {
    //     "state": "Ogun",
    //     "lgas": [
    //         "Abeokuta-North",
    //         "Abeokuta-South",
    //         "Ado-Odo\/Ota",
    //         "Ewekoro",
    //         "Ifo",
    //         "Ijebu-East",
    //         "Ijebu-North",
    //         "Ijebu-North-East",
    //         "Ijebu-Ode",
    //         "Ikenne",
    //         "Imeko-Afon",
    //         "Ipokia",
    //         "Obafemi-Owode",
    //         "Odeda",
    //         "Odogbolu",
    //         "Ogun-Waterside",
    //         "Remo-North",
    //         "Shagamu",
    //         "Yewa North"
    //     ]
    // },
    // {
    //     "state": "Ondo",
    //     "lgas": [
    //         "Akoko North-East",
    //         "Akoko North-West",
    //         "Akoko South-West",
    //         "Akoko South-East",
    //         "Akure-North",
    //         "Akure-South",
    //         "Ese-Odo",
    //         "Idanre",
    //         "Ifedore",
    //         "Ilaje",
    //         "Ile-Oluji-Okeigbo",
    //         "Irele",
    //         "Odigbo",
    //         "Okitipupa",
    //         "Ondo West",
    //         "Ondo-East",
    //         "Ose",
    //         "Owo"
    //     ]
    // },
    // {
    //     "state": "Osun",
    //     "lgas": [
    //         "Atakumosa West",
    //         "Atakumosa East",
    //         "Ayedaade",
    //         "Ayedire",
    //         "Boluwaduro",
    //         "Boripe",
    //         "Ede South",
    //         "Ede North",
    //         "Egbedore",
    //         "Ejigbo",
    //         "Ife North",
    //         "Ife South",
    //         "Ife-Central",
    //         "Ife-East",
    //         "Ifelodun",
    //         "Ila",
    //         "Ilesa-East",
    //         "Ilesa-West",
    //         "Irepodun",
    //         "Irewole",
    //         "Isokan",
    //         "Iwo",
    //         "Obokun",
    //         "Odo-Otin",
    //         "Ola Oluwa",
    //         "Olorunda",
    //         "Oriade",
    //         "Orolu",
    //         "Osogbo"
    //     ]
    // },
    // {
    //     "state": "Oyo",
    //     "lgas": [
    //         "Afijio",
    //         "Akinyele",
    //         "Atiba",
    //         "Atisbo",
    //         "Egbeda",
    //         "Ibadan North",
    //         "Ibadan North-East",
    //         "Ibadan North-West",
    //         "Ibadan South-East",
    //         "Ibadan South-West",
    //         "Ibarapa-Central",
    //         "Ibarapa-East",
    //         "Ibarapa-North",
    //         "Ido",
    //         "Ifedayo",
    //         "Irepo",
    //         "Iseyin",
    //         "Itesiwaju",
    //         "Iwajowa",
    //         "Kajola",
    //         "Lagelu",
    //         "Ogo-Oluwa",
    //         "Ogbomosho-North",
    //         "Ogbomosho-South",
    //         "Olorunsogo",
    //         "Oluyole",
    //         "Ona-Ara",
    //         "Orelope",
    //         "Ori-Ire",
    //         "Oyo-West",
    //         "Oyo-East",
    //         "Saki-East",
    //         "Saki-West",
    //         "Surulere"
    //     ]
    // },
    // {
    //     "state": "Plateau",
    //     "lgas": [
    //         "Barkin-Ladi",
    //         "Bassa",
    //         "Bokkos",
    //         "Jos-East",
    //         "Jos-North",
    //         "Jos-South",
    //         "Kanam",
    //         "Kanke",
    //         "Langtang-North",
    //         "Langtang-South",
    //         "Mangu",
    //         "Mikang",
    //         "Pankshin",
    //         "Qua'an Pan",
    //         "Riyom",
    //         "Shendam",
    //         "Wase"
    //     ]
    // },
    // {
    //     "state": "Rivers",
    //     "lgas": [
    //         "Abua\/Odual",
    //         "Ahoada-East",
    //         "Ahoada-West",
    //         "Akuku Toru",
    //         "Andoni",
    //         "Asari-Toru",
    //         "Bonny",
    //         "Degema",
    //         "Eleme",
    //         "Emuoha",
    //         "Etche",
    //         "Gokana",
    //         "Ikwerre",
    //         "Khana",
    //         "Obio\/Akpor",
    //         "Ogba-Egbema-Ndoni",
    //         "Ogba\/Egbema\/Ndoni",
    //         "Ogu\/Bolo",
    //         "Okrika",
    //         "Omuma",
    //         "Opobo\/Nkoro",
    //         "Oyigbo",
    //         "Port-Harcourt",
    //         "Tai"
    //     ]
    // },
    // {
    //     "state": "Sokoto",
    //     "lgas": [
    //         "Binji",
    //         "Bodinga",
    //         "Dange-Shuni",
    //         "Gada",
    //         "Goronyo",
    //         "Gudu",
    //         "Gwadabawa",
    //         "Illela",
    //         "Kebbe",
    //         "Kware",
    //         "Rabah",
    //         "Sabon Birni",
    //         "Shagari",
    //         "Silame",
    //         "Sokoto-North",
    //         "Sokoto-South",
    //         "Tambuwal",
    //         "Tangaza",
    //         "Tureta",
    //         "Wamako",
    //         "Wurno",
    //         "Yabo"
    //     ]
    // },
    // {
    //     "state": "Taraba",
    //     "lgas": [
    //         "Ardo-Kola",
    //         "Bali",
    //         "Donga",
    //         "Gashaka",
    //         "Gassol",
    //         "Ibi",
    //         "Jalingo",
    //         "Karim-Lamido",
    //         "Kurmi",
    //         "Lau",
    //         "Sardauna",
    //         "Takum",
    //         "Ussa",
    //         "Wukari",
    //         "Yorro",
    //         "Zing"
    //     ]
    // },
    // {
    //     "state": "Yobe",
    //     "lgas": [
    //         "Bade",
    //         "Bursari",
    //         "Damaturu",
    //         "Fika",
    //         "Fune",
    //         "Geidam",
    //         "Gujba",
    //         "Gulani",
    //         "Jakusko",
    //         "Karasuwa",
    //         "Machina",
    //         "Nangere",
    //         "Nguru",
    //         "Potiskum",
    //         "Tarmuwa",
    //         "Yunusari",
    //         "Yusufari"
    //     ]
    // },
    // {
    //     "state": "Zamfara",
    //     "lgas": [
    //         "Anka",
    //         "Bakura",
    //         "Birnin Magaji/Kiyaw",
    //         "Bukkuyum",
    //         "Bungudu",
    //         "Gummi",
    //         "Gusau",
    //         "Isa",
    //         "Kaura-Namoda",
    //         "Kiyawa",
    //         "Maradun",
    //         "Maru",
    //         "Shinkafi",
    //         "Talata-Mafara",
    //         "Tsafe",
    //         "Zurmi"
    //     ]
    // }

];