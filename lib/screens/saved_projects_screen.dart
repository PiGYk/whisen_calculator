import 'package:flutter/material.dart';
import '../models/saved_calculation.dart';
import '../theme/app_theme.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/web_frame.dart';
import 'result_screen.dart';
import 'edit_project_screen.dart';

class SavedProjectsScreen extends StatefulWidget {
  final List<SavedCalculation> projects;
  final Future<void> Function(int index) onDelete;
  final Future<void> Function(SavedCalculation updated, int index) onEdit;
  final Future<void> Function(SavedCalculation duplicate) onDuplicate;

  const SavedProjectsScreen({
    super.key,
    required this.projects,
    required this.onDelete,
    required this.onEdit,
    required this.onDuplicate,
  });

  @override
  State<SavedProjectsScreen> createState() => _SavedProjectsScreenState();
}

class _SavedProjectsScreenState extends State<SavedProjectsScreen> {
  String _fmtDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d.$m.$y  $h:$min';
  }

  Future<void> _confirmDelete(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Видалити проєкт?'),
        content: const Text('Цей розрахунок буде стертий з локального сховища.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.onDelete(index);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Проект видалено')),
        );
      }
    }
  }

  void _showActions(BuildContext context, SavedCalculation item, int index) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.projectName,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              _ActionTile(
                icon: Icons.edit_outlined,
                label: 'Редагувати',
                color: theme.colorScheme.primary,
                onTap: () async {
                  Navigator.pop(context);
                  final updated = await Navigator.push<SavedCalculation>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProjectScreen(project: item),
                    ),
                  );
                  if (updated != null) {
                    await widget.onEdit(updated, index);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Проект оновлено')),
                      );
                    }
                  }
                },
              ),
              _ActionTile(
                icon: Icons.copy_rounded,
                label: 'Дублювати',
                color: AppColors.money,
                onTap: () async {
                  Navigator.pop(context);
                  final duplicate = item.copyWith(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    projectName: '${item.projectName} (копiя)',
                    createdAt: DateTime.now(),
                  );
                  await widget.onDuplicate(duplicate);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Проект дубльовано')),
                    );
                  }
                },
              ),
              _ActionTile(
                icon: Icons.delete_outline_rounded,
                label: 'Видалити',
                color: AppColors.error,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(index);
                },
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projects = widget.projects;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          projects.isEmpty
              ? 'Збереженi проекти'
              : 'Збереженi проекти (${projects.length})',
        ),
      ),
      body: SafeArea(child: WebFrame(
        maxWidth: 900,
        child: projects.isEmpty
          ? AppEmptyState(
              icon: Icons.folder_open_rounded,
              title: 'Ще немає збережених розрахункiв',
              subtitle: 'Створи перший через головний екран',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
              itemCount: projects.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = projects[index];
                return _ProjectCard(
                  item: item,
                  formattedDate: _fmtDate(item.createdAt),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultScreen(project: item),
                    ),
                  ),
                  onMoreTap: () => _showActions(context, item, index),
                );
              },
            ),
        )),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final SavedCalculation item;
  final String formattedDate;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const _ProjectCard({
    required this.item,
    required this.formattedDate,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCooling = item.coolingKw > 0;
    final hasHeating = item.heatingKw > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.projectName,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.objectType,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onMoreTap,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: 20,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('${item.area.toStringAsFixed(0)} м²', style: theme.textTheme.bodySmall),
                  if (hasCooling) ...[
                    _Dot(),
                    const Icon(Icons.ac_unit_rounded, size: 12, color: AppColors.cooling),
                    const SizedBox(width: 3),
                    Text(
                      '${item.coolingKw.toStringAsFixed(1)} кВт',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.cooling,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (hasHeating) ...[
                    _Dot(),
                    const Icon(Icons.local_fire_department_rounded, size: 12, color: AppColors.heating),
                    const SizedBox(width: 3),
                    Text(
                      '${item.heatingKw.toStringAsFixed(1)} кВт',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.heating,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item.recommendation,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
