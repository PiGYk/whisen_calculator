import '../models/equipment_model.dart';
import '../models/selection_result.dart';

/// Selection Engine v3 — підбирає пару LG + AUX
/// як рівнозначні альтернативи, не тіри.
class SelectionEngine {
  static SelectionResult select({
    required double requiredKw,
    required List<EquipmentModel> catalog,
    required String mode,
  }) {
    double relevantKw(EquipmentModel m) =>
        mode == 'Опалення' ? (m.heatingKw ?? m.coolingKw) : m.coolingKw;

    double seasonalEff(EquipmentModel m) =>
        mode == 'Опалення' ? (m.scop ?? m.cop ?? 0) : (m.seer ?? 0);

    double nominalEff(EquipmentModel m) =>
        mode == 'Опалення' ? (m.cop ?? m.eer ?? 0) : (m.eer ?? 0);

    // ── Фільтр по потужності ─────────────────────────────
    List<EquipmentModel> findSuitable(List<EquipmentModel> pool) {
      var suitable = pool.where((m) {
        final kw = relevantKw(m);
        return kw >= requiredKw && kw <= requiredKw * 1.60;
      }).toList();

      if (suitable.isEmpty) {
        suitable = pool.where((m) {
          final kw = relevantKw(m);
          return kw >= requiredKw * 0.95 && kw <= requiredKw * 2.0;
        }).toList();
      }
      return suitable;
    }

    // ── Вибір найкращого з пулу ──────────────────────────
    EquipmentModel? pickBest(List<EquipmentModel> candidates) {
      if (candidates.isEmpty) return null;
      candidates.sort((a, b) {
        final ovA = relevantKw(a) - requiredKw;
        final ovB = relevantKw(b) - requiredKw;
        if (ovA != ovB) return ovA.compareTo(ovB);
        final seB = seasonalEff(b);
        final seA = seasonalEff(a);
        if (seB != seA) return seB.compareTo(seA);
        return nominalEff(b).compareTo(nominalEff(a));
      });
      return candidates.first;
    }

    // ── Розбивка по брендах ──────────────────────────────
    final lgPool  = catalog.where((m) => m.brand == 'LG').toList();
    final auxPool = catalog.where((m) => m.brand == 'AUX').toList();

    SelectionOption buildOption(EquipmentModel m, String brand) {
      final kw    = relevantKw(m);
      final over  = ((kw - requiredKw) / requiredKw * 100);
      final seas  = seasonalEff(m);
      final nom   = nominalEff(m);

      final parts = <String>['${kw.toStringAsFixed(1)} кВт'];
      if (over > 0) parts.add('+${over.toStringAsFixed(0)}% запас');
      if (nom > 0)  parts.add('${mode == "Опалення" ? "COP" : "EER"} ${nom.toStringAsFixed(2)}');
      if (seas > 0) parts.add('${mode == "Опалення" ? "SCOP" : "SEER"} ${seas.toStringAsFixed(2)}');
      if (m.noiseCoolingDb != null) {
        parts.add('${m.noiseCoolingDb!.toStringAsFixed(0)} дБ');
      }

      return SelectionOption(
        brand:       brand,
        model:       m,
        matchReason: parts.join('  ·  '),
        oversize:    over,
      );
    }

    // ── Кілька LG-варіантів з різних серій (до 3) ────────
    List<SelectionOption> buildTopLg(List<EquipmentModel> pool) {
      final suitable = findSuitable(pool);
      if (suitable.isEmpty) return [];

      suitable.sort((a, b) {
        final ovA = relevantKw(a) - requiredKw;
        final ovB = relevantKw(b) - requiredKw;
        if (ovA != ovB) return ovA.compareTo(ovB);
        final seB = seasonalEff(b);
        final seA = seasonalEff(a);
        if (seB != seA) return seB.compareTo(seA);
        return nominalEff(b).compareTo(nominalEff(a));
      });

      // По одному з кожної серії, максимум 3
      final seenSeries = <String>{};
      final result = <SelectionOption>[];
      for (final m in suitable) {
        if (seenSeries.contains(m.seriesId)) continue;
        seenSeries.add(m.seriesId);
        result.add(buildOption(m, 'LG'));
        if (result.length >= 3) break;
      }
      return result;
    }

    final auxBest = pickBest(findSuitable(auxPool));

    return SelectionResult(
      primaryOptions: buildTopLg(lgPool),
      analog: auxBest != null ? buildOption(auxBest, 'AUX') : null,
    );
  }
}
