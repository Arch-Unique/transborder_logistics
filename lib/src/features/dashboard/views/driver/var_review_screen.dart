import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/var_controller.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';
import 'package:transborder_logistics/src/src_barrel.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';

class VarReviewScreen extends StatelessWidget {
  VarReviewScreen({super.key});

  final controller = Get.find<VarController>();

  // ── Resolve display values from the stored delivery ───────────────────────
  String _deliveryLabel() {
    final d = controller.activeDelivery.value;
    final id = controller.selectedDeliveryId.value;
    return d != null ? '${d.waybill} — ${d.stops.join(', ')}' : '#$id';
  }

  String _driverLabel() {
    final d = controller.activeDelivery.value;
    final id = controller.selectedDriverId.value;
    return (d?.driver?.isNotEmpty ?? false) ? d!.driver! : '#$id';
  }

  String _vehicleLabel() {
    final d = controller.activeDelivery.value;
    final id = controller.selectedVehicleId.value;
    return (d?.truckno?.isNotEmpty ?? false) ? d!.truckno! : '#$id';
  }

  String _originLabel() {
    final d = controller.activeDelivery.value;
    return (d?.pickup?.isNotEmpty ?? false) ? d!.pickup! : '—';
  }

  /// Uses the last stop as the destination display.
  String _destinationLabel() {
    final d = controller.activeDelivery.value;
    if (d == null || d.stops.isEmpty) return '—';
    return d.stops.last;
  }

  @override
  Widget build(BuildContext context) {
    return SinglePageScaffold(
      title: 'VAR Review',
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Trip Information ──────────────────────────────────────
                _ReviewSection(
                  title: 'Trip Information',
                  icon: HugeIcons.strokeRoundedRoute03,
                  children: [
                    _InfoRow('Delivery', _deliveryLabel()),
                    _InfoRow('Job Order No.', controller.jobOrderNo.text),
                    _InfoRow(
                        'Date of Arrival', controller.dateOfArrival.text),
                    _InfoRow('Origin', _originLabel()),
                    _InfoRow('Destination', _destinationLabel()),
                  ],
                ),
                Ui.boxHeight(12),

                // ── Cold Chain ────────────────────────────────────────────
                _ReviewSection(
                  title: 'Cold Chain Details',
                  icon: HugeIcons.strokeRoundedThermometer,
                  children: [
                    _InfoRow('Driver', _driverLabel()),
                    _InfoRow('Vehicle', _vehicleLabel()),
                    _InfoRow('Required Temp. Range',
                        controller.temperatureRange.value),
                  ],
                ),
                Ui.boxHeight(12),

                // ── Commodity Details ─────────────────────────────────────
                _ReviewSection(
                  title: 'Commodity Details',
                  icon: HugeIcons.strokeRoundedMedicineBottle01,
                  children: [
                    _TableHeader(const [
                      'Vaccine/Item',
                      'Batch No.',
                      'Expiry',
                      'Qty D',
                      'Qty R',
                      'VVM'
                    ]),
                    ...controller.commodityRows.asMap().entries.map((e) {
                      final row = e.value;
                      return _TableRow([
                        row[0].text,
                        row[1].text,
                        row[2].text,
                        row[3].text,
                        row[4].text,
                        row[5].text,
                      ]);
                    }),
                  ],
                ),
                Ui.boxHeight(12),

                // ── Temperature Monitoring ────────────────────────────────
                _ReviewSection(
                  title: 'Temperature Monitoring',
                  icon: HugeIcons.strokeRoundedTemperature,
                  children: [
                    _TableHeader(
                        const ['Monitoring Point', 'Temp (°C)', 'Date/Time']),
                    ...controller.tempRows.asMap().entries.map((e) {
                      final row = e.value;
                      return _TableRow(
                          [row[0].text, row[1].text, row[2].text]);
                    }),
                  ],
                ),
                Ui.boxHeight(12),

                // ── Reverse Logistics (optional) ──────────────────────────
                if (controller.showReverseLogistics.value &&
                    controller.reverseRows.isNotEmpty)
                  _ReviewSection(
                    title: 'Reverse Logistics',
                    icon: HugeIcons.strokeRoundedArrowTurnBackward,
                    children: [
                      _TableHeader(const [
                        'Item Retrieved',
                        'Qty',
                        'Condition',
                        'Destination'
                      ]),
                      ...controller.reverseRows.asMap().entries.map((e) {
                        final row = e.value;
                        return _TableRow([
                          row[0].text,
                          row[1].text,
                          row[2].text,
                          row[3].text
                        ]);
                      }),
                    ],
                  ),

                if (controller.showReverseLogistics.value &&
                    controller.reverseRows.isNotEmpty)
                  Ui.boxHeight(12),

                // ── Sign-Off ──────────────────────────────────────────────
                _ReviewSection(
                  title: 'Sign-Off',
                  icon: HugeIcons.strokeRoundedSignature,
                  children: [
                    _InfoRow('Dispatched By', controller.dispatchedBy.text),
                    _InfoRow('Delivered By', controller.deliveredBy.text),
                    _InfoRow('Received By', controller.receivedBy.text),
                  ],
                ),
                Ui.boxHeight(12),
              ],
            ),
          ),

          // ── Sticky submit button ────────────────────────────────────────
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Obx(() => controller.isSubmitting.value
                ? const Center(child: LoadingIndicator(size: 32))
                : AppButton(
                    onPressed: controller.submit,
                    text: 'Confirm & Submit',
                  )),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
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

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: AppText.medium(label,
                fontSize: 11, color: AppColors.lightTextColor),
          ),
          Expanded(
            child: AppText.medium(
              value.isEmpty ? '—' : value,
              fontSize: 12,
              color:
                  value.isEmpty ? AppColors.lightTextColor : AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.headers);
  final List<String> headers;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryColor.withOpacity(0.06),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: headers
            .map(
              (h) => Expanded(
                child: AppText.semiBold(
                  h,
                  fontSize: 9,
                  color: AppColors.primaryColor,
                  alignment: TextAlign.center,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow(this.cells);
  final List<String> cells;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: cells
            .map(
              (c) => Expanded(
                child: AppText.thin(
                  c.isEmpty ? '—' : c,
                  fontSize: 10,
                  alignment: TextAlign.center,
                  color: c.isEmpty
                      ? AppColors.lightTextColor
                      : AppColors.textColor,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
