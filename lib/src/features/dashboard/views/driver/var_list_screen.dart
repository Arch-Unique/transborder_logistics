import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:transborder_logistics/src/features/dashboard/controllers/var_controller.dart';
import 'package:transborder_logistics/src/features/dashboard/models/var_data.dart';
import 'package:transborder_logistics/src/global/ui/widgets/others/containers.dart';
import 'package:transborder_logistics/src/src_barrel.dart';
import 'package:transborder_logistics/src/global/ui/ui_barrel.dart';

class VarListScreen extends StatefulWidget {
  const VarListScreen({super.key});

  @override
  State<VarListScreen> createState() => _VarListScreenState();
}

class _VarListScreenState extends State<VarListScreen> {
  final controller = Get.find<VarController>();

  @override
  void initState() {
    super.initState();
    controller.fetchVars();
  }

  @override
  Widget build(BuildContext context) {
    return SinglePageScaffold(
      title: 'VAR Records',
      child: Obx(() {
        if (controller.isFetchingVars.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.allVars.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(
                  HugeIcons.strokeRoundedDocumentCode,
                  size: 48,
                  color: AppColors.lightTextColor,
                ),
                Ui.boxHeight(12),
                AppText.thin(
                  'No VAR records submitted yet',
                  fontSize: 14,
                  color: AppColors.lightTextColor,
                ),
              ],
            ),
          );
        }
        return RefreshScrollView(
          onRefreshed: () async => controller.fetchVars(),
          onExtend: () async {},
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.allVars.length,
            itemBuilder: (_, i) => _VarRecordCard(controller.allVars[i]),
          ),
        );
      }),
    );
  }
}

class _VarRecordCard extends StatelessWidget {
  const _VarRecordCard(this.record);
  final VarRecord record;

