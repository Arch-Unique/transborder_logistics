import 'package:transborder_logistics/src/features/auth/auth_page.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/explorer.dart';
import 'package:transborder_logistics/src/features/dashboard/views/driver/driver_home.dart';
import 'package:transborder_logistics/src/src_barrel.dart';
import 'package:transborder_logistics/src/utils/constants/routes/middleware/auth_middleware.dart';
import 'package:get/get.dart';

class AppPages {
  static List<GetPage> getPages = [
    GetPage(
      name: AppRoutes.home,
      page: () => AuthScreen(),
      middlewares: [AuthMiddleWare()],
    ),
    GetPage(name: AppRoutes.auth, page: () => AuthScreen()),
    GetPage(name: AppRoutes.dashboard, page: () => AdminExplorer()),
  ];
}
