import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/features/dashboard/views/shared.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';
import 'package:transborder_logistics/src/src_barrel.dart';

import '../../../../global/services/barrel.dart';
import '../../../../global/ui/ui_barrel.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final appService = Get.find<AppService>();
    return CurvedContainer(
      radius: 0,
      width: Ui.width(context) * 0.75,
      child: Ui.padding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Ui.boxHeight(24),
            AppIcon(Assets.logo, size: 48),
            Ui.boxHeight(48),
            AppContainer(
              "",
              DashboardMode.values
                  .map(
                    (e) => Row(
                      children: [
                        AppIcon(e.icon, size: 20),
                        Ui.boxWidth(8),
                        AppText.medium(e.name, fontSize: 14),
                      ],
                    ),
                  )
                  .toList(),
              hasBorder: false,
            ),
            Spacer(),
            Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CurvedImage("", w: 48, h: 48, fit: BoxFit.cover),
                ),
                Ui.boxWidth(8),
                Expanded(
                  child: AppText.medium(
                    appService.currentUser.value.name ?? "N/A",
                    fontSize: 14,
                  ),
                ),
                Ui.boxWidth(8),
                AppIcon(HugeIcons.strokeRoundedMoreHorizontal),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
