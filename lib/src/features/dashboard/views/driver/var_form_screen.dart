import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/var_controller.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';
import 'package:transborder_logistics/src/src_barrel.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VarPopupForm — shown as a bottom sheet after End Trip confirmation.
//
// Usage:
//   controller.initFromDelivery(delivery, currentUser.id);
//   Get.bottomSheet(VarPopupForm(), isScrollControlled: true);
// ─────────────────────────────────────────────────────────────────────────────

class VarPopupForm extends StatelessWidget {
  VarPopupForm({super.key});

  final controller = Get.find<VarController>();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.93,
      maxChildSize: 0.97,
      minChildSize: 0.5,
      expand: false,
      builder: (ctx, scrollController) {
        return CurvedContainer(
          radius: 20,
          color:
              Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              // ── Drag handle ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: CurvedContainer(
                  radius: 4,
                  color: AppColors.borderColor,
                  width: 40,
                  height: 4,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    AppIcon(HugeIcons.strokeRoundedDocumentCode,
                        size: 18, color: AppColors.primaryColor),
                    Ui.boxWidth(8),
                    AppText.semiBold('Vaccine Arrival Report', fontSize: 14),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: AppIcon(HugeIcons.strokeRoundedCancel01,
                          size: 20, color: AppColors.lightTextColor),
                    ),
                  ],
                ),
              ),
              AppDivider(),

              // ── Scrollable content ────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Trip context banner ───────────────────────────────
                      _TripContextBanner(controller: controller),
                      Ui.boxHeight(12),

                      // ── Trip Details (driver input) ───────────────────────
                      _Section(
                        title: 'Trip Details',
                        icon: HugeIcons.strokeRoundedRoute03,
                        children: [
                          _DatePickerRow(
                              'Date of Arrival', controller.dateOfArrival, context),
                          _FieldRow('Job Order No.', controller.jobOrderNo,
                              hint: 'e.g. JO-001'),
                        ],
                      ),
                      Ui.boxHeight(12),

                      // ── Cold Chain Details ────────────────────────────────
                      _Section(
                        title: 'Cold Chain Details',
                        icon: HugeIcons.strokeRoundedThermometer,
                        children: [
                          _TempRangeToggle(controller),
                        ],
                      ),
                      Ui.boxHeight(12),

                      // ── Commodity Details ─────────────────────────────────
                      _DynamicSection<List<TextEditingController>>(
                        title: 'Commodity Details',
                        icon: HugeIcons.strokeRoundedMedicineBottle01,
                        rows: controller.commodityRows,
                        onAdd: controller.addCommodityRow,
                        onRemove: controller.removeCommodityRow,
                        rowBuilder: (row, i) => _CommodityRowCard(
                            row: row, index: i, controller: controller),
                        emptyLabel: 'No commodity added yet',
                      ),
                      Ui.boxHeight(12),

                      // ── Temperature Monitoring ────────────────────────────
                      _DynamicSection<List<TextEditingController>>(
                        title: 'Temperature Monitoring Record',
                        icon: HugeIcons.strokeRoundedTemperature,
                        rows: controller.tempRows,
                        onAdd: controller.addTempRow,
                        onRemove: controller.removeTempRow,
                        rowBuilder: (row, i) => _TempRowCard(
                            row: row, index: i, controller: controller),
                        emptyLabel: 'No temperature record added yet',
                      ),
                      Ui.boxHeight(12),

                      // ── Reverse Logistics ─────────────────────────────────
                      _ReverseLogisticsSection(controller),
                      Ui.boxHeight(12),

                      // ── Sign-Off ──────────────────────────────────────────
                      _Section(
                        title: 'Sign-Off',
                        icon: HugeIcons.strokeRoundedSignature,
                        children: [
                          _FieldRow('Dispatched By', controller.dispatchedBy,
                              hint: 'Name'),
                          _FieldRow('Delivered By', controller.deliveredBy,
                              hint: 'Driver name'),
                          _FieldRow('Received By', controller.receivedBy,
                              hint: 'Name'),
                        ],
                      ),
                      Ui.boxHeight(24),
                      AppButton(
                        onPressed: controller.goToReview,
                        text: 'Review VAR',
                      ),
                      Ui.boxHeight(32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trip context banner — shows read-only trip summary at the top of the form
// ─────────────────────────────────────────────────────────────────────────────

class _TripContextBanner extends StatelessWidget {
  const _TripContextBanner({required this.controller});
  final VarController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final delivery = controller.activeDelivery.value;

      // Waybill / ID header
      final waybillLabel = delivery != null ? '#${delivery.waybill}' : '—';

      // Origin: pickup field on the delivery
      final originLabel =
          (delivery?.pickup?.isNotEmpty ?? false) ? delivery!.pickup! : '—';

      // Destination: all stops joined with " - "
      final destLabel = (delivery?.stops.isNotEmpty ?? false)
          ? delivery!.stops.join(' - ')
          : '—';

      // Driver: name string from the delivery join
      final driverLabel =
          (delivery?.driver?.isNotEmpty ?? false) ? delivery!.driver! : '—';

      // Vehicle: truck registration from the delivery
      final vehicleLabel =
          (delivery?.truckno?.isNotEmpty ?? false) ? delivery!.truckno! : '—';

      return CurvedContainer(
        radius: 10,
        color: AppColors.primaryColor.withOpacity(0.06),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              AppIcon(HugeIcons.strokeRoundedContainerTruck01,
                  size: 14, color: AppColors.primaryColor),
              Ui.boxWidth(6),
              AppText.semiBold('Trip Context',
                  fontSize: 11, color: AppColors.primaryColor),
              const Spacer(),
              AppText.thin(waybillLabel,
                  fontSize: 11, color: AppColors.primaryColor),
            ]),
            Ui.boxHeight(8),
            _ContextRow('Driver', driverLabel),
            _ContextRow('Vehicle', vehicleLabel),
            _ContextRow('Origin', originLabel),
            _ContextRow('Destination', destLabel),
          ],
        ),
      );
    });
  }
}

