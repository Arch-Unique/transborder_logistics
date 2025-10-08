import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/views/shared.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';

import '../../../../global/ui/ui_barrel.dart';

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    return SinglePageScaffold(
      title: "Pick Up",
      hasBack: false,
      child: Obx(() {
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
      }),
    );
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
