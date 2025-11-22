import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/dashboard.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/drawer.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/resource_history.dart';
import 'package:transborder_logistics/src/features/dashboard/views/shared.dart';
import 'package:transborder_logistics/src/global/model/user.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';
import 'package:transborder_logistics/src/src_barrel.dart';

class AdminExplorer extends StatefulWidget {
  const AdminExplorer({super.key});

  @override
  State<AdminExplorer> createState() => _AdminExplorerState();
}

class _AdminExplorerState extends State<AdminExplorer> {
  final controller = Get.find<DashboardController>();
  final gkey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    controller.initApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Ui.isBigScreen(context)
        ? desktopVersion()
        : Scaffold(
            key: gkey,
            drawer: AppDrawer(),
            appBar: backAppBar(
              titleWidget: Obx(() {
                return AppText.medium(
                  controller.curResourceHistory.value.title,
                  fontSize: 16,
                  color: AppColors.textColor,
                );
              }),
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
              trailing: [
                Obx(() {
                  return controller.curResourceHistory.value.title ==
                              "Dashboard" ||
                          controller.curResourceHistory.value.title ==
                              "Location"
                      ? SizedBox()
                      : InkWell(
                          onTap: () async {
                            await controller.exportData();
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 16),
                            child: AppIcon(
                              HugeIcons.strokeRoundedDownload01,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        );
                }),
                Obx(() {
                  return controller.curResourceHistory.value.title ==
                              "Dashboard" ||
                          controller.curResourceHistory.value.title ==
                              "Location"
                      ? InkWell(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: AppIcon(HugeIcons.strokeRoundedQrCode),
                          ),
                          onTap: () {
                            Get.to(ScannerPage());
                          },
                        )
                      : InkWell(
                          onTap: () {
                            Get.bottomSheet(
                              AddResource(
                                controller.curResourceHistory.value.title,
                              ),
                              isScrollControlled: true,
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 16),
                            child: AppIcon(
                              HugeIcons.strokeRoundedAddCircle,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        );
                }),
              ],
            ),
            body: Obx(() {
              print("hello");
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              final title = controller.curResourceHistory.value.title;

              return title == "Dashboard"
                  ? DashboardScreen()
                  : ResourceHistoryPage(
                      title,
                      controller.curResourceHistory.value.items,
                      filters: controller.curResourceHistory.value.filters,
                      onFilter: controller.curResourceHistory.value.onFilter,
                      hasDrawer: true,
                      key: ValueKey(title),
                    );
            }),
          );
  }

  desktopVersion() {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: Ui.width(context) / 5, child: AppDrawer()),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              return controller.curResourceHistory.value.title == "Dashboard"
                  ? DashboardScreen()
                  : ResourceHistoryDesktopPage(
                      controller.curResourceHistory.value.title,
                      controller.curResourceHistory.value.items,
                      filters: controller.curResourceHistory.value.filters,
                      onFilter: controller.curResourceHistory.value.onFilter,
                      hasDrawer: false,
                    );
            }),
          ),
        ],
      ),
    );
  }
}
