// File: lib/services/owa_hero_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/models/owa_hero_spec.dart';
import 'package:owa_flutter/models/owa_specs.dart';

class OWAHeroService {
  static const String _heroUrl =
      'https://www.latente-cms.com/delivery/v1/tenants/owa/sections/hero/entries/hero';

  static const String _motoTextUrl =
      'https://www.latente-cms.com/delivery/v1/tenants/owa/sections/moto_text/entries/moto_text';

  static Future<OWAHeroSpec> fetchHeroSpec() async {
    final response = await http.get(Uri.parse(_heroUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load hero spec (${response.statusCode})');
    }
    final map = json.decode(response.body) as Map<String, dynamic>;
    return OWAHeroSpec.fromMap(map);
  }

  static Future<OWAMotoTextSpec> fetchMotoTextSpec() async {
    final response = await http.get(Uri.parse(_motoTextUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load moto text spec (${response.statusCode})');
    }
    final map = json.decode(response.body) as Map<String, dynamic>;
    return OWAMotoTextSpec.fromMap(map);
  }
}
