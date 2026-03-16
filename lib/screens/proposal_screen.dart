import 'package:flutter/material.dart';
import '../models/proposal_data.dart';
import '../models/saved_calculation.dart';
import '../models/selection_result.dart';
import '../models/equipment_model.dart';
import '../theme/app_theme.dart';
import '../widgets/web_frame.dart';

class ProposalScreen extends StatefulWidget {
  final ProposalData data;
  const ProposalScreen({super.key, required this.data});

  @override
  State<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.data.clientName);
    _phoneCtrl = TextEditingController(text: widget.data.clientPhone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d.$m.${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final p   = widget.data.project;
    final opt = widget.data.equipment;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Комерційна пропозицiя'),
        actions: [
          Tooltip(
            message: 'Експорт PDF — незабаром',
            child: IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: null,
            ),
          ),
        ],
      ),
      body: SafeArea(child: WebFrame(
        maxWidth: 800,
        child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        children: [
          _HeaderCard(project: p, dateStr: _fmtDate(p.createdAt)),
          const SizedBox(height: 14),
          _ClientCard(nameCtrl: _nameCtrl, phoneCtrl: _phoneCtrl),
          const SizedBox(height: 14),
          _ObjectCard(project: p),
          const SizedBox(height: 14),
          _PowerCard(project: p),
          const SizedBox(height: 14),
          _EquipmentBlock(option: opt),
          const SizedBox(height: 14),
          _FeaturesCard(option: opt),
          const SizedBox(height: 14),
          _EnergyCard(project: p),
          const SizedBox(height: 14),
          _DisclaimerCard(),
          const SizedBox(height: 8),
          _PdfBanner(),
        ],
      ))),
    );
  }
}