class _ContextRow extends StatelessWidget {
  const _ContextRow(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: AppText.medium(label,
                fontSize: 10, color: AppColors.lightTextColor),
          ),
          Expanded(
            child: AppText.thin(value.isEmpty ? '—' : value,
                fontSize: 11, color: AppColors.textColor,
                maxlines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────


class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final dynamic icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      border: Border.all(color: AppColors.borderColor),
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            AppIcon(icon, size: 16, color: AppColors.primaryColor),
            Ui.boxWidth(8),
            AppText.semiBold(title, fontSize: 13),
          ]),
          AppDivider(),
          ...children,
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow(this.label, this.controller, {this.hint = ''});
  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 84,
            child: AppText.medium(label,
                fontSize: 11, color: AppColors.lightTextColor),
          ),
          Expanded(
            child: CurvedContainer(
              radius: 8,
              border: Border.all(color: AppColors.borderColor),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: TextField(
                controller: controller,
                style: TextStyle(fontSize: 12, color: AppColors.textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: hint,
                  hintStyle: TextStyle(
                      fontSize: 11, color: AppColors.lightTextColor),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  const _DatePickerRow(this.label, this.controller, this.context);
  final String label;
  final TextEditingController controller;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 84,
            child: AppText.medium(label,
                fontSize: 11, color: AppColors.lightTextColor),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2040),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: ColorScheme.light(
                          primary: AppColors.primaryColor),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  controller.text =
                      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                }
              },
              child: CurvedContainer(
                radius: 8,
                border: Border.all(color: AppColors.borderColor),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: controller,
                        builder: (_, val, __) => AppText.thin(
                          val.text.isEmpty ? 'YYYY-MM-DD' : val.text,
                          fontSize: 12,
                          color: val.text.isEmpty
                              ? AppColors.lightTextColor
                              : AppColors.textColor,
                        ),
                      ),
                    ),
                    AppIcon(HugeIcons.strokeRoundedCalendar01,
                        size: 16, color: AppColors.lightTextColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TempRangeToggle extends StatelessWidget {
  const _TempRangeToggle(this.controller);
  final VarController controller;

  static const _options = ['+2°C to +8°C', '-15°C to -25°C'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium('Required Temp. Range',
              fontSize: 11, color: AppColors.lightTextColor),
          Ui.boxHeight(8),
          Obx(() => Row(
                children: _options.map((opt) {
                  final selected = controller.temperatureRange.value == opt;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.temperatureRange.value = opt,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin:
                            EdgeInsets.only(right: opt == _options.first ? 8 : 0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryColor
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected
                                ? AppColors.primaryColor
                                : AppColors.borderColor,
                          ),
                        ),
                        child: Center(
                          child: AppText.medium(
                            opt,
                            fontSize: 11,
                            color: selected
                                ? AppColors.white
                                : AppColors.textColor,
                            alignment: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }
}

// ── Dynamic sections ──────────────────────────────────────────────────────────

class _DynamicSection<T> extends StatelessWidget {
  const _DynamicSection({
    required this.title,
    required this.icon,
    required this.rows,
    required this.onAdd,
    required this.onRemove,
    required this.rowBuilder,
    required this.emptyLabel,
  });
  final String title;
  final dynamic icon;
  final RxList<T> rows;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final Widget Function(T row, int index) rowBuilder;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      border: Border.all(color: AppColors.borderColor),
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            AppIcon(icon, size: 16, color: AppColors.primaryColor),
            Ui.boxWidth(8),
            AppText.semiBold(title, fontSize: 13),
            const Spacer(),
            GestureDetector(
              onTap: onAdd,
              child: CurvedContainer(
                radius: 20,
                color: AppColors.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  AppIcon(HugeIcons.strokeRoundedAdd01,
                      size: 14, color: AppColors.white),
                  Ui.boxWidth(4),
                  AppText.medium('Add Row',
                      fontSize: 11, color: AppColors.white),
                ]),
              ),
            ),
          ]),
          AppDivider(),
          Obx(() {
            if (rows.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: AppText.thin(emptyLabel,
                      fontSize: 12, color: AppColors.lightTextColor),
                ),
              );
            }
            return Column(
              children:
                  rows.asMap().entries.map((e) => rowBuilder(e.value, e.key)).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _CommodityRowCard extends StatelessWidget {
  const _CommodityRowCard(
      {required this.row, required this.index, required this.controller});
  final List<TextEditingController> row;
  final int index;
  final VarController controller;

  @override
  Widget build(BuildContext context) {
    const labels = [
      'Vaccine/Item',
      'Batch No.',
      'Expiry Date',
      'Qty Dispatched',
      'Qty Received',
      'VVM Status'
    ];
    return CurvedContainer(
      border: Border.all(color: AppColors.borderColor),
      radius: 8,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppText.medium('Row ${index + 1}',
                  fontSize: 11, color: AppColors.lightTextColor),
              const Spacer(),
              GestureDetector(
                onTap: () => controller.removeCommodityRow(index),
                child: AppIcon(HugeIcons.strokeRoundedDelete01,
                    size: 16, color: AppColors.red),
              ),
            ],
          ),
          Ui.boxHeight(6),
          ...List.generate(6, (i) => _MiniField(labels[i], row[i])),
        ],
      ),
    );
  }
}

