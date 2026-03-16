import 'package:flutter/material.dart';
import '../models/selection_result.dart';
import '../models/equipment_model.dart';
import '../theme/app_theme.dart';

class EquipmentCard extends StatelessWidget {
  final SelectionOption option;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback? onProposal;

  const EquipmentCard({
    super.key,
    required this.option,
    required this.isExpanded,
    required this.onToggle,
    this.onProposal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = option.color;
    final m     = option.model;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded ? color : AppColors.outline(context),
            width: isExpanded ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      option.brand,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: color, fontWeight: FontWeight.w700, letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${m.brand} ${m.seriesName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.muted(context),
                          ),
                        ),
                        Text(m.id, style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${m.hp} HP',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: color, fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text('${m.coolingKw.toStringAsFixed(1)} кВт',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.muted(context), size: 20),
                  ),
                ],
              ),
            ),

            // ── Match reason ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Text(
                option.matchReason,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.muted(context),
                ),
              ),
            ),

            // ── Expanded detail ──────────────────────────────
            if (isExpanded) ...[
              Divider(height: 1, color: AppColors.outline(context)),

              if (m.hasImage) _ImageBlock(model: m, color: color),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      m.seriesTagline,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _SpecsGrid(model: m),
                    const SizedBox(height: 16),

                    _TagRow(label: 'Застосування', tags: m.seriesApplication, color: color),
                    const SizedBox(height: 16),

                    Text('Переваги серiї',
                        style: theme.textTheme.titleMedium?.copyWith(color: color)),
                    const SizedBox(height: 8),
                    ...m.seriesFeatures.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle_outline_rounded, size: 15, color: color),
                            const SizedBox(width: 8),
                            Expanded(child: Text(f, style: theme.textTheme.bodySmall)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Divider(height: 1, color: AppColors.outline(context)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _InfoChip(label: m.voltage),
                        _InfoChip(label: m.refrigerant),
                        if (m.maxIndoorUnits != null)
                          _InfoChip(label: 'до ${m.maxIndoorUnits} вн. блокiв'),
                      ],
                    ),

                    if (onProposal != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: onProposal,
                          icon: const Icon(Icons.description_outlined, size: 18),
                          label: const Text('Сформувати КП'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Image block
// ─────────────────────────────────────────────
class _ImageBlock extends StatelessWidget {
  final EquipmentModel model;
  final Color color;
  const _ImageBlock({required this.model, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      color: color.withValues(alpha: 0.04),
      child: Image.asset(
        model.imagePath!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hvac_rounded, size: 48, color: color.withValues(alpha: 0.35)),
              const SizedBox(height: 6),
              Text(model.id,
                  style: TextStyle(color: color.withValues(alpha: 0.55),
                      fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Specs grid — LayoutBuilder, завжди 2 колонки
// ─────────────────────────────────────────────
class _SpecsGrid extends StatelessWidget {
  final EquipmentModel model;
  const _SpecsGrid({required this.model});

  @override
  Widget build(BuildContext context) {
    final specs = [
      if (model.coolingKw > 0)
        _Spec(Icons.ac_unit_rounded,               'Охолодження',    '${model.coolingKw.toStringAsFixed(1)} кВт',   AppColors.cooling),
      if (model.heatingKw != null)
        _Spec(Icons.local_fire_department_rounded, 'Опалення',       '${model.heatingKw!.toStringAsFixed(1)} кВт',  AppColors.heating),
      if (model.eer != null)
        _Spec(Icons.eco_rounded,                   'EER',             model.eer!.toStringAsFixed(2),                 AppColors.money),
      if (model.cop != null)
        _Spec(Icons.eco_rounded,                   'COP',             model.cop!.toStringAsFixed(2),                 AppColors.money),
      if (model.seer != null)
        _Spec(Icons.trending_up_rounded,           'SEER',            model.seer!.toStringAsFixed(2),                AppColors.cooling),
      if (model.scop != null)
        _Spec(Icons.trending_up_rounded,           'SCOP',            model.scop!.toStringAsFixed(2),                AppColors.heating),
      if (model.noiseCoolingDb != null)
        _Spec(Icons.volume_down_rounded,           'Шум охол.',      '${model.noiseCoolingDb!.toStringAsFixed(0)} дБ', const Color(0xFF9C6FFF)),
      if (model.noiseHeatingDb != null)
        _Spec(Icons.volume_down_rounded,           'Шум обiгр.',     '${model.noiseHeatingDb!.toStringAsFixed(0)} дБ', const Color(0xFF9C6FFF)),
      if (model.powerCoolingKw != null)
        _Spec(Icons.bolt_rounded,                  'Спожив. охол.',  '${model.powerCoolingKw!.toStringAsFixed(2)} кВт', AppColors.energy),
      if (model.powerHeatingKw != null)
        _Spec(Icons.bolt_rounded,                  'Спожив. обiгр.', '${model.powerHeatingKw!.toStringAsFixed(2)} кВт', AppColors.energy),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final tileW = (constraints.maxWidth - gap) / 2;
        final rows = <List<_Spec>>[];
        for (var i = 0; i < specs.length; i += 2) {
          rows.add(specs.sublist(i, i + 2 > specs.length ? specs.length : i + 2));
        }
        return Column(
          children: rows.map((row) => Padding(
            padding: const EdgeInsets.only(bottom: gap),
            child: Row(
              children: [
                _SpecTile(spec: row[0], width: tileW),
                if (row.length > 1) ...[
                  const SizedBox(width: gap),
                  _SpecTile(spec: row[1], width: tileW),
                ] else
                  SizedBox(width: tileW + gap),
              ],
            ),
          )).toList(),
        );
      },
    );
  }
}

class _Spec {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _Spec(this.icon, this.label, this.value, this.color);
}

class _SpecTile extends StatelessWidget {
  final _Spec spec;
  final double width;
  const _SpecTile({required this.spec, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: spec.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: spec.color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(spec.icon, size: 14, color: spec.color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spec.value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: spec.color,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  spec.label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.muted(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tag row
// ─────────────────────────────────────────────
class _TagRow extends StatelessWidget {
  final String label;
  final List<String> tags;
  final Color color;
  const _TagRow({required this.label, required this.tags, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: tags.map((t) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Text(t, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          )).toList(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Info chip
// ─────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface2(context),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.outline(context)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: AppColors.muted(context), fontWeight: FontWeight.w500),
      ),
    );
  }
}
