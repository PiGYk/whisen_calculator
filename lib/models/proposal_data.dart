import 'saved_calculation.dart';
import 'selection_result.dart';

/// Дані для формування комерційної пропозиції.
/// Збирається з SavedCalculation + обраного SelectionOption.
class ProposalData {
  final SavedCalculation project;
  final SelectionOption equipment;

  /// Дані клієнта — необов'язкові, заповнюються на екрані КП
  String clientName;
  String clientPhone;

  ProposalData({
    required this.project,
    required this.equipment,
    this.clientName = '',
    this.clientPhone = '',
  });
}
