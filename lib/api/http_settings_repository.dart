import 'package:owa_flutter/api/settings_repository.dart';
import 'package:owa_flutter/models/update_settings_request.dart';
import 'package:owa_flutter/models/update_settings_response.dart';
import 'package:owa_flutter/models/user_profile.dart';

class HttpSettingsRepository implements SettingsRepository {
  const HttpSettingsRepository();

  @override
  Future<UserProfile> getMyProfile() async {
    // TODO(api): request profile settings from backend once contract is available.
    throw UnimplementedError('HTTP profile settings integration pending.');
  }

  @override
  Future<UpdateSettingsResponse> updateSettings(UpdateSettingsRequest request) async {
    // TODO(api): send update payload to backend and parse response.
    throw UnimplementedError('HTTP update settings integration pending.');
  }
}