  @override
  Widget build(BuildContext context) {
    final received = record.signOff.receivedBy.isNotEmpty;
    return InkWell(
      onTap: () => Get.to(() => _VarDetailScreen(record)),
      child: CurvedContainer(
        border: Border.all(color: AppColors.borderColor),
        radius: 12,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ─────────────────────────────────────────────────
            Row(
              children: [
                CurvedContainer(
                  radius: 20,
                  color: AppColors.primaryColor[50],
                  padding: const EdgeInsets.all(6),
                  child: AppIcon(
                    HugeIcons.strokeRoundedDocumentCode,
                    size: 14,
                    color: AppColors.primaryColor,
                  ),
                ),
                Ui.boxWidth(10),
                Expanded(
                  child: AppText.semiBold(
                    record.joborderno.isEmpty ? '—' : record.joborderno,
                    fontSize: 14,
                  ),
                ),
                _StatusChip(received ? 'Received' : 'Pending', received),
              ],
            ),
            AppDivider(),

            // ── Meta rows ──────────────────────────────────────────────────
            _MetaRow(HugeIcons.strokeRoundedCalendar01,
                record.dateofarrival.isEmpty ? '—' : record.dateofarrival),
            _MetaRow(
              HugeIcons.strokeRoundedThermometer,
              record.temperaturerange.isEmpty ? '—' : record.temperaturerange,
            ),
            _MetaRow(
              HugeIcons.strokeRoundedLocation05,
              () {
                final parts = [
                  if (record.originName.isNotEmpty) record.originName,
                  if (record.destinationName.isNotEmpty) record.destinationName,
                ].join(' → ');
                return parts.isEmpty ? '—' : parts;
              }(),
            ),

            // ── Commodity count ────────────────────────────────────────────
            Ui.boxHeight(6),
            Row(
              children: [
                _CountBadge(
                    '${record.commodityDetails.length}', 'Commodities'),
                Ui.boxWidth(8),
                _CountBadge(
                    '${record.temperatureMonitoring.length}', 'Temp Checks'),
                if (record.reverseLogistics.isNotEmpty) ...[
                  Ui.boxWidth(8),
                  _CountBadge(
                      '${record.reverseLogistics.length}', 'Reverse'),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.icon, this.text);
  final dynamic icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          AppIcon(icon, size: 12, color: AppColors.lightTextColor),
          Ui.boxWidth(6),
          Expanded(
            child: AppText.thin(
              text,
              fontSize: 12,
              color: AppColors.lightTextColor,
              maxlines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.label, this.isReceived);
  final String label;
  final bool isReceived;

  @override
  Widget build(BuildContext context) {
    final color = isReceived ? AppColors.green : AppColors.yellow;
    return CurvedContainer(
      radius: 20,
      color: color.withOpacity(0.12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: AppText.medium(label, fontSize: 10, color: color),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge(this.count, this.label);
  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      radius: 8,
      border: Border.all(color: AppColors.borderColor),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText.bold(count, fontSize: 11, color: AppColors.primaryColor),
          Ui.boxWidth(4),
          AppText.thin(label, fontSize: 10, color: AppColors.lightTextColor),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VAR Detail Screen
// ─────────────────────────────────────────────────────────────────────────────

class _VarDetailScreen extends StatelessWidget {
  const _VarDetailScreen(this.record);
  final VarRecord record;

  @override
  Widget build(BuildContext context) {
    return SinglePageScaffold(
      title: 'VAR #${record.id}',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailSection(
              title: 'Trip Information',
              icon: HugeIcons.strokeRoundedRoute03,
              fields: {
                'Job Order No.': record.joborderno,
                'Date of Arrival': record.dateofarrival,
                'Origin': record.originName.isEmpty
                    ? '#${record.originid}'
                    : record.originName,
                'Destination': record.destinationName.isEmpty
                    ? '#${record.destinationid}'
                    : record.destinationName,
              },
            ),
            Ui.boxHeight(12),
            _DetailSection(
              title: 'Cold Chain Details',
              icon: HugeIcons.strokeRoundedThermometer,
              fields: {
                'Driver': record.driverName.isEmpty
                    ? '#${record.driverid}'
                    : record.driverName,
                'Vehicle': record.vehicleName.isEmpty
                    ? '#${record.vehicleid}'
                    : record.vehicleName,
                'Temp. Range': record.temperaturerange,
              },
            ),
            Ui.boxHeight(12),
            _TableSection(
              title: 'Commodity Details',
              icon: HugeIcons.strokeRoundedMedicineBottle01,
              headers: const [
                'Vaccine',
                'Batch',
                'Expiry',
                'Qty D',
                'Qty R',
                'VVM'
              ],
              rows: record.commodityDetails
                  .map((c) => [
                        c.vaccine,
                        c.batchNo,
                        c.expiryDate,
                        c.qtyDispatched,
                        c.qtyReceived,
                        c.vvmStatus,
                      ])
                  .toList(),
            ),
            Ui.boxHeight(12),
            _TableSection(
              title: 'Temperature Monitoring',
              icon: HugeIcons.strokeRoundedTemperature,
              headers: const ['Point', 'Temp (°C)', 'Date/Time'],
              rows: record.temperatureMonitoring
                  .map((t) => [
                        t.monitoringPoint,
                        t.temperatureCelsius,
                        t.dateTime,
                      ])
                  .toList(),
            ),
            if (record.reverseLogistics.isNotEmpty) ...[
              Ui.boxHeight(12),
              _TableSection(
                title: 'Reverse Logistics',
                icon: HugeIcons.strokeRoundedArrowTurnBackward,
                headers: const ['Item', 'Qty', 'Condition', 'Destination'],
                rows: record.reverseLogistics
                    .map((r) => [
                          r.item,
                          r.quantity,
                          r.condition,
                          r.destination,
                        ])
                    .toList(),
              ),
            ],
            Ui.boxHeight(12),
            _DetailSection(
              title: 'Sign-Off',
              icon: HugeIcons.strokeRoundedSignature,
              fields: {
                'Dispatched By': record.signOff.dispatchedBy,
                'Delivered By': record.signOff.deliveredBy,
                'Received By': record.signOff.receivedBy,
              },
            ),
            Ui.boxHeight(24),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection(
      {required this.title, required this.icon, required this.fields});
  final String title;
  final dynamic icon;
  final Map<String, String> fields;

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      border: Border.all(color: AppColors.borderColor),
      radius: 12,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            AppIcon(icon, size: 15, color: AppColors.primaryColor),
            Ui.boxWidth(8),
            AppText.semiBold(title, fontSize: 13),
          ]),
          AppDivider(),
          ...fields.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130,
                    child: AppText.medium(e.key,
                        fontSize: 11, color: AppColors.lightTextColor),
                  ),
                  Expanded(
                    child: AppText.medium(
                      e.value.isEmpty ? '—' : e.value,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableSection extends StatelessWidget {
  const _TableSection(
      {required this.title,
      required this.icon,
      required this.headers,
      required this.rows});
  final String title;
  final dynamic icon;
  final List<String> headers;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return CurvedContainer(
      border: Border.all(color: AppColors.borderColor),
      radius: 12,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            AppIcon(icon, size: 15, color: AppColors.primaryColor),
            Ui.boxWidth(8),
            AppText.semiBold(title, fontSize: 13),
          ]),
          AppDivider(),
          // Header
          Container(
            color: AppColors.primaryColor.withOpacity(0.06),
            padding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
            child: Row(
              children: headers
                  .map((h) => Expanded(
                        child: AppText.semiBold(h,
                            fontSize: 9,
                            color: AppColors.primaryColor,
                            alignment: TextAlign.center),
                      ))
                  .toList(),
            ),
          ),
          // Rows
          ...rows.map(
            (cells) => Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppColors.borderColor)),
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
              child: Row(
                children: cells
                    .map(
                      (c) => Expanded(
                        child: AppText.thin(
                          c.isEmpty ? '—' : c,
                          fontSize: 10,
                          alignment: TextAlign.center,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
