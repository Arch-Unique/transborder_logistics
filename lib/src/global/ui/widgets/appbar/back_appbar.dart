import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/src/app/app_barrel.dart';
import '/src/global/ui/ui_barrel.dart';

AppBar backAppBar(
    {String? title,
    Widget? titleWidget,
    Color color = AppColors.textColor,
    Color bgColor = AppColors.transparent,
    bool hasBack = true,
    List<Widget>? trailing}) {
  return AppBar(
      toolbarHeight: 72,
      backgroundColor: bgColor,
      title: title == null
          ? titleWidget
          : AppText.medium(title, fontSize: 16, color: color),
      elevation: 0,
      // shadowColor: Color(0xFFE80976).withOpacity(0.05),
      centerTitle: true,
      actions: trailing ?? [],
      leadingWidth: hasBack ? 56 : 28,
      leading: hasBack
          ? Builder(builder: (context) {
              return IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: color,
                  ));
            })
          : SizedBox());
}
