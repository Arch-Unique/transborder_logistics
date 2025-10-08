import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/src/src_barrel.dart';
import '../../ui_barrel.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String hint, label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final Color iconColor;
  final double fontSize;
  final FontWeight fontWeight;
  final bool hasBottomPadding;
  final bool isEnabled;

  const CustomDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
    this.label = "",
    this.iconColor = AppColors.textColor,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w300,
    this.hasBottomPadding = true,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.borderColor;
    return SizedBox(
      width: Ui.width(context) - 32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Ui.align(
              child: AppText.medium(label, fontSize: 14),
            ),
          if (label.isNotEmpty) Ui.boxHeight(4),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(48),
              border: Border.all(color: borderColor),
            ),
            child: DropdownButtonFormField<T>(
              value: value,
              isExpanded: true,
              icon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: AppIcon(Icons.keyboard_arrow_down_rounded,
                    color: iconColor),
              ),
              
              decoration: InputDecoration(
                fillColor: AppColors.transparent,
                filled: false,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
                hintText: hint,
                hintMaxLines: 1,
                
                hintStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                  color: borderColor,
                ),
              ),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: AppColors.textColor,
              ),
              dropdownColor: AppColors.white,
              items: isEnabled ? items : [],
              onChanged: isEnabled ? onChanged : null,
            ),
          ),
          SizedBox(
            height: hasBottomPadding ? 24 : 0,
          ),
        ],
      ),
    );
  }

  // Factory constructor for number of days dropdown
  static CustomDropdown<int> days({
    required String hint,
    required int? selectedValue,
    required Function(int?) onChanged,
    String label = "Number of questions",
    bool hasBottomPadding = true,
  }) {
    // Generate days from 1 to 10 (can be adjusted as needed)
    final List<int> days = List.generate(10, (index) => index + 1);

    return CustomDropdown<int>(
      hint: hint,
      value: selectedValue,
      label: label,
      hasBottomPadding: hasBottomPadding,
      items: days.map((day) {
        return DropdownMenuItem<int>(
          value: day,
          child: Text(day.toString()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // Factory constructor for number of days dropdown
  static CustomDropdown<int> rows({
    required String hint,
    required int? selectedValue,
    required Function(int?) onChanged,
  }) {
    // Generate days from 1 to 30 (can be adjusted as needed)
    final List<int> days = [10,20,50,100];

    return CustomDropdown<int>(
      hint: hint,
      value: selectedValue,
      hasBottomPadding: false,
      items: days.map((day) {
        return DropdownMenuItem<int>(
          value: day,
          child: Text(day.toString()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
    
    
    static CustomDropdown<int> months({
    required String hint,
    required int? selectedValue,
    required Function(int?) onChanged,
    bool hasBottomPadding = true,
  }) {
    // Generate days from 1 to 30 (can be adjusted as needed)
    final List<int> days = List.generate(12, (index) => index + 1);

    return CustomDropdown<int>(
      hint: hint,
      value: selectedValue,
      hasBottomPadding: hasBottomPadding,
      items: days.map((day) {
        return DropdownMenuItem<int>(
          value: day,
          child: Text(DateFormat("MMMM").format(DateTime(2025,day))),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

      static CustomDropdown<int> years({
    required String hint,
    required int? selectedValue,
    required Function(int?) onChanged,
    bool hasBottomPadding = true,
  }) {
    // Generate days from 1 to 30 (can be adjusted as needed)
    final List<int> days = List.generate(50, (index) => index + 2025);

    return CustomDropdown<int>(
      hint: hint,
      value: selectedValue,
      hasBottomPadding: hasBottomPadding,
      items: days.map((day) {
        return DropdownMenuItem<int>(
          value: day,
          child: Text(day.toString()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // Factory constructor for city dropdown
  static CustomDropdown<String> city({
    required String hint,
    required String? selectedValue,
    required Function(String?) onChanged,
    required List<String> cities,
    String label = "Number of Days",
    bool hasBottomPadding = true,
  }) {

    return CustomDropdown<String>(
      hint: hint,
      value: selectedValue,
      label: label,
      hasBottomPadding: hasBottomPadding,
      items: cities.map((day) {
        return DropdownMenuItem<String>(
          value: day,
          child: Text(day.toString()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // Factory constructor for phone country code dropdown
  static CustomDropdown<String> phoneCountryCode({
    required String? selectedValue,
    required Function(String?) onChanged,
    bool hasBottomPadding = true,
  }) {
    // You can add more country codes as needed
    final countryCodes = [
      {'name': 'United States', 'code': '+1', 'flag': '🇺🇸'},
      {'name': 'Nigeria', 'code': '+234', 'flag': '🇳🇬'},
      {'name': 'United Kingdom', 'code': '+44', 'flag': '🇬🇧'},
      {'name': 'Canada', 'code': '+1', 'flag': '🇨🇦'},
      {'name': 'Ghana', 'code': '+233', 'flag': '🇬🇭'},
    ];

    return CustomDropdown<String>(
      hint: "+1",
      value: selectedValue,
      hasBottomPadding: hasBottomPadding,
      items: countryCodes.map((country) {
        return DropdownMenuItem<String>(
          value: country['code'],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(country['flag']!),
              SizedBox(width: 4),
              Text(country['code']!, style: TextStyle(fontSize: 14)),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
