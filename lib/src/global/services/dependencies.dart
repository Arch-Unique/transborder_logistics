import 'package:transborder_logistics/src/features/auth/controllers/auth_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/global/controller/connection_controller.dart';
import 'package:transborder_logistics/src/global/services/barrel.dart';
import 'package:get/get.dart';

import '../../features/dashboard/repository/app_repo.dart';

class AppDependency {
  static init() async {
    Get.put(MyPrefService());
    Get.put(DioApiService());
    await Get.putAsync(() async {
      final connectTivity = ConnectionController();
      await connectTivity.init();
      return connectTivity;
    });
    await Get.putAsync(() async {
      final appService = AppService();
      await appService.initUserConfig();
      return appService;
    });

    //repos
    Get.put(AppRepo());

    //controllers
    Get.put(AuthController());
    Get.put(DashboardController());
  }
}
