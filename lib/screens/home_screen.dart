import 'package:flutter/material.dart';
import '../app.dart';
import '../models/saved_calculation.dart';
import '../services/local_storage_service.dart';
import '../widgets/section_title.dart';
import '../widgets/web_frame.dart';
import 'new_calculation_screen.dart';
import 'saved_projects_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SavedCalculation> savedProjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final items = await LocalStorageService.loadProjects();
    if (!mounted) return;
    setState(() {
      savedProjects = items;
      isLoading = false;
    });
  }

  Future<void> _addProject(SavedCalculation item) async {
    final updated = [item, ...savedProjects];
    await LocalStorageService.saveProjects(updated);
    if (!mounted) return;
    setState(() => savedProjects = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Проект збережено')),
    );
  }

  Future<void> _deleteProject(int index) async {
    final updated = [...savedProjects]..removeAt(index);
    await LocalStorageService.saveProjects(updated);
    if (!mounted) return;
    setState(() => savedProjects = updated);
  }

  Future<void> _editProject(SavedCalculation updated, int index) async {
    final list = [...savedProjects];
    list[index] = updated;
    await LocalStorageService.saveProjects(list);
    if (!mounted) return;
    setState(() => savedProjects = list);
  }

  Future<void> _duplicateProject(SavedCalculation duplicate) async {
    final updated = [duplicate, ...savedProjects];
    await LocalStorageService.saveProjects(updated);
    if (!mounted) return;
    setState(() => savedProjects = updated);
  }

  Future<void> _confirmClearAll() async {
    if (savedProjects.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Очистити всi проекти?'),
        content: const Text('Це видалить усi локально збереженi розрахунки без можливостi вiдновлення.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Видалити все'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await LocalStorageService.clearProjects();
      if (!mounted) return;
      setState(() => savedProjects = []);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Усi проекти видалено')),
      );
    }
  }

  Future<void> _goToNewCalc() async {
    final saved = await Navigator.push<SavedCalculation>(
      context,
      MaterialPageRoute(builder: (_) => const NewCalculationScreen()),
    );
    if (saved != null) await _addProject(saved);
  }

  void _goToSavedProjects() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavedProjectsScreen(
          projects: savedProjects,
          onDelete: _deleteProject,
          onEdit: _editProject,
          onDuplicate: _duplicateProject,
        ),
      ),
    ).then((_) => _loadProjects());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('HVAC Calc Pro'),
        centerTitle: false,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: HvacCalcApp.themeNotifier,
            builder: (_, mode, __) => IconButton(
              onPressed: () {
                HvacCalcApp.themeNotifier.value =
                    mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
              },
              icon: Icon(mode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined),
              tooltip: 'Змiнити тему',
            ),
          ),
          if (savedProjects.isNotEmpty)
            IconButton(
              onPressed: _confirmClearAll,
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Очистити всi проекти',
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: WebFrame(
                child: savedProjects.isEmpty
                    ? _EmptyState(onNewCalc: _goToNewCalc)
                    : _HomeContent(
                        savedCount: savedProjects.length,
                        onNewCalc: _goToNewCalc,
                        onSaved: _goToSavedProjects,
                      ),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────
// Home content — single/two-column adaptive
// ─────────────────────────────────────────────
class _HomeContent extends StatelessWidget {
  final int savedCount;
  final VoidCallback onNewCalc;
  final VoidCallback onSaved;

  const _HomeContent({
    required this.savedCount,
    required this.onNewCalc,
    required this.onSaved,
  });

  static const _features = [
    (Icons.ac_unit_rounded,    'Cooling / Heating load',     'Орiєнтовна потужнiсть для першого КП',   Color(0xFFA50034)),
    (Icons.bolt_rounded,       'Оцiнка споживання',          'кВт·год/мiсяць та приблизна вартiсть',   Color(0xFFFFB347)),
    (Icons.save_alt_rounded,   'Локальне збереження',        'Проекти зберiгаються без хмари',          Color(0xFF4CAF50)),
    (Icons.edit_rounded,       'Редагування i дублювання',   'Три крапки на картцi проекту',            Color(0xFF9C6FFF)),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = isWide(context);

    final actions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroBlock(savedCount: savedCount),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onNewCalc,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Новий розрахунок'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onSaved,
          icon: const Icon(Icons.folder_outlined, size: 20),
          label: Text('Збереженi проекти ($savedCount)'),
        ),
      ],
    );

    final featureCards = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Можливостi'),
        const SizedBox(height: 8),
        for (final (icon, title, subtitle, color) in _features) ...[
          _FeatureCard(icon: icon, title: title, subtitle: subtitle, color: color),
          const SizedBox(height: 10),
        ],
      ],
    );

    if (wide) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: actions),
            const SizedBox(width: 28),
            Expanded(flex: 5, child: featureCards),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        actions,
        const SizedBox(height: 32),
        featureCards,
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Empty state — коли ще нема жодного проекту
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onNewCalc;
  const _EmptyState({required this.onNewCalc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.thermostat_rounded,
                size: 40,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Поки що нема проектiв',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Створи перший розрахунок — введи площу, висоту стелi та параметри примiщення.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onNewCalc,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Створити перший розрахунок'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Hero block (коли є проекти)
// ─────────────────────────────────────────────
class _HeroBlock extends StatelessWidget {
  final int savedCount;
  const _HeroBlock({required this.savedCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.thermostat_rounded, color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Calc', style: theme.textTheme.titleLarge),
                  Text('HVAC попереднiй пiдбiр', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                label: 'Проектiв',
                value: '$savedCount',
                icon: Icons.folder_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              _StatChip(
                label: 'Режим',
                value: 'Quick',
                icon: Icons.flash_on_rounded,
                color: const Color(0xFFFFB347),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: theme.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
                Text(label, style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
