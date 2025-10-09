import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/views/shared.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';
import 'package:transborder_logistics/src/src_barrel.dart';

import '../../../../global/ui/ui_barrel.dart';

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    return Obx(() {
      if (controller.undeliveredDeliveries.isEmpty) {
        return Center(
          child: AppText.thin("No deliveries assigned yet", fontSize: 13),
        );
      }
      return ListView.builder(
        itemCount: controller.undeliveredDeliveries.length,
        itemBuilder: (c, i) {
          return DeliveryInfo(controller.undeliveredDeliveries[i]);
        },
      );
    });
  }
}

class DriverHistoryPage extends StatelessWidget {
  const DriverHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    return SinglePageScaffold(
      title: "History",
      hasBack: false,
      child: Obx(() {
        if (controller.allDeliveries.isEmpty) {
          return Center(
            child: AppText.thin("No deliveries assigned yet", fontSize: 13),
          );
        }
        return ListView.builder(
          itemCount: controller.allDeliveries.length,
          itemBuilder: (c, i) {
            return DeliveryInfo(controller.allDeliveries[i]);
          },
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

  navItem(dynamic icon, int i) {
    return InkWell(
      onTap: () => controller.curMode.value = i,
      child: Obx(
         () {
          return CircleAvatar(
            radius: 20,
            backgroundColor: i == controller.curMode.value
                ? AppColors.primaryColor[100]!
                : AppColors.borderColor,
            child: CircleAvatar(
              radius: 19.5,
              backgroundColor:i == controller.curMode.value
                ? AppColors.primaryColor
                : Color(0xFFF7F7F7) ,
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
        }
      ),
    );
  }
}

class DriverExplorer extends StatelessWidget {
  DriverExplorer({super.key});
  final controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
       () {
        return SinglePageScaffold(
          title: controller.curMode.value == 0 ? "Pick Up" : "Profile",
          hasBack: false,
          child: Stack(
            children: [
              controller.curMode.value == 0
                  ? DriverHomePage()
                  : ProfilePage(),
                  Positioned(child: BottomNavBar(),bottom: 24,)
            ],
          ),
        );
      }
    );
  }
}