// ══════════════════════════════════════════════
// 1. Header — бренд + назва КП + дата + проект
// ══════════════════════════════════════════════
class _HeaderCard extends StatelessWidget {
  final SavedCalculation project;
  final String dateStr;
  const _HeaderCard({required this.project, required this.dateStr});

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline(context)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Акцентна смужка зверху
          Container(height: 4, color: accent),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Whisen',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Комерційна пропозицiя',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.muted(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      dateStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.muted(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: AppColors.outline(context)),
                const SizedBox(height: 16),
                Text(project.projectName, style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Chip(label: project.objectType, color: accent),
                    const SizedBox(width: 8),
                    Text(
                      '${project.area.toStringAsFixed(0)} м²',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    Text('·', style: theme.textTheme.bodySmall),
                    const SizedBox(width: 8),
                    Text(project.mode, style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 2. Клієнт — редаговані поля
// ══════════════════════════════════════════════
class _ClientCard extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  const _ClientCard({required this.nameCtrl, required this.phoneCtrl});

  @override
  Widget build(BuildContext context) {
    return _Section(
      icon: Icons.person_outline_rounded,
      title: 'Клiєнт',
      child: Column(
        children: [
          TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'ПIБ або назва органiзацiї',
              hintText: "Необов'язково",
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Телефон',
              hintText: "Необов'язково",
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 3. Об'єкт — параметри у сітці
// ══════════════════════════════════════════════
class _ObjectCard extends StatelessWidget {
  final SavedCalculation project;
  const _ObjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final p = project;
    return _Section(
      icon: Icons.home_outlined,
      title: "Об'єкт",
      child: _ParamGrid(params: [
        _Param("Тип об'єкта", p.objectType),
        _Param('Площа',          '${p.area.toStringAsFixed(0)} м²'),
        _Param('Висота стелi',   '${p.height} м'),
        _Param('Клiмат',         p.climate),
        _Param('Утеплення',      p.insulation),
        _Param('Склiння',        p.glazing),
        _Param('Сонячна сторона', p.sunnySide ? 'Так (+10%)' : 'Нi'),
        if (p.people > 0) _Param('Людей', '${p.people}'),
      ]),
    );
  }
}

// ══════════════════════════════════════════════
// 4. Розрахункові показники
// ══════════════════════════════════════════════
class _PowerCard extends StatelessWidget {
  final SavedCalculation project;
  const _PowerCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final p          = project;
    final hasCooling = p.coolingKw > 0;
    final hasHeating = p.heatingKw > 0;

    return _Section(
      icon: Icons.calculate_outlined,
      title: 'Розрахунковi показники',
      child: Row(
        children: [
          if (hasCooling)
            Expanded(child: _PowerBig(
              label: 'Охолодження',
              value: '${p.coolingKw.toStringAsFixed(2)} кВт',
              icon: Icons.ac_unit_rounded,
              color: AppColors.cooling,
            )),
          if (hasCooling && hasHeating) const SizedBox(width: 10),
          if (hasHeating)
            Expanded(child: _PowerBig(
              label: 'Опалення',
              value: '${p.heatingKw.toStringAsFixed(2)} кВт',
              icon: Icons.local_fire_department_rounded,
              color: AppColors.heating,
            )),
          if (!hasCooling && !hasHeating)
            Text('Режим не визначено',
                style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _PowerBig extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _PowerBig({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color, fontWeight: FontWeight.w700,
                  ),
                ),
                Text(label, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 5. Рекомендоване рішення — обладнання
// ══════════════════════════════════════════════
class _EquipmentBlock extends StatelessWidget {
  final SelectionOption option;
  const _EquipmentBlock({required this.option});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = option.color;
    final m     = option.model;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок блоку
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            color: color.withValues(alpha: 0.08),
            child: Row(
              children: [
                Icon(Icons.devices_rounded, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  'Рекомендоване рiшення',
                  style: theme.textTheme.titleMedium?.copyWith(color: color),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: color.withValues(alpha: 0.3)),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Бренд + модель
                Row(
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
                        style: TextStyle(
                          color: color, fontWeight: FontWeight.w800, fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.seriesName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.muted(context),
                            ),
                          ),
                          Text(
                            m.id,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${m.hp} HP',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: color, fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${m.coolingKw.toStringAsFixed(1)} кВт',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Tagline
                Text(
                  m.seriesTagline,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: 16),

                // Specs grid
                _ProposalSpecsGrid(model: m),

                const SizedBox(height: 14),
                Divider(height: 1, color: AppColors.outline(context)),
                const SizedBox(height: 12),

                // Застосування
                _AppTags(tags: m.seriesApplication, color: color),

                const SizedBox(height: 12),

                // Технічні чіпи
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 6. Ключові переваги серії
// ══════════════════════════════════════════════
class _FeaturesCard extends StatelessWidget {
  final SelectionOption option;
  const _FeaturesCard({required this.option});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = option.color;

    return _Section(
      icon: Icons.star_outline_rounded,
      title: 'Ключовi переваги серiї',
      accentColor: color,
      child: Column(
        children: option.model.seriesFeatures.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 16, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(f, style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 7. Енергоспоживання
// ══════════════════════════════════════════════
class _EnergyCard extends StatelessWidget {
  final SavedCalculation project;
  const _EnergyCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = project;
    return _Section(
      icon: Icons.bolt_rounded,
      title: 'Енергоспоживання',
      child: Column(
        children: [
          _ParamGrid(params: [
            _Param('Споживання/мiсяць', '${p.monthlyKwh.toStringAsFixed(0)} кВт·год'),
            _Param('Вартiсть/мiсяць',   '${p.monthlyCost.toStringAsFixed(0)} грн'),
            _Param('Тариф',             '${p.tariff.toStringAsFixed(2)} грн/кВт·год'),
            _Param('Режим роботи',      '${p.hoursPerDay.toStringAsFixed(0)} год/день · ${p.daysPerMonth} днiв'),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.energy.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.energy.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 13, color: AppColors.energy),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Розрахунок орiєнтовний. Враховує коефiцiєнт COP/EER ≈ 3 '
                    '(реальне споживання менше за охолоджувальну потужнiсть).',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.energy,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 8. Дисклеймер
// ══════════════════════════════════════════════
class _DisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Пiдбiр обладнання та розрахунки є попереднiми. Фiнальний вибiр '
              'узгоджується з клiєнтом з урахуванням умов монтажу, наявностi '
              'обладнання та побажань. Цiни не вказанi.',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// 9. PDF-банер (Phase 4 preview)
// ══════════════════════════════════════════════
class _PdfBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf_outlined,
              color: theme.colorScheme.primary.withValues(alpha: 0.5), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Експорт у PDF — незабаром',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Фаза 4: брендований PDF-документ з логотипом, '
                  'характеристиками та зображеннями обладнання.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Shared widgets
// ══════════════════════════════════════════════

/// Уніфікована секція з іконкою та заголовком
class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Color? accentColor;
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Параметр — пара label + value
class _Param {
  final String label;
  final String value;
  const _Param(this.label, this.value);
}

/// Двоколонкова сітка параметрів
class _ParamGrid extends StatelessWidget {
  final List<_Param> params;
  const _ParamGrid({required this.params});

  @override
  Widget build(BuildContext context) {
    final rows  = <List<_Param>>[];
    for (var i = 0; i < params.length; i += 2) {
      rows.add(params.sublist(i, (i + 2).clamp(0, params.length)));
    }
    return Column(
      children: rows.map((row) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(child: _ParamCell(p: row[0])),
            const SizedBox(width: 8),
            if (row.length > 1)
              Expanded(child: _ParamCell(p: row[1]))
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      )).toList(),
    );
  }
}

class _ParamCell extends StatelessWidget {
  final _Param p;
  const _ParamCell({required this.p});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface2(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.muted(context),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            p.value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Технічні характеристики — компактна сітка (як в EquipmentCard)
class _ProposalSpecsGrid extends StatelessWidget {
  final EquipmentModel model;
  const _ProposalSpecsGrid({required this.model});

  @override
  Widget build(BuildContext context) {
    final m = model;
    final specs = [
      if (m.coolingKw > 0)
        _Spec(Icons.ac_unit_rounded, 'Охолодження',
            '${m.coolingKw.toStringAsFixed(1)} кВт', AppColors.cooling),
      if (m.heatingKw != null)
        _Spec(Icons.local_fire_department_rounded, 'Опалення',
            '${m.heatingKw!.toStringAsFixed(1)} кВт', AppColors.heating),
      if (m.eer != null)
        _Spec(Icons.eco_rounded, 'EER', m.eer!.toStringAsFixed(2), AppColors.money),
      if (m.cop != null)
        _Spec(Icons.eco_rounded, 'COP', m.cop!.toStringAsFixed(2), AppColors.money),
      if (m.seer != null)
        _Spec(Icons.trending_up_rounded, 'SEER',
            m.seer!.toStringAsFixed(2), AppColors.cooling),
      if (m.scop != null)
        _Spec(Icons.trending_up_rounded, 'SCOP',
            m.scop!.toStringAsFixed(2), AppColors.heating),
      if (m.noiseCoolingDb != null)
        _Spec(Icons.volume_down_rounded, 'Шум',
            '${m.noiseCoolingDb!.toStringAsFixed(0)} дБ',
            const Color(0xFF9C6FFF)),
      if (m.powerCoolingKw != null)
        _Spec(Icons.bolt_rounded, 'Спожив.',
            '${m.powerCoolingKw!.toStringAsFixed(2)} кВт', AppColors.energy),
    ];

    return LayoutBuilder(builder: (ctx, constraints) {
      const gap = 8.0;
      final tileW = (constraints.maxWidth - gap) / 2;
      final rows  = <List<_Spec>>[];
      for (var i = 0; i < specs.length; i += 2) {
        rows.add(specs.sublist(i, (i + 2).clamp(0, specs.length)));
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
    });
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
    return SizedBox(
      width: width,
      child: Container(
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
      ),
    );
  }
}

/// Теги застосування
class _AppTags extends StatelessWidget {
  final List<String> tags;
  final Color color;
  const _AppTags({required this.tags, required this.color});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags.map((t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Text(
          t,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
        ),
      )).toList(),
    );
  }
}

/// Кольоровий чіп (для header)
class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Сірий технічний чіп
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
        style: TextStyle(
          fontSize: 10,
          color: AppColors.muted(context),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
