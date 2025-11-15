import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  Rx<T?> selectedValue = Rx<T?>(null);

  CustomDropdown({
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

  String _getItemText(DropdownMenuItem<T> item) {
    if (item.child is Text) {
      return (item.child as Text).data ?? '';
    }
    return item.value.toString();
  }

  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SearchBottomSheet<T>(
        items: items,
        value: value,
        onChanged: (a) {
          selectedValue.value = a;
          onChanged(a);
        },
        hint: hint,
        fontSize: fontSize,
        fontWeight: fontWeight,
        getItemText: _getItemText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.borderColor;
    final useBottomSheet = items.length > 10;
    selectedValue.value = value;
    return SizedBox(
      width: Ui.width(context) - 32,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label.isNotEmpty)
            Ui.align(child: AppText.medium(label, fontSize: 14)),
          if (label.isNotEmpty) Ui.boxWidth(4),
          Flexible(
            child: useBottomSheet
                ? InkWell(
                    onTap: isEnabled
                        ? () => _showSearchBottomSheet(context)
                        : null,
                    borderRadius: BorderRadius.circular(48),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Obx(() {
                              print(selectedValue.value);
                              return Text(
                                selectedValue.value == null
                                    ? ""
                                    : _getItemText(
                                        items.firstWhere(
                                          (item) =>
                                              item.value == selectedValue.value,
                                        ),
                                      ),
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: fontWeight,

                                  color: AppColors.textColor,
                                ),
                              );
                            }),
                          ),
                          AppIcon(
                            Icons.keyboard_arrow_down_rounded,
                            color: iconColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  )
                : DropdownButtonFormField<T>(
                    value: value,
                    isExpanded: true,

                    isDense: true,
                    icon: AppIcon(
                      Icons.keyboard_arrow_down_rounded,
                      color: iconColor,
                      size: 16,
                    ),
                    alignment: AlignmentDirectional.centerEnd,
                    iconSize: 16,
                    
                    decoration: InputDecoration(
                      fillColor: AppColors.transparent,
                      filled: false,

                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0.0,
                        horizontal: 100,
                      ),
                      // hintText: hint,
                      // hintMaxLines: 1,
                      isDense: true,
                      isCollapsed: true,
                      // hintStyle: TextStyle(
                      //   fontSize: fontSize,
                      //   fontWeight: FontWeight.w400,
                      //   color: borderColor,
                      // ),
                    ),

                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      overflow: TextOverflow.ellipsis,
                      color: AppColors.textColor,
                    ),
                    dropdownColor: AppColors.white,
                    items: isEnabled ? items : [],
                    onChanged: isEnabled ? onChanged : null,
                  ),
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
        return DropdownMenuItem<int>(value: day, child: Text(day.toString()));
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
    final List<int> days = [10, 20, 50, 100];

    return CustomDropdown<int>(
      hint: hint,
      value: selectedValue,
      hasBottomPadding: false,
      items: days.map((day) {
        return DropdownMenuItem<int>(value: day, child: Text(day.toString()));
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
          child: Text(DateFormat("MMMM").format(DateTime(2025, day))),
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
        return DropdownMenuItem<int>(value: day, child: Text(day.toString()));
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
      value: (selectedValue?.isEmpty ?? true) || !cities.contains(
        selectedValue
      ) ? null : selectedValue,
      label: label,
      hasBottomPadding: hasBottomPadding,
      items: cities.map((day) {
        return DropdownMenuItem<String>(
          value: day,
          alignment: AlignmentDirectional.centerEnd,
          child: Text(day.toString(), textAlign: TextAlign.right),
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

class _SearchBottomSheet<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final Function(T?) onChanged;
  final String hint;
  final double fontSize;
  final FontWeight fontWeight;
  final String Function(DropdownMenuItem<T>) getItemText;

  const _SearchBottomSheet({
    required this.items,
    required this.value,
    required this.onChanged,
    required this.hint,
    required this.fontSize,
    required this.fontWeight,
    required this.getItemText,
  });

  @override
  State<_SearchBottomSheet<T>> createState() => _SearchBottomSheetState<T>();
}

class _SearchBottomSheetState<T> extends State<_SearchBottomSheet<T>> {
  late List<DropdownMenuItem<T>> filteredItems;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = widget.items;
      } else {
        filteredItems = widget.items.where((item) {
          final text = widget.getItemText(item).toLowerCase();
          return text.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.hint,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: AppColors.textColor),
                ),
              ],
            ),
          ),
          // Search field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: searchController,
              onChanged: _filterItems,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: AppColors.textColor,
              ),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(
                  fontSize: widget.fontSize,
                  color: AppColors.borderColor,
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.borderColor),
                filled: true,
                fillColor: AppColors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(48),
                  borderSide: BorderSide(color: AppColors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(48),
                  borderSide: BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(48),
                  borderSide: BorderSide(color: AppColors.borderColor),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
          ),
          // Items list
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        color: AppColors.borderColor,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final isSelected = item.value == widget.value;

                      return InkWell(
                        onTap: () {
                          widget.onChanged(item.value);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.borderColor.withOpacity(0.1)
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.getItemText(item),
                                  style: TextStyle(
                                    fontSize: widget.fontSize,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : widget.fontWeight,
                                    color: AppColors.textColor,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  color: AppColors.textColor,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
