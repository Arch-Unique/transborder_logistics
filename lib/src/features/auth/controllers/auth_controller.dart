import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';
import 'package:transborder_logistics/src/src_barrel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../dashboard/repository/app_repo.dart';

class AuthController {
  ///TEXT EDITING CONTROLLERS
  ///0 - LOGIN EMAIL/PHONE
  ///1 - LOGIN PASSWORD
  List<TextEditingController> textControllers = List.generate(
    8,
    (index) => TextEditingController(),
  );

  final authFormKey = GlobalKey<FormState>();
  final appRepo = Get.find<AppRepo>();
  final RxString errorText = "".obs;

  onAuthPressed() async {
    final ss = authFormKey.currentState!.validateGranularly();
    if (ss.isEmpty) {
      try {
        await _onLogin();

        Get.offAllNamed(AppRoutes.dashboard);
        clearTextControllers();
      } catch (e) {
        Ui.showError(e.toString());
      }
      
    } else {
      errorText.value = ss.first.errorText ?? "Please fill all fields";
    }
  }

  _onLogin() async {
    await appRepo.login(
      textControllers[0].value.text,
      textControllers[1].value.text,
    );
  }

  clearTextControllers() {
    UtilFunctions.clearTextEditingControllers(textControllers);
  }
}
