import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/app/app_barrel.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/views/admin/drawer.dart';
import 'package:transborder_logistics/src/features/dashboard/views/shared.dart';
import 'package:transborder_logistics/src/global/model/user.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';
import 'package:transborder_logistics/src/global/ui/widgets/fields/custom_dropdown.dart';
import 'package:transborder_logistics/src/global/ui/widgets/fields/custom_textfield.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';

class ResourceHistory<T extends Slugger> {
  String title;
  List<String> filters;
  List<T> items;
  Function(RxList<T>, String)? onFilter;
  Function()? onInit;

  ResourceHistory({
    this.title = "Dashboard",
    this.filters = const ["All"],
    this.items = const [],
    this.onFilter,
    this.onInit,
  });

  Widget toPage({bool hasDrawer = false}) {
    return ResourceHistoryPage<T>(
      title,
      items,
      filters: filters,
      onFilter: onFilter,
      hasDrawer: hasDrawer,
    );
  }
}

class ResourceHistoryPage<T extends Slugger> extends StatefulWidget {
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

class _ResourceHistoryPageState<T extends Slugger>
    extends State<ResourceHistoryPage<T>> {
  RxString curFilter = "All".obs;
  final tec = TextEditingController();
  RxList<T> allItems = <T>[].obs;

  @override
  void initState() {
    allItems.value = List.from(widget.items);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ResourceHistoryPage<T> oldWidget) {
    if (oldWidget.title != widget.title) {
      allItems.value = List.from(widget.items);
      curFilter.value = "All";
      tec.clear();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        if (widget.onFilter == null && widget.filters.isEmpty)
          Align(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
              child: AppText.bold("Ongoing Trips"),
            ),
            alignment: Alignment.centerLeft,
          ),
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
              if (widget.items.isEmpty) {
                return;
              }
              allItems.value = widget.items.where((test) {
                final tg = test as Slugger;
                return tg.slug.toLowerCase().contains(tec.text.toLowerCase());
              }).toList();
            },
            prefix: HugeIcons.strokeRoundedSearch02,
          ),
        ),
        if (widget.onFilter != null)
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
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Obx(() {
              return AppText.thin(
                "Showing ${allItems.length} results",
                fontSize: 10,
                color: AppColors.lightTextColor,
              );
            }),
          ),
        ),
        Expanded(
          child: Obx(() {
            return ListView.separated(
              itemBuilder: (c, i) {
                if (allItems[i].runtimeType == Delivery) {
                  return DeliveryInfo(allItems[i] as Delivery);
                }
                if (allItems[i].runtimeType == User &&
                    widget.title.toLowerCase() == "drivers") {
                  return DriverInfo(allItems[i] as User);
                }
                if (allItems[i].runtimeType == User &&
                    widget.title.toLowerCase() == "users") {
                  return UserInfo(allItems[i] as User);
                }
                if (allItems[i].runtimeType == Location) {
                  return LocationInfo(allItems[i] as Location);
                }
                if (allItems[i].runtimeType == StateLocation) {
                  return StateInfo(allItems[i] as StateLocation);
                }
                if (allItems[i].runtimeType == Vehicle) {
                  return VehicleInfo(allItems[i] as Vehicle);
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
    );

    if (widget.hasDrawer) {
      return body;
    }

    return SinglePageScaffold(title: widget.title, child: body);
  }
}

class ResourceHistoryDesktopPage<T extends Slugger> extends StatefulWidget {
  const ResourceHistoryDesktopPage(
    this.title,
    this.items, {
    this.filters = const ["All"],
    this.onFilter,
    this.onInit,
    this.onAdd,
    this.onEdit,
    this.onDelete,
    super.key,
    this.hasDrawer = false,
  });
  final String title;
  final List<String> filters;
  final List<T> items;
  final bool hasDrawer;
  final Function(RxList<T>, String)? onFilter;
  final Function()? onInit, onAdd;
  final Function(dynamic)? onEdit;
  final Function(dynamic)? onDelete;

  @override
  State<ResourceHistoryDesktopPage<T>> createState() =>
      _ResourceHistoryDesktopPageState<T>();
}

class _ResourceHistoryDesktopPageState<T extends Slugger>
    extends State<ResourceHistoryDesktopPage<T>> {
  RxString curFilter = "All".obs;
  final tec = TextEditingController();
  RxList<T> allItems = <T>[].obs;
  final controller = Get.find<DashboardController>();

  @override
  void initState() {
    allItems.value = List.from(widget.items);
    controller.curFilters.listen((v) {
      if (v.isEmpty) {
        curFilter.value = "All";
        allItems.value = List.from(widget.items);
      } else {
        allItems.value = widget.items.where((test) {
          final tg = test as Slugger;
          return v.every(
            (test) => test.any(
              (test2) => tg.slug.toLowerCase().contains(test2.toLowerCase()),
            ),
          );
        }).toList();
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ResourceHistoryDesktopPage<T> oldWidget) {
    if (oldWidget.title != widget.title || oldWidget.items != widget.items) {
      allItems.value = List.from(widget.items);
      curFilter.value = "All";
      controller.curFilters.value = [];
      tec.clear();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      border: Border.all(color: AppColors.borderColor),
      radius: 0,
      child: Column(
        children: [
          //App Header
          AppDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            child: detailHeader(),
          ),
          AppDivider(),
          Expanded(
            child: CurvedContainer(
              radius: 12,
              border: Border.all(color: AppColors.borderColor),
              margin: EdgeInsets.all(16),
              child: Builder(
                builder: (context) {
                  return Obx(() {
                    print(allItems.length);
                    return controller.currentModelIndex.value != 0
                        ? ResourceHistoryItemDetail(
                            controller.currentModel.value.fields,
                            rtitle: widget.title,
                          )
                        : ResourceHistoryTable(
                            allItems: allItems,
                            rtitle: widget.title,
                          );
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  tableHeader() {
    return Row(
      children: [
        AppText.medium(widget.title, fontSize: 18),
        Spacer(),
        CurvedContainer(
          border: Border.all(color: AppColors.borderColor),
          color: Color(0xfff7f7f7),
          width: Ui.width(context) * 0.25,
          radius: 24,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
              if (widget.items.isEmpty) {
                return;
              }
              allItems.value = widget.items.where((test) {
                final tg = test as Slugger;
                return tg.slug.toLowerCase().contains(tec.text.toLowerCase());
              }).toList();
            },
            prefix: HugeIcons.strokeRoundedSearch02,
          ),
        ),
        if (widget.title != "Location")
          Obx(() {
            return badgeBox(
              CurvedContainer(
                onPressed: () {
                  if (widget.items.isEmpty) {
                    return;
                  }

                  Get.bottomSheet(
                    FilterResource(widget.title, obj: widget.items),
                    isScrollControlled: true,
                  );
                },
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                border: Border.all(color: AppColors.borderColor),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(HugeIcons.strokeRoundedFilterHorizontal, size: 16),
                    Ui.boxWidth(8),
                    AppText.medium("Filter", fontSize: 14),
                  ],
                ),
              ),
              onTap: () {
                curFilter.value = "All";
                allItems.value = List.from(widget.items);

                controller.curFilters.value = [];
                return;
              },
              a: Alignment.topRight,
              shdShow: controller.curFilters.isNotEmpty,
            );
          }),
        Ui.boxWidth(12),
        CurvedContainer(
          onPressed: () async {
            await controller.exportData(items: List.from(allItems));
          },
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          border: Border.all(color: AppColors.borderColor),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(HugeIcons.strokeRoundedDownload01, size: 16),
              Ui.boxWidth(8),
              AppText.medium("Export", fontSize: 14),
            ],
          ),
        ),
        Ui.boxWidth(12),
        if (widget.title != "Location")
          CurvedContainer(
            onPressed: () {
              if (widget.onAdd != null) {
                widget.onAdd!();
              }
            },
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
            color: AppColors.primaryColor,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(
                  HugeIcons.strokeRoundedAdd01,
                  size: 16,
                  color: AppColors.white,
                ),
                Ui.boxWidth(8),
                AppText.medium(
                  "Add ${widget.title}",
                  fontSize: 14,
                  color: AppColors.white,
                ),
              ],
            ),
          ),
      ],
    );
  }

  detailHeader() {
    return Obx(() {
      return controller.currentModelIndex.value == 0
          ? tableHeader()
          : Row(
              children: [
                InkWell(
                  onTap: () {
                    controller.currentModelIndex.value = 0;
                  },
                  child: AppText.medium(widget.title, fontSize: 18),
                ),
                AppText.medium(
                  "  > ",
                  fontSize: 18,
                  color: AppColors.lightTextColor,
                ),
                Obx(() {
                  return AppText.medium(
                    controller.currentModel.value.rawId,
                    fontSize: 16,
                    color: AppColors.lightTextColor,
                  );
                }),
                Spacer(),
                CurvedContainer(
                  onPressed: () {
                    if (widget.onEdit != null) {
                      widget.onEdit!(controller.currentModel.value);
                    }
                  },
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                  border: Border.all(color: AppColors.borderColor),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(HugeIcons.strokeRoundedPencilEdit01, size: 16),
                      Ui.boxWidth(8),
                      AppText.medium("Edit", fontSize: 14),
                    ],
                  ),
                ),

                Ui.boxWidth(12),
                if (controller
                    .appRepo
                    .appService
                    .currentUser
                    .value
                    .isSuperAdmin)
                  CurvedContainer(
                    onPressed: () {
                      if (widget.onDelete != null) {
                        widget.onDelete!(controller.currentModel.value);
                      }
                    },
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                    color: AppColors.primaryColor,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          HugeIcons.strokeRoundedDelete02,
                          size: 16,
                          color: AppColors.white,
                        ),
                        Ui.boxWidth(8),
                        AppText.medium(
                          "Delete",
                          fontSize: 14,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
              ],
            );
    });
  }
}

class ResourceHistoryRowItem extends StatelessWidget {
  const ResourceHistoryRowItem({
    super.key,
    this.isHeader = false,
    this.isFooter = false,
    this.children = const [],
    this.footer,
  });
  final bool isHeader;
  final bool isFooter;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: isHeader ? Radius.circular(12) : Radius.zero,
          bottomRight: isFooter ? Radius.circular(12) : Radius.zero,
          topLeft: isHeader ? Radius.circular(12) : Radius.zero,
          bottomLeft: isFooter ? Radius.circular(12) : Radius.zero,
        ),
        border: Border(
          top: isFooter
              ? BorderSide(color: AppColors.borderColor)
              : BorderSide.none,
          bottom: isFooter
              ? BorderSide.none
              : BorderSide(color: AppColors.borderColor),
        ),
        color: isHeader ? Color(0xfff7f7f7) : AppColors.white,
      ),
      child: isFooter
          ? footer
          : Row(children: children.map((e) => Expanded(child: e)).toList()),
    );
  }
}

class ResourceHistoryFooter extends StatelessWidget {
  const ResourceHistoryFooter({
    super.key,
    this.currentPage = 1,
    this.totalPages = 10,
    this.pageSize = 10,
    this.onNext,
    this.onPrevious,
    this.onChanged,
  });
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final VoidCallback? onNext, onPrevious;
  final Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText.thin(
          "Page $currentPage of $totalPages",
          fontSize: 14,
          color: AppColors.lightTextColor,
        ),

        Ui.boxWidth(24),
        SizedBox(
          width: 48,
          child: DropdownButton<String>(
            value: pageSize.toString(),
            underline: SizedBox(),

            items: ["10", "20", "50", "100"]
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: AppText.thin(
                      e.toString(),
                      fontSize: 14,
                      color: AppColors.lightTextColor,
                    ),
                  ),
                )
                .toList(),
            icon: AppIcon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.lightTextColor,
              size: 16,
            ),
            onChanged: onChanged ?? (v) {},
          ),
        ),
        Spacer(),
        CurvedContainer(
          onPressed: onPrevious,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          border: Border.all(color: AppColors.borderColor),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(HugeIcons.strokeRoundedArrowLeft03, size: 16),
              Ui.boxWidth(8),
              AppText.medium("Previous", fontSize: 14),
            ],
          ),
        ),
        Ui.boxWidth(24),
        CurvedContainer(
          onPressed: onNext,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          border: Border.all(color: AppColors.borderColor),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.medium("Next", fontSize: 14),

              Ui.boxWidth(8),
              AppIcon(HugeIcons.strokeRoundedArrowRight03, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class ResourceHistoryTable<T extends Slugger> extends StatelessWidget {
  ResourceHistoryTable({this.allItems = const [], this.rtitle = "", super.key});
  final List<T> allItems;
  final String rtitle;
  List<T> pageRawItems = [];
  List<List<String>> items = [];
  RxInt curPage = 1.obs;
  RxInt curIndex = 0.obs;
  RxInt totalPage = 10.obs;
  RxInt curPageSize = 10.obs;
  RxList<List<String>> pageItems = <List<String>>[].obs;

  paginate() {
    curPage.value = curIndex.value + 1;
    int start = (curIndex.value * curPageSize.value);
    int end = (curIndex.value * curPageSize.value) + curPageSize.value;
    end = end > items.length ? items.length : end;
    pageItems.value = items.sublist(start, end);
    pageRawItems = allItems.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    items = allItems.map((e) => (e as Slugger).tableValue).toList();
    List<String> title = allItems.isEmpty
        ? []
        : (allItems[0] as Slugger).tableTitle;
    if (title.isEmpty) {
      return Center(child: AppText.thin("No Record Found !!!"));
    }

    title[0] = title[0].toLowerCase() == "id" ? "$rtitle ID" : title[0];
    if (rtitle == "Drivers") {
      title[2] = "Status";
      for (var b in items) {
        b[2] =
            Get.find<DashboardController>().allUnavailableDrivers
                .map((driver) => driver.id.toString())
                .contains(b[0])
            ? "Busy"
            : "Available";
      }
    }

    totalPage.value = (items.length / curPageSize.value).ceil();
    paginate();

    return Column(
      children: [
        ResourceHistoryRowItem(
          isHeader: true,
          children: List.generate(title.length, (i) {
            return AppText.medium(
              title[i],
              fontSize: 14,
              color: AppColors.lightTextColor,
              alignment: TextAlign.center,
              maxlines: 2,
            );
          }),
        ),
        Expanded(
          child: Obx(() {
            return ListView.builder(
              itemCount: pageItems.length,
              itemBuilder: (c, i) {
                return InkWell(
                  onTap: () {
                    Get.find<DashboardController>().currentModel.value =
                        pageRawItems[i];
                    Get.find<DashboardController>().currentModelIndex.value = 1;
                  },
                  child: ResourceHistoryRowItem(
                    children: List.generate(pageItems[i].length, (j) {
                      return Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 4),
                        child: Builder(
                          builder: (c) {
                            if (title[j] == "Status") {
                              return rtitle == "Trips"
                                  ? WaybillStatusChip(pageItems[i][j])
                                  : DriverStatusChip(pageItems[i][j]);
                            }
                            return AppText.thin(
                              pageItems[i][j].isEmpty ? "N/A" : pageItems[i][j],
                              fontSize: 12,
                              color: AppColors.lightTextColor,
                              alignment: TextAlign.center,
                              maxlines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      );
                    }),
                  ),
                );
              },
            );
          }),
        ),
        ResourceHistoryRowItem(
          isFooter: true,
          footer: Obx(() {
            return ResourceHistoryFooter(
              currentPage: curPage.value,
              totalPages: totalPage.value,
              pageSize: curPageSize.value,
              onNext: () {
                if (curPage.value < totalPage.value) {
                  curIndex.value++;
                  paginate();
                }
              },
              onPrevious: () {
                if (curIndex.value > 0) {
                  curIndex.value--;
                  paginate();
                }
              },
              onChanged: (v) {
                final b = int.parse(v ?? "10");
                curPageSize.value = b;
                paginate();
              },
            );
          }),
        ),
      ],
    );
  }
}

class ResourceHistoryItemDetail extends StatelessWidget {
  const ResourceHistoryItemDetail(this.fields, {this.rtitle = "", super.key});
  final Map<String, String> fields;
  final String rtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppText.medium(
            "INFO",
            color: AppColors.lightTextColor,
            fontSize: 14,
          ),
        ),
        CurvedContainer(
          radius: 12,
          border: Border.all(color: AppColors.borderColor),
          margin: EdgeInsets.only(bottom: 16, right: 16, left: 16),
          padding: EdgeInsets.all(16),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 6,
            mainAxisSpacing: 12,
            crossAxisSpacing: 24,
            children: List.generate(fields.length, (i) {
              return SizedBox(
                height: 32,
                child: Column(
                  crossAxisAlignment: i % 3 == 0
                      ? CrossAxisAlignment.start
                      : i % 3 == 1
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText.thin(
                      fields.keys.elementAt(i),
                      fontSize: 12,
                      color: AppColors.lightTextColor,
                    ),
                    Ui.boxHeight(4),
                    if (![
                      "inactive",
                      "active",
                      "new",
                      "available"
                          "completed",
                      "track",
                      "cancelled",
                      "in progress",
                    ].contains(fields.values.elementAt(i).toLowerCase()))
                      AppText.thin(
                        fields.values.elementAt(i).isEmpty
                            ? "N/A"
                            : fields.values.elementAt(i),
                        fontSize: 14,
                        maxlines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    if ([
                      "inactive",
                      "active",
                      "new",
                      "available"
                          "completed",
                      "track",
                      "cancelled",
                      "in progress",
                    ].contains(fields.values.elementAt(i).toLowerCase()))
                      SizedBox(
                        width: 150,
                        child: rtitle == "Trips"
                            ? WaybillStatusChip(fields.values.elementAt(i))
                            : DriverStatusChip(fields.values.elementAt(i)),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
        if (rtitle == "Trips")
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 200,
                child: AppButton(
                  onPressed: () {
                    Get.to(
                      WaybillDetailPage(
                        Get.find<DashboardController>().currentModel.value
                            as Delivery,
                      ),
                    );
                  },
                  text: "Share",
                ),
              ),
            ),
          ),
      ],
    );
  }
}
