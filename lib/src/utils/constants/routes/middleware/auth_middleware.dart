import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:transborder_logistics/src/global/services/barrel.dart';
import 'package:flutter/src/widgets/navigator.dart';
import 'package:get/get.dart';

import '../route.dart';

class AuthMiddleWare extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final controller = Get.find<AppService>();
    FlutterNativeSplash.remove();
    if (controller.hasOpenedOnboarding.value) {
      if (controller.isLoggedIn.value) {
        return const RouteSettings(name: AppRoutes.dashboard);
      } else {
        return const RouteSettings(name: AppRoutes.auth);
      }
    }
    return super.redirect(route);
  }
}

class AppMiddleWare extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final controller = Get.find<AppService>();
    FlutterNativeSplash.remove();
    if (!controller.currentUser.value.isAdmin) {
      return const RouteSettings(name: AppRoutes.driverDashboard);
    }
    return super.redirect(route);
  }
}
