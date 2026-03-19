import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/models/owa_specs.dart';

class OWATherapiesService {
  static const String _url =
      'https://www.latente-cms.com/delivery/v1/tenants/owa/sections/therapies/entries/therapies';

  static Future<OWATherapiesSectionSpec> fetchSpec() async {
    final response = await http.get(Uri.parse(_url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load therapies spec (${response.statusCode})');
    }
    final map = json.decode(response.body) as Map<String, dynamic>;
    return OWATherapiesSectionSpec.fromMap(map);
  }
}
