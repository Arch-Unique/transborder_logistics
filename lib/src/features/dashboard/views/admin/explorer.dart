import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/drawer.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/resource_history.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';
import 'package:transborder_logistics/src/src_barrel.dart';

class AdminExplorer extends StatefulWidget {
  const AdminExplorer({super.key});

  @override
  State<AdminExplorer> createState() => _AdminExplorerState();
}

class _AdminExplorerState extends State<AdminExplorer> {
  final controller = Get.find<DashboardController>();

  @override
  void initState() {
    controller.initApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gkey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: gkey,
      drawer: AppDrawer(),
      appBar: backAppBar(
        titleWidget: Obx(
           () {
            return AppText.medium(controller.curResourceHistory.value.title, fontSize: 16, color: AppColors.textColor);
          }
        ),
        hasBack: false,
        leading: InkWell(
          onTap: () {
            //open drawer
            gkey.currentState?.openDrawer();
          },
          child: Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8),
            child: AppIcon(
              HugeIcons.strokeRoundedMenu02,
              color: AppColors.darkTextColor,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return controller.curResourceHistory.value.title == "Dashboard"
            ? SizedBox()
            : ResourceHistoryPage(
                controller.curResourceHistory.value.title,
                controller.curResourceHistory.value.items,
                filters: controller.curResourceHistory.value.filters,
                onFilter: controller.curResourceHistory.value.onFilter,
                hasDrawer: true,
              );
      }),
    );
  }
}
