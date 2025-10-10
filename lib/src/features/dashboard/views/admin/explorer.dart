import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/drawer.dart';
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
        title: "Dashboard",
        hasBack: false,
        leading: InkWell(
          onTap: () {
            //open drawer
            gkey.currentState?.openDrawer();
          },
          child: Padding(
            padding: EdgeInsets.only(left: 8.0,right:8),
            child: AppIcon(
              HugeIcons.strokeRoundedMenu02,
              color: AppColors.darkTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