class _TempRowCard extends StatelessWidget {
  const _TempRowCard(
      {required this.row, required this.index, required this.controller});
  final List<TextEditingController> row;
  final int index;
  final VarController controller;

  @override
  Widget build(BuildContext context) {
    const labels = ['Monitoring Point', 'Temperature (°C)', 'Date/Time'];
    return CurvedContainer(
      border: Border.all(color: AppColors.borderColor),
      radius: 8,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppText.medium('Record ${index + 1}',
                  fontSize: 11, color: AppColors.lightTextColor),
              const Spacer(),
              GestureDetector(
                onTap: () => controller.removeTempRow(index),
                child: AppIcon(HugeIcons.strokeRoundedDelete01,
                    size: 16, color: AppColors.red),
              ),
            ],
          ),
          Ui.boxHeight(6),
          ...List.generate(3, (i) => _MiniField(labels[i], row[i])),
        ],
      ),
    );
  }
}

class _MiniField extends StatelessWidget {
  const _MiniField(this.label, this.controller);
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: AppText.medium(label,
                fontSize: 10, color: AppColors.lightTextColor),
          ),
          Expanded(
            child: CurvedContainer(
              radius: 6,
              border: Border.all(color: AppColors.borderColor),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: TextField(
                controller: controller,
                style:
                    TextStyle(fontSize: 11, color: AppColors.textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: '—',
                  hintStyle: TextStyle(
                      fontSize: 11, color: AppColors.lightTextColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReverseLogisticsSection extends StatelessWidget {
  const _ReverseLogisticsSection(this.controller);
  final VarController controller;

  @override
  Widget build(BuildContext context) {
    const labels = ['Item Retrieved', 'Quantity', 'Condition', 'Destination'];
    return Obx(() => CurvedContainer(
          border: Border.all(color: AppColors.borderColor),
          radius: 12,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                AppIcon(HugeIcons.strokeRoundedArrowTurnBackward,
                    size: 16, color: AppColors.primaryColor),
                Ui.boxWidth(8),
                AppText.semiBold('Reverse Logistics', fontSize: 13),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    controller.showReverseLogistics.value =
                        !controller.showReverseLogistics.value;
                    if (controller.showReverseLogistics.value &&
                        controller.reverseRows.isEmpty) {
                      controller.addReverseRow();
                    }
                  },
                  child: CurvedContainer(
                    radius: 20,
                    color: controller.showReverseLogistics.value
                        ? AppColors.primaryColor[100]!
                        : AppColors.borderColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: AppText.medium(
                      controller.showReverseLogistics.value
                          ? 'Enabled'
                          : 'Optional',
                      fontSize: 11,
                      color: controller.showReverseLogistics.value
                          ? AppColors.primaryColor
                          : AppColors.lightTextColor,
                    ),
                  ),
                ),
                if (controller.showReverseLogistics.value) ...[
                  Ui.boxWidth(8),
                  GestureDetector(
                    onTap: controller.addReverseRow,
                    child: CurvedContainer(
                      radius: 20,
                      color: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIcon(HugeIcons.strokeRoundedAdd01,
                                size: 14, color: AppColors.white),
                            Ui.boxWidth(4),
                            AppText.medium('Add Row',
                                fontSize: 11, color: AppColors.white),
                          ]),
                    ),
                  ),
                ],
              ]),
              if (controller.showReverseLogistics.value) ...[
                AppDivider(),
                if (controller.reverseRows.isEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: AppText.thin('No items added',
                          fontSize: 12,
                          color: AppColors.lightTextColor),
                    ),
                  )
                else
                  ...controller.reverseRows.asMap().entries.map((e) {
                    final row = e.value;
                    final idx = e.key;
                    return CurvedContainer(
                      border:
                          Border.all(color: AppColors.borderColor),
                      radius: 8,
                      margin:
                          const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AppText.medium('Item ${idx + 1}',
                                  fontSize: 11,
                                  color:
                                      AppColors.lightTextColor),
                              const Spacer(),
                              GestureDetector(
                                onTap: () =>
                                    controller.removeReverseRow(idx),
                                child: AppIcon(
                                    HugeIcons
                                        .strokeRoundedDelete01,
                                    size: 16,
                                    color: AppColors.red),
                              ),
                            ],
                          ),
                          Ui.boxHeight(6),
                          ...List.generate(4,
                              (i) => _MiniField(labels[i], row[i])),
                        ],
                      ),
                    );
                  }),
              ],
            ],
          ),
        ));
  }
}
