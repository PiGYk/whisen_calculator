import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_calculation.dart';

class LocalStorageService {
  static const String _storageKey = 'saved_hvac_projects';

  static Future<List<SavedCalculation>> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = prefs.getStringList(_storageKey) ?? [];

    return rawList
        .map((item) => SavedCalculation.fromMap(jsonDecode(item)))
        .toList();
  }

  static Future<void> saveProjects(List<SavedCalculation> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList =
        projects.map((item) => jsonEncode(item.toMap())).toList();
    await prefs.setStringList(_storageKey, rawList);
  }

  static Future<void> clearProjects() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
