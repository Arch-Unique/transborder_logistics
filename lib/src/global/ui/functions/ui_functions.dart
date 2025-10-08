import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../ui_barrel.dart';
import '/src/app/app_barrel.dart';
import '/src/utils/utils_barrel.dart';

abstract class Ui {
  static SizedBox boxHeight(double height) => SizedBox(height: height);

  static SizedBox boxWidth(double width) => SizedBox(width: width);

  ///All padding
  static Padding padding({Widget? child, double padding = 24}) => Padding(
        padding: EdgeInsets.all(padding),
        child: child,
      );

  static Align align({Widget? child, Alignment align = Alignment.centerLeft}) =>
      Align(
        alignment: align,
        child: child,
      );

  static BorderRadius circularRadius(double radius) => BorderRadius.all(
        Radius.circular(radius),
      );

  static BorderRadius topRadius(double radius) => BorderRadius.vertical(
        top: Radius.circular(radius),
      );

  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static bool isSmallScreen(BuildContext context) {
    return width(context) < 330;
  }

  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static BorderRadius bottomRadius(double radius) => BorderRadius.vertical(
        bottom: Radius.circular(radius),
      );

  static BorderSide simpleBorderSide({Color color = AppColors.grey}) =>
      BorderSide(
        color: color,
        width: 1,
      );

  static showInfo(String message) {
    Get.closeAllSnackbars();

    Get.snackbar("Info", message, leftBarIndicatorColor: Colors.green);
    // Get.showSnackbar(GetSnackBar(
    //   messageText: AppText.thin(message,
    //       fontSize: 12, color: AppColors.black, alignment: TextAlign.center),
    //   boxShadows: [
    //     BoxShadow(
    //         offset: Offset(0, -4),
    //         blurRadius: 40,
    //         color: AppColors.textFieldColor)
    //   ],
    //   backgroundColor: AppColors.textFieldColor,
    //   borderRadius: 16,
    //   forwardAnimationCurve: Curves.elasticInOut,
    //   icon: Image.asset(
    //     Assets.logo,
    //     width: 24,
    //     height: 24,
    //   ),
    //   animationDuration: Duration(milliseconds: 1500),
    //   duration: Duration(seconds: 3),
    //   padding: EdgeInsets.all(24),
    //   isDismissible: true,
    //   margin: EdgeInsets.only(left: 24, right: 24, bottom: 24),
    // ));
  }

  static showError(String message) {
    Get.closeAllSnackbars();
    Get.snackbar("Error", message, leftBarIndicatorColor: Colors.red);
    // Get.showSnackbar(GetSnackBar(
    //   messageText: AppText.thin(message, fontSize: 12, color: AppColors.black),
    //   boxShadows: [
    //     BoxShadow(
    //         offset: Offset(0, -4),
    //         blurRadius: 40,
    //         color: AppColors.textFieldColor)
    //   ],
    //   shouldIconPulse: true,
    //   icon: AppIcon(Iconsax.danger_outline),
    //   backgroundColor: AppColors.textFieldColor,
    //   borderRadius: 16,
    //   duration: Duration(seconds: 3),
    //   margin: EdgeInsets.only(left: 24, right: 24, bottom: 24),
    // ));
  }

  static showBottomSheet(String title, String message, Widget? backWidget,
      {Function? yesBtn}) {
    Get.bottomSheet(
        Ui.padding(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.textColor.withOpacity(0.12),
                  child: Center(
                      child: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryColor,
                          child: Center(
                              child: Icon(
                            Iconsax.logout_bold,
                            color: Colors.white,
                          ))))),
              AppText.medium(title, fontSize: 16),
              Ui.boxHeight(8),
              AppText.thin(message, fontSize: 14,alignment: TextAlign.center),
              Ui.boxHeight(24),
              Row(
                children: [
                  Expanded(
                      child: AppButton.outline(() {
                    Get.back();
                  }, "Cancel", color: AppColors.primaryColor)),
                  Ui.boxWidth(16),
                  Expanded(
                      child: AppButton(
                          onPressed: () async {
                            if (yesBtn != null) await yesBtn();
                            if (backWidget != null) {
                              Get.offAll(backWidget);
                            }
                          },
                          text: "Logout")),
                ],
              ),
              Ui.boxHeight(24),
            ],
          ),
        ),
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40))));
  }

  static InputDecoration simpleInputDecoration({
    EdgeInsetsGeometry? contentPadding,
    Color? fillColor,
  }) =>
      InputDecoration(
        border: Ui.outlinedInputBorder(),
        contentPadding: contentPadding,
        fillColor: fillColor,
        errorBorder: Ui.outlinedInputBorder(),
        focusedBorder: Ui.outlinedInputBorder(),
        enabledBorder: Ui.outlinedInputBorder(),
      );

  ///decoration for text fields without a border
  static InputDecoration denseInputDecoration({
    EdgeInsetsGeometry? contentPadding,
    Color fillColor = AppColors.grey,
  }) =>
      InputDecoration(
        border: Ui.denseOutlinedInputBorder(),
        contentPadding: contentPadding,
        fillColor: fillColor,
        filled: true,
        errorBorder: Ui.denseOutlinedInputBorder(),
        focusedErrorBorder: Ui.denseOutlinedInputBorder(),
        focusedBorder: Ui.denseOutlinedInputBorder(),
        enabledBorder: Ui.denseOutlinedInputBorder(),
      );

  static InputBorder outlinedInputBorder({
    double circularRadius = 5,
  }) =>
      OutlineInputBorder(
        borderRadius: Ui.circularRadius(circularRadius),
      );

  static InputBorder denseOutlinedInputBorder({
    double circularRadius = 5,
  }) =>
      OutlineInputBorder(
          borderRadius: Ui.circularRadius(circularRadius),
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 0,
          ));

  static TextStyle simpleInputStyle() => const TextStyle(
        color: AppColors.black,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        fontFamily: Assets.appFontFamily,
      );

  static dynamic backgroundImage(String url) => DecorationImage(
      image:
          url.startsWith("http") ? NetworkImage(url) : Image.asset(url).image);
}
