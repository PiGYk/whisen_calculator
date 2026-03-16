import 'package:flutter/material.dart';
import '../models/saved_calculation.dart';
import '../services/hvac_calculator_service.dart';
import '../widgets/section_title.dart';
import '../widgets/web_frame.dart';
import 'result_screen.dart';

class NewCalculationScreen extends StatefulWidget {
  const NewCalculationScreen({super.key});

  @override
  State<NewCalculationScreen> createState() => _NewCalculationScreenState();
}

class _NewCalculationScreenState extends State<NewCalculationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _projectNameCtrl = TextEditingController();
  final _areaCtrl        = TextEditingController(text: '35');
  final _heightCtrl      = TextEditingController(text: '2.7');
  final _peopleCtrl      = TextEditingController(text: '2');
  final _tariffCtrl      = TextEditingController(text: '4.32');

  static const double _residentialTariff = 4.32;
  static const double _commercialTariff  = 14.17;

  /// 'residential' або 'commercial'
  String _tariffType = 'residential';
  final _hoursCtrl       = TextEditingController(text: '8');
  final _daysCtrl        = TextEditingController(text: '30');

  String objectType = 'Квартира';
  String glazing    = 'Середнє';
  String insulation = 'Середнє';
  String climate    = 'Помiрний';
  String mode       = 'Охолодження';
  bool sunnySide    = false;

  /// Quick mode = тiльки обов'язковi поля (площа, тип, режим)
  /// Advanced mode = усi поля
  bool _quickMode = true;

  @override
  void dispose() {
    _projectNameCtrl.dispose();
    _areaCtrl.dispose();
    _heightCtrl.dispose();
    _peopleCtrl.dispose();
    _tariffCtrl.dispose();
    _hoursCtrl.dispose();
    _daysCtrl.dispose();
    super.dispose();
  }

  String? _validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) return "Поле обов'язкове";
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return 'Введи число';
    if (parsed <= 0) return 'Має бути бiльше нуля';
    return null;
  }

  String? _validateInt(String? value) {
    if (value == null || value.trim().isEmpty) return "Поле обов'язкове";
    final parsed = int.tryParse(value);
    if (parsed == null) return 'Введи цiле число';
    if (parsed < 0) return 'Не може бути менше нуля';
    return null;
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    final projectName = _projectNameCtrl.text.trim().isEmpty
        ? 'Без назви'
        : _projectNameCtrl.text.trim();

    final area         = double.parse(_areaCtrl.text.replaceAll(',', '.'));
    final height       = _quickMode ? 2.7 : double.parse(_heightCtrl.text.replaceAll(',', '.'));
    final people       = _quickMode ? 0   : int.parse(_peopleCtrl.text);
    final tariff       = _quickMode
        ? (_tariffType == 'residential' ? _residentialTariff : _commercialTariff)
        : double.parse(_tariffCtrl.text.replaceAll(',', '.'));
    final hoursPerDay  = _quickMode ? 8.0  : double.parse(_hoursCtrl.text.replaceAll(',', '.'));
    final daysPerMonth = _quickMode ? 30   : int.parse(_daysCtrl.text);
    final quickGlazing    = _quickMode ? 'Середнє' : glazing;
    final quickInsulation = _quickMode ? 'Середнє' : insulation;
    final quickClimate    = _quickMode ? 'Помiрний' : climate;
    final quickSunny      = _quickMode ? false : sunnySide;

    final result = HvacCalculatorService.calculate(
      objectType: objectType,
      area: area,
      height: height,
      people: people,
      glazing: quickGlazing,
      insulation: quickInsulation,
      sunnySide: quickSunny,
      climate: quickClimate,
      mode: mode,
      tariff: tariff,
      hoursPerDay: hoursPerDay,
      daysPerMonth: daysPerMonth,
    );

    final savedProject = SavedCalculation(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      projectName: projectName,
      objectType: objectType,
      area: area,
      height: height,
      people: people,
      glazing: quickGlazing,
      insulation: quickInsulation,
      sunnySide: quickSunny,
      climate: quickClimate,
      mode: mode,
      tariff: tariff,
      hoursPerDay: hoursPerDay,
      daysPerMonth: daysPerMonth,
      coolingKw: result.coolingKw,
      heatingKw: result.heatingKw,
      monthlyKwh: result.monthlyKwh,
      monthlyCost: result.monthlyCost,
      recommendation: result.recommendation,
      summary: result.summary,
      createdAt: DateTime.now(),
    );

    if (!mounted) return;

    final bool? shouldSave = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(project: savedProject, saveMode: true),
      ),
    );

    if (shouldSave == true && mounted) {
      Navigator.pop(context, savedProject);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новий розрахунок'),
      ),
      body: SafeArea(
        child: WebFrame(
          maxWidth: 680,
          child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 80),
            children: [
              // ── Quick / Advanced toggle ──────────────────
              _ModeToggle(
                quickMode: _quickMode,
                onChanged: (v) => setState(() => _quickMode = v),
              ),
              const SizedBox(height: 20),

              // ── Назва ────────────────────────────────────
              TextFormField(
                controller: _projectNameCtrl,
                decoration: InputDecoration(
                  labelText: "Назва об'єкта",
                  hintText: _quickMode ? 'Необов\'язково' : "Наприклад: Офiс на Хрещатику",
                ),
              ),
              const SizedBox(height: 20),

              // ── Основнi поля (завжди) ────────────────────
              const SectionTitle("Об'єкт"),
              _DropdownField<String>(
                label: "Тип об'єкта",
                value: objectType,
                items: const ['Квартира', 'Будинок', 'Офiс', 'Магазин'],
                onChanged: (v) => setState(() => objectType = v!),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _areaCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Площа, м²'),
                validator: _validateNumber,
              ),

              // ── Advanced-only поля ───────────────────────
              if (!_quickMode) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _heightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Висота стелi, м'),
                  validator: _validateNumber,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _peopleCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Кiлькiсть людей'),
                  validator: _validateInt,
                ),
                const SizedBox(height: 20),
                const SectionTitle('Умови'),
                _DropdownField<String>(
                  label: 'Рiвень склiння',
                  value: glazing,
                  items: const ['Низьке', 'Середнє', 'Високе'],
                  onChanged: (v) => setState(() => glazing = v!),
                ),
                const SizedBox(height: 14),
                _DropdownField<String>(
                  label: 'Утеплення',
                  value: insulation,
                  items: const ['Слабке', 'Середнє', 'Хороше'],
                  onChanged: (v) => setState(() => insulation = v!),
                ),
                const SizedBox(height: 14),
                _DropdownField<String>(
                  label: 'Клiмат',
                  value: climate,
                  items: const ['Теплий', 'Помiрний', 'Холодний'],
                  onChanged: (v) => setState(() => climate = v!),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: SwitchListTile(
                    title: const Text('Сонячна сторона'),
                    subtitle: Text(
                      sunnySide ? 'Так — +10% до навантаження' : 'Нi',
                      style: theme.textTheme.bodySmall,
                    ),
                    value: sunnySide,
                    onChanged: (v) => setState(() => sunnySide = v),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],

              // ── Тариф (завжди) ───────────────────────────
              const SizedBox(height: 20),
              const SectionTitle('Тариф електроенергiї'),
              _TariffSelector(
                selected: _tariffType,
                onChanged: (type) => setState(() {
                  _tariffType = type;
                  _tariffCtrl.text = type == 'residential'
                      ? _residentialTariff.toString()
                      : _commercialTariff.toString();
                }),
              ),

              // ── Режим (завжди) ───────────────────────────
              const SizedBox(height: 20),
              const SectionTitle('Режим роботи'),
              _DropdownField<String>(
                label: 'Режим',
                value: mode,
                items: const ['Охолодження', 'Опалення', 'Обидва'],
                onChanged: (v) => setState(() => mode = v!),
              ),

              // ── Енергоспоживання (тiльки Advanced) ───────
              if (!_quickMode) ...[
                const SizedBox(height: 20),
                const SectionTitle('Енергоспоживання'),
                TextFormField(
                  controller: _tariffCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Тариф, грн/кВт·год (власний)'),
                  validator: _validateNumber,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _hoursCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Годин/день'),
                        validator: _validateNumber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _daysCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Днiв/мiсяць'),
                        validator: _validateInt,
                      ),
                    ),
                  ],
                ),
              ],

              // ── Quick mode hint ──────────────────────────
              if (_quickMode) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.flash_on_rounded, color: theme.colorScheme.primary, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Quick mode: стандартнi значення висоти, склiння i тарифу. '
                          'Для точнiшого розрахунку перейди в Advanced.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate_rounded, size: 20),
                label: const Text('Розрахувати'),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Quick / Advanced toggle
