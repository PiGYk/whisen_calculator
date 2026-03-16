import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/equipment_model.dart';

class CatalogService {
  static List<EquipmentModel>? _cache;

  static Future<List<EquipmentModel>> loadAll() async {
    if (_cache != null) return _cache!;
    final results = <EquipmentModel>[];

    // Додавай сюди нові каталоги — вони завантажаться автоматично
    const catalogFiles = [
      'assets/data/catalog_lg_rac.json',
      'assets/data/catalog_lg_multiv.json',
      'assets/data/catalog_aux_vrf.json',
    ];

    for (final path in catalogFiles) {
      try {
        final raw  = await rootBundle.loadString(path);
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final brand     = data['brand'] as String;
        final seriesList = data['series'] as List;

        for (final seriesJson in seriesList) {
          final s           = seriesJson as Map<String, dynamic>;
          final seriesId    = s['id']       as String;
          final seriesName  = s['name']     as String;
          final tier        = s['tier']     as String;
          final tagline     = s['tagline']  as String;
          final features    = List<String>.from(s['features']    as List);
          final application = List<String>.from(s['application'] as List);

          final photoFile = s['photo'] as String?;
          final seriesImgPath = photoFile != null ? 'assets/data/photo/$photoFile' : null;

          for (final mJson in s['models'] as List) {
            final m = mJson as Map<String, dynamic>;

            results.add(EquipmentModel(
              id:               m['id']               as String,
              brand:            brand,
              seriesId:         seriesId,
              seriesName:       seriesName,
              tier:             tier,
              seriesTagline:    tagline,
              seriesFeatures:   features,
              seriesApplication:application,
              hp:               (m['hp']               as num).toInt(),
              coolingKw:        (m['cooling_kw']        as num).toDouble(),
              heatingKw:        (m['heating_kw']        as num?)?.toDouble(),
              eer:              (m['eer']               as num?)?.toDouble(),
              cop:              (m['cop']               as num?)?.toDouble(),
              seer:             (m['seer']              as num?)?.toDouble(),
              scop:             (m['scop']              as num?)?.toDouble(),
              powerCoolingKw:   (m['power_cooling_kw']  as num?)?.toDouble(),
              powerHeatingKw:   (m['power_heating_kw']  as num?)?.toDouble(),
              noiseCoolingDb:   (m['noise_cooling_db']  as num?)?.toDouble(),
              noiseHeatingDb:   (m['noise_heating_db']  as num?)?.toDouble(),
              maxIndoorUnits:   (m['max_indoor_units']  as num?)?.toInt(),
              voltage:          m['voltage']            as String,
              refrigerant:      m['refrigerant']        as String,
              imagePath:        seriesImgPath,
            ));
          }
        }
      } catch (e) {
        debugPrint('CatalogService: failed to load $path — $e');
      }
    }

    _cache = results;
    return results;
  }

  static void clearCache() => _cache = null;
}
