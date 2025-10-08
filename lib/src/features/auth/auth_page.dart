import 'package:hugeicons/hugeicons.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:transborder_logistics/src/features/auth/controllers/auth_controller.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';
import 'package:transborder_logistics/src/global/ui/widgets/fields/custom_textfield.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transborder_logistics/src/global/ui/widgets/text/app_text.dart';

import '../../app/app_barrel.dart';
import '../../utils/utils_barrel.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final controller = Get.find<AuthController>();
  String oldPass = "";
  bool isDisabled = true;

  @override
  void initState() {
    super.initState();
  }

  void _updateButtonState() {
    setState(() {
      isDisabled = !controller.authFormKey.currentState!.validate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SinglePageScaffold(
      hasBack: false,
      title: "Login",
      child: Form(
        key: controller.authFormKey,
        onChanged: _updateButtonState,
        child: Column(
          children: [
            Ui.align(
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0,bottom: 12),
                child: AppText.medium(
                  "DETAILS",
                  fontSize: 10,
                  color: AppColors.lightTextColor,
                ),
              ),
            ),
            CurvedContainer(
              border: Border.all(color: AppColors.borderColor),
              margin: EdgeInsets.symmetric(horizontal: 16),
              radius: 12,
              child: Column(
                children: [
                  CustomTextField(
                    "johndoe@gmail.com",
                    controller.textControllers[0],
                    prefix: HugeIcons.strokeRoundedMail01,
                    label: "Email",
                  ),
                  Ui.align(
                    align: Alignment.centerRight,
                    child: SizedBox(
                      width: Ui.width(context) - 56,
                      child: AppDivider(),
                    ),
                  ),
                  CustomTextField(
                    "Password",
                    controller.textControllers[1],
                    prefix: HugeIcons.strokeRoundedLockPassword,
                    label: "Password",
                    varl: FPL.password,
                  ),
                ],
              ),
            ),
            Ui.boxHeight(4),
            Obx(
               () {
                return AppText.thin(controller.errorText.value,fontSize: 10,color: AppColors.red);
              }
            ),
            Ui.boxHeight(26),
            SizedBox(
              width: Ui.width(context) / 3,
              child: AppButton(onPressed: () async {
                await controller.onAuthPressed();
              }, text: "Login"),
            ),
          ],
        ),
      ),
    );
  }
}