// ─────────────────────────────────────────────
class _ModeToggle extends StatelessWidget {
  final bool quickMode;
  final ValueChanged<bool> onChanged;

  const _ModeToggle({required this.quickMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _Tab(
            label: 'Quick',
            icon: Icons.flash_on_rounded,
            active: quickMode,
            onTap: () => onChanged(true),
          ),
          _Tab(
            label: 'Advanced',
            icon: Icons.tune_rounded,
            active: !quickMode,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? theme.colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: active
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: active
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tariff selector
// ─────────────────────────────────────────────
class _TariffSelector extends StatelessWidget {
  final String selected; // 'residential' | 'commercial'
  final ValueChanged<String> onChanged;

  const _TariffSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TariffChip(
          label: 'Побутовий',
          value: '4.32 грн/кВт·год',
          active: selected == 'residential',
          onTap: () => onChanged('residential'),
        ),
        const SizedBox(width: 10),
        _TariffChip(
          label: 'Комерцiйний',
          value: '14.17 грн/кВт·год',
          active: selected == 'commercial',
          onTap: () => onChanged('commercial'),
        ),
      ],
    );
  }
}

class _TariffChip extends StatelessWidget {
  final String label;
  final String value;
  final bool active;
  final VoidCallback onTap;

  const _TariffChip({
    required this.label,
    required this.value,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: active
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: active
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: active
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Dropdown field
// ─────────────────────────────────────────────
class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(labelText: label),
      dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(item.toString()),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
