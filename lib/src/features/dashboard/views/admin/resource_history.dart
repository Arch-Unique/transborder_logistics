import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/app/app_barrel.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/drawer.dart';
import 'package:transborder_logistics/src/features/dashboard/views/shared.dart';
import 'package:transborder_logistics/src/global/model/user.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';
import 'package:transborder_logistics/src/global/ui/widgets/fields/custom_textfield.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';

class ResourceHistoryPage<T> extends StatefulWidget {
  const ResourceHistoryPage(
    this.title,
    this.items, {
    this.filters = const ["All"],
    this.onFilter,
    this.onInit,
    super.key,
    this.hasDrawer = false,
  });
  final String title;
  final List<String> filters;
  final List<T> items;
  final bool hasDrawer;
  final Function(RxList<T>, String)? onFilter;
  final Function()? onInit;

  @override
  State<ResourceHistoryPage<T>> createState() => _ResourceHistoryPageState<T>();
}

class _ResourceHistoryPageState<T> extends State<ResourceHistoryPage<T>> {
  RxString curFilter = "All".obs;
  final tec = TextEditingController();
  RxList<T> allItems = <T>[].obs;

  @override
  void initState() {
    allItems.value = List.from(widget.items);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SinglePageScaffold(
      title: widget.title,
      drawer: widget.hasDrawer ? AppDrawer() : null,
      hasBack: !widget.hasDrawer,
      trailing: [
        InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColors.primaryColor,
              radius: 10,
              child: Center(
                child: AppIcon(
                  HugeIcons.strokeRoundedAdd01,
                  size: 16,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ],
      child: Column(
        children: [
          CurvedContainer(
            border: Border.all(color: AppColors.borderColor),
            color: Color(0xfff7f7f7),
            radius: 12,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: CustomTextField(
              "Search",
              tec,
              textAlign: TextAlign.start,
              customOnChanged: () {
                if (tec.text.isEmpty) {
                  curFilter.value = "All";
                  allItems.value = List.from(widget.items);
                  return;
                }
                if (T == Delivery) {
                  allItems.value = widget.items.where((test) {
                    final tg = test as Delivery;
                    return tg.slug.toLowerCase().contains(
                      tec.text.toLowerCase(),
                    );
                  }).toList();
                } else if (T == User) {
                  allItems.value = widget.items.where((test) {
                    final tg = test as User;
                    return tg.slug.toLowerCase().contains(
                      tec.text.toLowerCase(),
                    );
                  }).toList();
                }
              },
              prefix: HugeIcons.strokeRoundedSearch02,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: widget.filters.map((e) {
                return Obx(() {
                  return CurvedContainer(
                    color: e == curFilter.value
                        ? AppColors.primaryColor
                        : AppColors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    radius: 8,
                    onPressed: () {
                      curFilter.value = e;
                      if (e == "All") {
                        allItems.value = List.from(widget.items);
                        return;
                      }
                      if (widget.onFilter != null) {
                        widget.onFilter!(allItems, e);
                      }
                    },
                    child: AppText.medium(
                      e,
                      fontSize: 14,
                      color: e == curFilter.value
                          ? AppColors.white
                          : AppColors.lightTextColor,
                    ),
                  );
                });
              }).toList(),
            ),
          ),
          Expanded(
            child: Obx(() {
              return ListView.separated(
                itemBuilder: (c, i) {
                  if (T == Delivery) {
                    return DeliveryInfo(allItems[i] as Delivery);
                  }
                  if (T == User) {
                    return DriverInfo(allItems[i] as User);
                  }
                  return SizedBox();
                },
                separatorBuilder: (c, i) {
                  return Ui.boxHeight(0);
                },
                itemCount: allItems.length,
              );
            }),
          ),
        ],
      ),
    );
  }
}
