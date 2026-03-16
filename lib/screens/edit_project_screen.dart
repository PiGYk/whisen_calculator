import 'package:flutter/material.dart';
import '../models/saved_calculation.dart';
import '../services/hvac_calculator_service.dart';
import '../widgets/section_title.dart';

/// Екран редагування iснуючого проекту.
/// Повертає оновлений [SavedCalculation] або null якщо скасовано.
class EditProjectScreen extends StatefulWidget {
  final SavedCalculation project;

  const EditProjectScreen({super.key, required this.project});

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _projectNameCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _peopleCtrl;
  late final TextEditingController _tariffCtrl;
  late final TextEditingController _hoursCtrl;
  late final TextEditingController _daysCtrl;

  late String objectType;
  late String glazing;
  late String insulation;
  late String climate;
  late String mode;
  late bool sunnySide;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _projectNameCtrl = TextEditingController(text: p.projectName);
    _areaCtrl        = TextEditingController(text: p.area.toString());
    _heightCtrl      = TextEditingController(text: p.height.toString());
    _peopleCtrl      = TextEditingController(text: p.people.toString());
    _tariffCtrl      = TextEditingController(text: p.tariff.toString());
    _hoursCtrl       = TextEditingController(text: p.hoursPerDay.toString());
    _daysCtrl        = TextEditingController(text: p.daysPerMonth.toString());
    objectType = p.objectType;
    glazing    = p.glazing;
    insulation = p.insulation;
    climate    = p.climate;
    mode       = p.mode;
    sunnySide  = p.sunnySide;
  }

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

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final projectName = _projectNameCtrl.text.trim().isEmpty
        ? 'Без назви'
        : _projectNameCtrl.text.trim();

    final area        = double.parse(_areaCtrl.text.replaceAll(',', '.'));
    final height      = double.parse(_heightCtrl.text.replaceAll(',', '.'));
    final people      = int.parse(_peopleCtrl.text);
    final tariff      = double.parse(_tariffCtrl.text.replaceAll(',', '.'));
    final hoursPerDay = double.parse(_hoursCtrl.text.replaceAll(',', '.'));
    final daysPerMonth = int.parse(_daysCtrl.text);

    final result = HvacCalculatorService.calculate(
      objectType: objectType,
      area: area,
      height: height,
      people: people,
      glazing: glazing,
      insulation: insulation,
      sunnySide: sunnySide,
      climate: climate,
      mode: mode,
      tariff: tariff,
      hoursPerDay: hoursPerDay,
      daysPerMonth: daysPerMonth,
    );

    final updated = widget.project.copyWith(
      projectName: projectName,
      objectType: objectType,
      area: area,
      height: height,
      people: people,
      glazing: glazing,
      insulation: insulation,
      sunnySide: sunnySide,
      climate: climate,
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
      // createdAt зберiгаємо оригiнальний
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редагувати проект'),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              'Зберегти',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              TextFormField(
                controller: _projectNameCtrl,
                decoration: const InputDecoration(labelText: "Назва об'єкта"),
              ),
              const SizedBox(height: 24),

              const SectionTitle("Об'єкт"),
              _DropdownField<String>(
                label: "Тип об'єкта",
                value: objectType,
                items: const ['Квартира', 'Будинок', 'Офiс', 'Магазин'],
                onChanged: (v) => setState(() => objectType = v!),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _areaCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Площа, м²'),
                      validator: _validateNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _heightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Висота, м'),
                      validator: _validateNumber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _peopleCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Кiлькiсть людей'),
                validator: _validateInt,
              ),

              const SizedBox(height: 24),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const SectionTitle('Режим роботи'),
              _DropdownField<String>(
                label: 'Режим',
                value: mode,
                items: const ['Охолодження', 'Опалення', 'Обидва'],
                onChanged: (v) => setState(() => mode = v!),
              ),

              const SizedBox(height: 24),
              const SectionTitle('Енергоспоживання'),
              TextFormField(
                controller: _tariffCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Тариф, грн/кВт·год'),
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

              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text('Зберегти змiни'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Скасувати'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
