// File: lib/services/owa_discover_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/models/owa_specs.dart';

class OWADiscoverService {
  static const String _url =
      'https://www.latente-cms.com/delivery/v1/tenants/owa/sections/discover_owa/entries/discover_owa';

  static Future<OWADiscoverSectionSpec> fetchSpec() async {
    final response = await http.get(Uri.parse(_url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load discover spec (${response.statusCode})');
    }
    final map = json.decode(response.body) as Map<String, dynamic>;
    return OWADiscoverSectionSpec.fromMap(map);
  }
}
