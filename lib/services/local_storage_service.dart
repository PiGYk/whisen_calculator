import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_calculation.dart';

class LocalStorageService {
  static const String _storageKey = 'saved_hvac_projects';

  static Future<List<SavedCalculation>> loadProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = prefs.getStringList(_storageKey) ?? [];
      final result = <SavedCalculation>[];
      for (final item in rawList) {
        try {
          result.add(SavedCalculation.fromMap(jsonDecode(item) as Map<String, dynamic>));
        } catch (e) {
          debugPrint('LocalStorageService: skipping corrupt entry — $e');
        }
      }
      return result;
    } catch (e) {
      debugPrint('LocalStorageService: loadProjects failed — $e');
      return [];
    }
  }

  static Future<void> saveProjects(List<SavedCalculation> projects) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList =
          projects.map((item) => jsonEncode(item.toMap())).toList();
      await prefs.setStringList(_storageKey, rawList);
    } catch (e) {
      debugPrint('LocalStorageService: saveProjects failed — $e');
    }
  }

  static Future<void> clearProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint('LocalStorageService: clearProjects failed — $e');
    }
  }
}
