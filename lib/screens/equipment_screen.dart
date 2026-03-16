import 'package:flutter/material.dart';
import '../models/saved_calculation.dart';
import '../models/selection_result.dart';
import '../models/proposal_data.dart';
import '../services/catalog_service.dart';
import '../services/selection_engine.dart';
import '../widgets/equipment_card.dart';
import '../widgets/web_frame.dart';
import '../theme/app_theme.dart';
import 'proposal_screen.dart';

class EquipmentScreen extends StatefulWidget {
  final SavedCalculation project;
  const EquipmentScreen({super.key, required this.project});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  SelectionResult? _result;
  bool _loading = true;
  String? _error;
  String? _expandedBrand; // яка картка розгорнута

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final catalog = await CatalogService.loadAll();
      final result  = SelectionEngine.select(
        requiredKw: _requiredKw,
        catalog:    catalog,
        mode:       widget.project.mode,
      );
      if (!mounted) return;
      setState(() {
        _result        = result;
        _loading       = false;
        // Перший варіант розгорнутий за замовчуванням
        _expandedBrand = result.primary?.model.seriesId ?? result.analog?.brand;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _openProposal(SelectionOption option) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProposalScreen(
          data: ProposalData(
            project:   widget.project,
            equipment: option,
          ),
        ),
      ),
    );
  }

  double get _requiredKw =>
      widget.project.coolingKw > 0
          ? widget.project.coolingKw
          : widget.project.heatingKw;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пiдбiр обладнання'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(26),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.project.projectName,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);

    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Завантаження каталогу...', style: theme.textTheme.bodySmall),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Не вдалося завантажити каталог', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(_error!, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Спробувати знову'),
              ),
            ],
          ),
        ),
      );
    }

    if (_result == null || _result!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 56, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 16),
              Text('Нiчого не знайдено', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Для ${_requiredKw.toStringAsFixed(1)} кВт пiдходящих моделей немає.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return WebFrame(
      maxWidth: 900,
      child: ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
      children: [

        // ── Required power banner ──────────────────────────
        _RequiredBanner(
          requiredKw: _requiredKw,
          mode:       widget.project.mode,
          area:       widget.project.area,
        ),
        const SizedBox(height: 16),

        // ── Brand comparison hint (тільки якщо є AUX) ─────
        if (_result!.primary != null && _result!.analog != null)
          _ComparisonHint(lg: _result!.primary!, aux: _result!.analog!),

        const SizedBox(height: 16),

        // ── LG картки (кілька варіантів з різних серій) ───
        ..._result!.primaryOptions.map((opt) {
          final id = opt.model.seriesId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: EquipmentCard(
              option:     opt,
              isExpanded: _expandedBrand == id,
              onToggle:   () => setState(() {
                _expandedBrand = _expandedBrand == id ? null : id;
              }),
              onProposal: () => _openProposal(opt),
            ),
          );
        }),

        // ── AUX card ──────────────────────────────────────
        if (_result!.analog != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EquipmentCard(
              option:     _result!.analog!,
              isExpanded: _expandedBrand == _result!.analog!.brand,
              onToggle:   () => setState(() {
                _expandedBrand = _expandedBrand == _result!.analog!.brand
                    ? null
                    : _result!.analog!.brand;
              }),
              onProposal: () => _openProposal(_result!.analog!),
            ),
          ),

        _Disclaimer(),
      ],
    ),
    );
  }
}

// ─────────────────────────────────────────────
class _RequiredBanner extends StatelessWidget {
  final double requiredKw;
  final String mode;
  final double area;
  const _RequiredBanner({required this.requiredKw, required this.mode, required this.area});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);
    final onSurf = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.thermostat_rounded, color: accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 14, color: onSurf),
                    children: [
                      const TextSpan(text: 'Потрiбна потужнiсть: '),
                      TextSpan(
                        text: '${requiredKw.toStringAsFixed(2)} кВт',
                        style: TextStyle(
                          color: accent, fontWeight: FontWeight.w700, fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Площа ${area.toStringAsFixed(0)} м²  ·  Режим: $mode',
                  style: TextStyle(fontSize: 12, color: AppColors.muted(context)),
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
// Порівняльний хінт LG vs AUX
// ─────────────────────────────────────────────
class _ComparisonHint extends StatelessWidget {
  final SelectionOption lg;
  final SelectionOption aux;
  const _ComparisonHint({required this.lg, required this.aux});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final lgEff  = lg.model.seer ?? lg.model.eer ?? 0;
    final auxEff = aux.model.seer ?? aux.model.eer ?? 0;
    final effDiff = lgEff > 0 && auxEff > 0
        ? ((lgEff - auxEff) / auxEff * 100).abs().toStringAsFixed(0)
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface2(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline(context)),
      ),
      child: Row(
        children: [
          // LG chip
          _BrandChip(brand: 'LG', color: lg.color, model: lg.model.id),
          const SizedBox(width: 8),
          Text('vs', style: TextStyle(color: AppColors.muted(context), fontSize: 12)),
          const SizedBox(width: 8),
          // AUX chip
          _BrandChip(brand: 'AUX', color: aux.color, model: aux.model.id),
          const Spacer(),
          // Diff hint
          if (effDiff != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  lgEff > auxEff ? 'LG ефективнiший' : 'AUX ефективнiший',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: lgEff > auxEff ? lg.color : aux.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'на $effDiff%',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  final String brand;
  final Color color;
  final String model;
  const _BrandChip({required this.brand, required this.color, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            brand,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 2),
        Text(model, style: TextStyle(fontSize: 10, color: AppColors.muted(context))),
      ],
    );
  }
}

// ─────────────────────────────────────────────
class _Disclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 14, color: AppColors.warning),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Пiдбiр автоматичний по потужностi. Фiнальний вибiр — за менеджером '
              'з урахуванням умов монтажу, наявностi та побажань клiєнта.',
              style: TextStyle(fontSize: 11, color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
