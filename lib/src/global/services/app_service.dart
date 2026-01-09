import 'dart:async';

import 'package:transborder_logistics/fcm_functions.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/repository/app_repo.dart';
import 'package:transborder_logistics/src/global/model/user.dart';
import 'package:transborder_logistics/src/global/services/barrel.dart';
import 'package:transborder_logistics/src/plugin/jwt.dart';
import 'package:transborder_logistics/src/src_barrel.dart';
import 'package:transborder_logistics/src/utils/constants/prefs/prefs.dart';
import 'package:get/get.dart';

class AppService extends GetxService {
  Rx<User> currentUser = User().obs;
  RxBool hasOpenedOnboarding = false.obs;
  RxBool isLoggedIn = false.obs;
  RxBool isDarkMode = false.obs;
  final apiService = Get.find<DioApiService>();
  final prefService = Get.find<MyPrefService>();

  Future<void> initUserConfig() async {
    try {
      await _hasOpened();
      await _setLoginStatus();
      if (isLoggedIn.value) {
        await _setCurrentUser();
      }
      isDarkMode.value = prefService.get(MyPrefs.mpDarkMode) ?? false;
    } catch (e) {
      isLoggedIn.value = false;
    }
  }

  toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    await prefService.save(MyPrefs.mpDarkMode, isDarkMode.value);
  }

  Future<void> loginUser(String jwt, String refreshJwt) async {
    await _saveJWT(jwt, refreshJwt);
    await _setCurrentUser();
  }

  Future<void> logout() async {
    // await apiService.post(AppUrls.logout);
    Get.find<DashboardController>().resetApp();
    await _logout();
  }

  Future<void> updateFCMtoken() async {
    if (GetPlatform.isMobile) {
      final token = await FCMFunctions().getFCMToken();
      if (token != null) {
        await Get.find<AppRepo>().updateFCM(token);
      }
    }
  }

  Future<void> _hasOpened() async {
    bool a = prefService.get(MyPrefs.hasOpenedOnboarding) ?? false;
    if (a == false) {
      await prefService.save(MyPrefs.hasOpenedOnboarding, true);
    }
    hasOpenedOnboarding.value = a;
  }

  Future<void> _saveUser() async {
    await prefService.saveAll({
      MyPrefs.mpLoggedInEmail: currentUser.value.email,
      MyPrefs.mpFirstName: currentUser.value.name,
      MyPrefs.mpPhone: currentUser.value.phone,
      MyPrefs.mpCustomerLoc: currentUser.value.location,
      MyPrefs.mpCustomerName: currentUser.value.name,
      MyPrefs.mpUserRole: currentUser.value.role,
      MyPrefs.mpLoggedInURLPhoto: currentUser.value.image,
    });
  }

  Future<void> _logout() async {
    final b = prefService.get(MyPrefs.mpLogin3rdParty) ?? false;
    if (b) {
      // final c = await GoogleSignIn().isSignedIn();
      // if (c) {
      //   await GoogleSignIn().disconnect();
      // }
    }
    await prefService.eraseAllExcept(MyPrefs.hasOpenedOnboarding);
  }

  Future<void> _saveJWT(String jwt, String refreshJwt) async {
    final msg = Jwt.parseJwt(jwt);
    await prefService.saveAll({
      MyPrefs.mpLoginExpiry: msg["exp"],
      MyPrefs.mpUserJWT: jwt,
      MyPrefs.mpUserID: msg["id"],
      MyPrefs.mpIsLoggedIn: true,
      MyPrefs.mpUserRefreshJWT: refreshJwt,
    });
  }

  // _refreshToken() async {
  //   final res = await apiService.post(
  //     AppUrls.changePassword,
  //     data: {"refresh_token": prefService.get(MyPrefs.mpUserRefreshJWT)},
  //   );
  //   await _saveJWT(res.data["access_token"], res.data["refresh_token"]);
  // }

  Future<void> _setCurrentUser() async {
    final res = await apiService.get("${AppUrls.profileURL}/user/p");
    final user = User.fromJson(res.data["data"]);
    currentUser.value.email = user.email;
    currentUser.value.id = user.id;
    currentUser.value.name = user.name;
    currentUser.value.phone = user.phone;
    currentUser.value.location = user.location;
    currentUser.value.role = user.role;
    currentUser.value.image = user.image;
    _saveUser();
    //_listenToRefreshTokenExpiry();
  }

  Future<void> refreshUser() async {
    final res = await apiService.get("${AppUrls.profileURL}/user/p");
    final user = User.fromJson(res.data["data"]);
    currentUser.value.name = user.name;
    currentUser.value.phone = user.phone;
    currentUser.value.location = user.location;
    currentUser.value.role = user.role;
    currentUser.value.image = user.image;
    currentUser.refresh();
    _saveUser();
  }

  Future<void> _setLoginStatus() async {
    final e = prefService.get(MyPrefs.mpLoginExpiry) ?? 0;
    if (e != 0 && DateTime.now().millisecondsSinceEpoch > e * 1000) {
      //await _refreshToken();
      isLoggedIn.value = true;
    }
    isLoggedIn.value = prefService.get(MyPrefs.mpIsLoggedIn) ?? false;
  }

  void _listenToRefreshTokenExpiry() {
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      final e = prefService.get(MyPrefs.mpLoginExpiry) ?? 0;
      if (e == 0) {
        timer.cancel();
      } else if (DateTime.now().millisecondsSinceEpoch - (e * 1000) > 100000) {
        // await _refreshToken();
      }
    });
  }
}
