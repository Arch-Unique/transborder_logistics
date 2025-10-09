import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/drawer.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';
import 'package:transborder_logistics/src/src_barrel.dart';

class AdminExplorer extends StatelessWidget {
  const AdminExplorer({super.key});

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
          child: AppIcon(
            HugeIcons.strokeRoundedMenu02,
            color: AppColors.darkTextColor,
          ),
        ),
      ),
    );
  }
}
