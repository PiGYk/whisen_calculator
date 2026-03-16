import 'package:flutter/material.dart';
import '../models/saved_calculation.dart';
import '../theme/app_theme.dart';
import '../widgets/result_tile.dart';
import '../widgets/param_row.dart';
import '../widgets/web_frame.dart';
import 'equipment_screen.dart';

class ResultScreen extends StatelessWidget {
  final SavedCalculation project;
  final bool saveMode;

  const ResultScreen({
    super.key,
    required this.project,
    this.saveMode = false,
  });

  String _fmtDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d.$m.$y  $h:$min';
  }

  void _goToEquipment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EquipmentScreen(project: project),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasCooling = project.coolingKw > 0;
    final bool hasHeating = project.heatingKw > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(saveMode ? 'Результат розрахунку' : 'Деталi проекту'),
      ),
      body: SafeArea(
        child: WebFrame(
        child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
        children: [

          // ── Project header ────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        project.projectName,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        project.objectType,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.straighten_rounded, size: 14,
                        color: theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 4),
                    Text('${project.area.toStringAsFixed(0)} м²',
                        style: theme.textTheme.bodySmall),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time_rounded, size: 14,
                        color: theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 4),
                    Text(_fmtDate(project.createdAt),
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Power results (2-col on wide screens) ─
          _ResultTilesGrid(project: project, hasCooling: hasCooling, hasHeating: hasHeating),

          const SizedBox(height: 20),

          // ── CTA — пiдбiр обладнання ──────────────
          _EquipmentCta(onTap: () => _goToEquipment(context)),

          const SizedBox(height: 20),

          // ── Recommendation ────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.recommend_rounded,
                        color: theme.colorScheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Рекомендацiя',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  project.recommendation,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (project.summary.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(project.summary, style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Parameters ────────────────────────────
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: ExpansionTile(
                title: const Text('Вхiднi параметри'),
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                childrenPadding:
                    const EdgeInsets.fromLTRB(18, 0, 18, 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                children: [
                  const Divider(height: 16),
                  ParamRow('Висота стелi', '${project.height} м'),
                  ParamRow('Людей', '${project.people}'),
                  ParamRow('Склiння', project.glazing),
                  ParamRow('Утеплення', project.insulation),
                  ParamRow('Сонячна сторона', project.sunnySide ? 'Так' : 'Нi'),
                  ParamRow('Клiмат', project.climate),
                  ParamRow('Режим', project.mode),
                  ParamRow('Тариф',
                      '${project.tariff.toStringAsFixed(2)} грн/кВт·год'),
                  ParamRow('Годин на день',
                      project.hoursPerDay.toStringAsFixed(1)),
                  ParamRow('Днiв на мiсяць', '${project.daysPerMonth}'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Disclaimer ────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.warning, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Це попереднiй розрахунок. Для фiнального пiдбору обладнання "
                    "потрiбне уточнення по об'єкту, склiнню, теплопритоках, "
                    "монтажних умовах i режиму роботи.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Actions ───────────────────────────────
          if (saveMode) ...[
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.save_rounded, size: 20),
              label: const Text('Зберегти проект'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, false),
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              label: const Text('Назад без збереження'),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () => _goToEquipment(context),
              icon: const Icon(Icons.devices_rounded, size: 20),
              label: const Text('Пiдiбрати обладнання'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              label: const Text('Назад'),
            ),
          ],
        ],
      ),
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Result tiles — 2-col grid on wide screens
// ─────────────────────────────────────────────
class _ResultTilesGrid extends StatelessWidget {
  final SavedCalculation project;
  final bool hasCooling;
  final bool hasHeating;

  const _ResultTilesGrid({
    required this.project,
    required this.hasCooling,
    required this.hasHeating,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = [
      if (hasCooling)
        ResultTile(
          title: 'Охолодження',
          value: '${project.coolingKw.toStringAsFixed(2)} кВт',
          icon: Icons.ac_unit_rounded,
          accentColor: AppColors.cooling,
        ),
      if (hasHeating)
        ResultTile(
          title: 'Опалення',
          value: '${project.heatingKw.toStringAsFixed(2)} кВт',
          icon: Icons.local_fire_department_rounded,
          accentColor: AppColors.heating,
        ),
      ResultTile(
        title: 'Споживання / мiсяць',
        value: '${project.monthlyKwh.toStringAsFixed(0)} кВт·год',
        icon: Icons.bolt_rounded,
        accentColor: AppColors.energy,
      ),
      ResultTile(
        title: 'Вартiсть / мiсяць',
        value: '${project.monthlyCost.toStringAsFixed(0)} грн',
        icon: Icons.payments_outlined,
        accentColor: AppColors.money,
      ),
    ];

    if (!isWide(context) || tiles.length < 2) {
      return Column(
        children: [
          for (final t in tiles) ...[t, const SizedBox(height: 10)],
        ],
      );
    }

    // 2-column grid
    final rows = <Widget>[];
    for (int i = 0; i < tiles.length; i += 2) {
      rows.add(Row(
        children: [
          Expanded(child: tiles[i]),
          const SizedBox(width: 12),
          Expanded(child: i + 1 < tiles.length ? tiles[i + 1] : const SizedBox()),
        ],
      ));
      if (i + 2 < tiles.length) rows.add(const SizedBox(height: 12));
    }
    return Column(children: [...rows, const SizedBox(height: 10)]);
  }
}

// ─────────────────────────────────────────────
// CTA блок — виклик до дiї пiдбору обладнання
// ─────────────────────────────────────────────
class _EquipmentCta extends StatelessWidget {
  final VoidCallback onTap;
  const _EquipmentCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.12),
              theme.colorScheme.primary.withValues(alpha: 0.05),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.devices_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Пiдiбрати обладнання',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'LG та AUX — Економ / Оптимальний / Премiум',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
