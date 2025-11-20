import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/resource_history.dart';
import 'package:transborder_logistics/src/features/dashboard/views/shared.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';
import 'package:transborder_logistics/src/src_barrel.dart';

import '../../../../global/model/barrel.dart';
import '../../../../global/ui/ui_barrel.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final controller = Get.find<DashboardController>();

  @override
  void initState() {
    getCustomerDeliveries();
    super.initState();
  }

  Future getCustomerDeliveries() async {
    await controller.getCustomerDelivery();
  }

  Future refreshDeliveries() async {
    await Get.showOverlay(
      asyncFunction: () async {
        await getCustomerDeliveries();
      },
      opacity: 0.8,
      loadingWidget: const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.undeliveredDeliveries.isEmpty) {
        return Center(
          child: AppText.thin("No deliveries assigned yet", fontSize: 13),
        );
      }
      return RefreshScrollView(
        onExtend: () async {},
        onRefreshed: () async {
          await refreshDeliveries();
        },
        child: ListView.builder(
          itemCount: controller.undeliveredDeliveries.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (c, i) {
            return DeliveryInfo(controller.undeliveredDeliveries[i]);
          },
        ),
      );
    });
  }
}

class DriverHistoryPage extends StatefulWidget {
  const DriverHistoryPage({super.key});

  @override
  State<DriverHistoryPage> createState() => _DriverHistoryPageState();
}

class _DriverHistoryPageState extends State<DriverHistoryPage> {
  final controller = Get.find<DashboardController>();

  @override
  void initState() {
    getCustomerDeliveries();
    super.initState();
  }

  Future getCustomerDeliveries() async {
    await controller.getCustomerDelivery();
  }

  Future refreshDeliveries() async {
    await Get.showOverlay(
      asyncFunction: () async {
        await getCustomerDeliveries();
      },
      opacity: 0.8,
      loadingWidget: const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SinglePageScaffold(
      title: "History",
      child: Obx(() {
        if (controller.allDeliveries.isEmpty) {
          return Center(
            child: AppText.thin("No deliveries assigned yet", fontSize: 13),
          );
        }
        return RefreshScrollView(
          onExtend: () async {},
          onRefreshed: () async {
            await refreshDeliveries();
          },
          child: ListView.builder(
            itemCount: controller.allDeliveries.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (c, i) {
              return DeliveryInfo(controller.allDeliveries[i]);
            },
          ),
        );
      }),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  BottomNavBar({super.key});
  final controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      border: Border.all(color: AppColors.borderColor),
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          navItem(HugeIcons.strokeRoundedContainerTruck01, 0),
          Ui.boxWidth(16),
          navItem(HugeIcons.strokeRoundedUser, 1),
        ],
      ),
    );
  }

  InkWell navItem(dynamic icon, int i) {
    return InkWell(
      onTap: () => controller.curMode.value = i,
      child: Obx(() {
        return CircleAvatar(
          radius: 20,
          backgroundColor: i == controller.curMode.value
              ? AppColors.primaryColor[100]!
              : AppColors.borderColor,
          child: CircleAvatar(
            radius: 19.5,
            backgroundColor: i == controller.curMode.value
                ? AppColors.primaryColor
                : Color(0xFFF7F7F7),
            child: Center(
              child: AppIcon(
                icon,
                color: i == controller.curMode.value
                    ? AppColors.primaryColor[100]!
                    : AppColors.lightTextColor,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class DriverExplorer extends StatelessWidget {
  DriverExplorer({super.key});
  final controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SinglePageScaffold(
        title: controller.curMode.value == 0 ? "Pick Up" : "Profile",
        trailing: [
          InkWell(
            child: AppIcon(HugeIcons.strokeRoundedQrCode),
            onTap: () {
              Get.to(ScannerPage());
            },
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: AppIcon(HugeIcons.strokeRoundedNotification01),
            ),
            onTap: () {
              // Get.to(DriverHistoryPage());
              Get.to(
                ResourceHistoryPage<Delivery>(
                  "All Deliveries",
                  controller.allDeliveries,
                  filters: ["All", "New", "Ongoing", "Completed"],
                  onFilter: (v, s) {
                    controller.getFilters(v, s, "drivertrips");
                  },
                ),
              );
            },
          ),
        ],
        hasBack: false,
        child: Stack(
          children: [
            SizedBox(
              height: Ui.height(context) - 72,
              child: controller.curMode.value == 0
                  ? DriverHomePage()
                  : ProfilePage(),
            ),
            Positioned(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [BottomNavBar()],
              ),
              bottom: 24,
              width: Ui.width(context),
            ),
          ],
        ),
      );
    });
  }
}
