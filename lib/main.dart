import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:transborder_logistics/fcm_functions.dart';
import 'package:transborder_logistics/firebase_options.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

import 'src/global/services/app_service.dart';
import 'src/global/services/dependencies.dart';
import 'src/global/views/pages.dart';
import 'src/src_barrel.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (GetPlatform.isMobile) {
  await fcmFunctions.initApp();
  await fcmFunctions.iosWebPermission();
  Get.put(DashboardController());
  fcmFunctions.listenToNotif(message);
  print("Handling a background message: ${message.messageId}");
}
}

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await GetStorage.init("transborder2");
  await AppDependency.init();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  if (GetPlatform.isMobile) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await fcmFunctions.initApp();
    await fcmFunctions.iosWebPermission();
    fcmFunctions.foreGroundMessageListener();
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // if (kReleaseMode) exit(1);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    log('PlatformDispatcher.onError: $error');
    log(error.toString(), stackTrace: stack);
    return true;
  };
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppService>();
    
    return Obx(
       () {
        print(controller.isDarkMode.value);
        return GetMaterialApp(
          builder: (context, widget) {
            Widget error = const Text('...there was an error...');
            if (widget is Scaffold || widget is Navigator) {
              error = Scaffold(
                body: Center(child: error),
              );
            }
        
            ErrorWidget.builder = (errorDetails) => error;
            if (widget != null) {
              return widget;
            }
            throw FlutterError('...widget is null...');
          },
          initialRoute: AppRoutes.home,
          title: 'Transborder Logistics',
          getPages: AppPages.getPages,
          theme: ThemeData(
              scaffoldBackgroundColor: AppColors.primaryColorBackground,
              fontFamily: Assets.appFontFamily,
              primarySwatch: AppColors.primaryColor,
              brightness:
                  controller.isDarkMode.value ? Brightness.dark : Brightness.light,
              ),
        );
      }
    );
  }
}
