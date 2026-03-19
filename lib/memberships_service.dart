// File: lib/services/owa_memberships_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:owa_flutter/models/owa_specs.dart';

class OWAMembershipsService {
  static const String _url =
      'https://www.latente-cms.com/delivery/v1/tenants/owa/sections/memberships/entries/memberships';

  static Future<OWAMembershipsSectionSpec> fetchSpec() async {
    final response = await http.get(Uri.parse(_url));
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load memberships spec (${response.statusCode})',
      );
    }
    final map = json.decode(response.body) as Map<String, dynamic>;
    return OWAMembershipsSectionSpec.fromMap(map);
  }
}
