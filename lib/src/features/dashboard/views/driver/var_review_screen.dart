import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/dashboard_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/var_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/models/var_data.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';
import 'package:transborder_logistics/src/src_barrel.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';

/// VarDetailReview — Shows a fully resolved, read-only detail view of a [VarRecord].
/// Opened from the admin resource_history detail panel when the user wants to
/// see the full record outside of the table grid.
class VarDetailReview extends StatelessWidget {
  const VarDetailReview({super.key, required this.record});
  final VarRecord record;

  @override
  Widget build(BuildContext context) {
    final dashCtrl = Get.find<DashboardController>();
    final varCtrl = Get.find<VarController>();

    final driverLabel = record.driverName.isNotEmpty
        ? record.driverName
        : record.driverid != 0
            ? '#${record.driverid}'
            : '—';

    final vehicleLabel = record.vehicleName.isNotEmpty
        ? record.vehicleName
        : record.vehicleid != 0
            ? '#${record.vehicleid}'
            : '—';

    final originLabel =
        record.originName.isNotEmpty ? record.originName : '—';

    final destinationLabel =
        record.destinationName.isNotEmpty ? record.destinationName : '—';

    return SinglePageScaffold(
      title: 'VAR Detail',
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status badge ────────────────────────────────────────────
                _ReviewSection(
                  title: 'Status',
                  icon: HugeIcons.strokeRoundedInformationCircle,
                  children: [
                    _InfoRow('Status', record.status),
                    _InfoRow(
                        'Delivery Complete',
                        record.deliveryComplete ? 'Yes — Trip ended' : 'No — Trip ongoing'),
                  ],
                ),
                Ui.boxHeight(12),

                // ── Trip Information ─────────────────────────────────────────
                _ReviewSection(
                  title: 'Trip Information',
                  icon: HugeIcons.strokeRoundedRoute03,
                  children: [
                    _InfoRow('Job Order No.', record.joborderno),
                    _InfoRow('Date of Arrival', record.dateofarrival),
                    _InfoRow('Driver', driverLabel),
                    _InfoRow('Vehicle', vehicleLabel),
                    _InfoRow('Origin', originLabel),
                    _InfoRow('Destination', destinationLabel),
                  ],
                ),
                Ui.boxHeight(12),

                // ── Cold Chain ───────────────────────────────────────────────
                _ReviewSection(
                  title: 'Cold Chain Details',
                  icon: HugeIcons.strokeRoundedThermometer,
                  children: [
                    _InfoRow(
                      'Required Temp. Range',
                      record.temperaturerange.isNotEmpty
                          ? record.temperaturerange
                          : '—',
                    ),
                  ],
                ),
                Ui.boxHeight(12),

                // ── Commodity Details ────────────────────────────────────────
                if (record.commodityDetails.isNotEmpty) ...[
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
                        'VVM',
                      ]),
                      ...record.commodityDetails.map(
                        (row) => _TableRow([
                          row.vaccine,
                          row.batchNo,
                          row.expiryDate,
                          row.qtyDispatched,
                          row.qtyReceived,
                          row.vvmStatus,
                        ]),
                      ),
                    ],
                  ),
                  Ui.boxHeight(12),
                ],

                // ── Temperature Monitoring ───────────────────────────────────
                if (record.temperatureMonitoring.isNotEmpty) ...[
                  _ReviewSection(
                    title: 'Temperature Monitoring',
                    icon: HugeIcons.strokeRoundedTemperature,
                    children: [
                      _TableHeader(const [
                        'Monitoring Point',
                        'Temp (°C)',
                        'Date/Time',
                      ]),
                      ...record.temperatureMonitoring.map(
                        (row) => _TableRow([
                          row.monitoringPoint,
                          row.temperatureCelsius,
                          row.dateTime,
                        ]),
                      ),
                    ],
                  ),
                  Ui.boxHeight(12),
                ],

                // ── Reverse Logistics ────────────────────────────────────────
                if (record.reverseLogistics.isNotEmpty) ...[
                  _ReviewSection(
                    title: 'Reverse Logistics',
                    icon: HugeIcons.strokeRoundedArrowTurnBackward,
                    children: [
                      _TableHeader(const [
                        'Item Retrieved',
                        'Qty',
                        'Condition',
                        'Destination',
                      ]),
                      ...record.reverseLogistics.map(
                        (row) => _TableRow([
                          row.item,
                          row.quantity,
                          row.condition,
                          row.destination,
                        ]),
                      ),
                    ],
                  ),
                  Ui.boxHeight(12),
                ],

                // ── Sign-Off ─────────────────────────────────────────────────
                _ReviewSection(
                    title: 'Sign-Off',
                    icon: HugeIcons.strokeRoundedSignature,
                    children: [
                      _InfoRow(
                          'Dispatched By', record.signOff.dispatchedBy),
                      _InfoRow(
                          'Delivered By', record.signOff.deliveredBy),
                      _InfoRow(
                          'Received By', record.signOff.receivedBy),
                    ],
                  ),
                Ui.boxHeight(12),
              ],
            ),
          ),

          // ── Sticky Close Out button (only admin, only when trip_ended) ────
          if (record.tripEnded)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Obx(
                () => varCtrl.isSubmitting.value
                    ? const Center(child: LoadingIndicator(size: 32))
                    : AppButton(
                        onPressed: () async {
                          await varCtrl.closeVar(record.id);
                          await dashCtrl.getAllVarRecords();
                          Get.back();
                        },
                        text: 'Close Out VAR',
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets (identical to old review screen, reusable)
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
          Row(
            children: [
              AppIcon(icon, size: 16, color: AppColors.primaryColor),
              Ui.boxWidth(8),
              AppText.semiBold(title, fontSize: 13),
            ],
          ),
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
            child: AppText.medium(
              label,
              fontSize: 11,
              color: AppColors.lightTextColor,
            ),
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
      color: AppColors.primaryColor..withValues(alpha: 0.06),
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
                  color:
                      c.isEmpty ? AppColors.lightTextColor : AppColors.textColor,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
