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
    final form = Form(
      key: controller.authFormKey,
      onChanged: _updateButtonState,
      child: Column(
        children: [
          Ui.align(
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, bottom: 24),
              child: AppText.medium(
                "ENTER YOUR DETAILS",
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
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4),
                  child: CustomTextField(
                    "johndoe@gmail.com",
                    controller.textControllers[0],
                    prefix: HugeIcons.strokeRoundedMail01,
                    label: "Email/Phone",
                  ),
                ),
                Ui.align(
                  align: Alignment.centerRight,
                  child: SizedBox(
                    width: Ui.swidth(context) - 56,
                    child: AppDivider(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: CustomTextField(
                    "PIN",
                    controller.textControllers[1],
                    prefix: HugeIcons.strokeRoundedLockPassword,
                    label: "PIN",
                    varl: FPL.password,
                  ),
                ),
              ],
            ),
          ),
          Ui.boxHeight(4),
          Obx(() {
            return AppText.thin(
              controller.errorText.value,
              fontSize: 10,
              color: AppColors.red,
            );
          }),
          Ui.boxHeight(26),
          SizedBox(
            width: Ui.isBigScreen(context) ? 120 : Ui.width(context) / 3,
            child: AppButton(
              onPressed: () async {
                await controller.onAuthPressed();
              },
              text: "Login",
            ),
          ),
        ],
      ),
    );
    return Ui.isBigScreen(context)
        ? Scaffold(
            body: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: AppIcon(Assets.fulllogo, size: 120),
                        )),
                      SizedBox(
                        width: 400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: AppText.thin(
                                "Welcome Back",
                                fontSize: 36,
                                alignment: TextAlign.start,
                              ),
                            ),
                            Ui.boxHeight(8),
                            form,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Image.asset(
                        Assets.onb,
                        height: Ui.height(context),
                        width: Ui.width( context)/3,
                        fit: BoxFit.cover,
                      ),
                      Image.asset(
                        Assets.truck,
                        width: Ui.width( context)/3,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : SinglePageScaffold(hasBack: false, title: "Login", child: form);
  }
}
