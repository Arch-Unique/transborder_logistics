import 'package:hugeicons/hugeicons.dart';
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

  @override
  Widget build(BuildContext context) {
    return Ui.isBigScreen(context)
        ? _DesktopLogin(controller: controller)
        : _MobileLogin(controller: controller);
  }
}

class _DesktopLogin extends StatelessWidget {
  const _DesktopLogin({required this.controller});
  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                image: const DecorationImage(
                  image: AssetImage(Assets.onb),
                  fit: BoxFit.cover,
                  opacity: 0.15,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.asset(Assets.fulllogo, width: 140),
                      ),
                      const Spacer(),
                      Center(
                        child: Image.asset(
                          Assets.truck,
                          width: Ui.width(context) * 0.28,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Spacer(),
                      AppText.bold(
                        'Delivering\nExcellence\nAcross Borders',
                        fontSize: 36,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      AppText.thin(
                        'Real-time logistics management\nfor modern supply chains.',
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          _StatBadge(label: 'Trips', value: '2K+'),
                          const SizedBox(width: 24),
                          _StatBadge(label: 'Locations', value: '500+'),
                          const SizedBox(width: 24),
                          _StatBadge(label: 'Drivers', value: '50+'),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              color: AppColors.primaryColorBackground,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(48),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.bold('Welcome back', fontSize: 32),
                        const SizedBox(height: 8),
                        AppText.thin(
                          'Sign in to your account to continue',
                          fontSize: 14,
                          color: AppColors.lightTextColor,
                        ),
                        const SizedBox(height: 40),
                        _LoginForm(controller: controller),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileLogin extends StatelessWidget {
  const _MobileLogin({required this.controller});
  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: Ui.height(context) * 0.38,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              image: const DecorationImage(
                image: AssetImage(Assets.onb),
                fit: BoxFit.cover,
                opacity: 0.15,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Image.asset(Assets.fulllogo, width: 120),
                      const SizedBox(height: 16),
                      Image.asset(
                        Assets.truck,
                        width: Ui.width(context) * 0.5,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColorBackground,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          AppText.bold('Welcome back', fontSize: 26),
                          const SizedBox(height: 6),
                          AppText.thin(
                            'Sign in to continue',
                            fontSize: 13,
                            color: AppColors.lightTextColor,
                          ),
                          const SizedBox(height: 32),
                          _LoginForm(controller: controller),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.controller});
  final AuthController controller;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.controller.authFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium('Email / Phone', fontSize: 13, color: AppColors.lightTextColor),
          const SizedBox(height: 8),
          CurvedContainer(
            border: Border.all(color: AppColors.borderColor),
            radius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: CustomTextField(
              'johndoe@gmail.com',
              widget.controller.textControllers[0],
              prefix: HugeIcons.strokeRoundedMail01,
              label: '',
            ),
          ),
          const SizedBox(height: 20),
          AppText.medium('PIN', fontSize: 13, color: AppColors.lightTextColor),
          const SizedBox(height: 8),
          CurvedContainer(
            border: Border.all(color: AppColors.borderColor),
            radius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: CustomTextField(
              '••••',
              widget.controller.textControllers[1],
              prefix: HugeIcons.strokeRoundedLockPassword,
              label: '',
              varl: FPL.password,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => widget.controller.errorText.value.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFFF1F1F), size: 14),
                      const SizedBox(width: 6),
                      AppText.thin(
                        widget.controller.errorText.value,
                        fontSize: 12,
                        color: AppColors.red,
                      ),
                    ],
                  ),
                )
              : const SizedBox(height: 8)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () async => await widget.controller.onAuthPressed(),
              text: 'Sign In',
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: AppText.thin(
              '© 2026 Transborder Logistics. All rights reserved.',
              fontSize: 11,
              color: AppColors.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bold(value, fontSize: 22, color: Colors.white),
        AppText.thin(label, fontSize: 12, color: Colors.white.withOpacity(0.7)),
      ],
    );
  }
}