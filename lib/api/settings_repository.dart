import 'package:owa_flutter/models/update_settings_request.dart';
import 'package:owa_flutter/models/update_settings_response.dart';
import 'package:owa_flutter/models/user_profile.dart';

abstract class SettingsRepository {
  Future<UserProfile> getMyProfile();
  Future<UpdateSettingsResponse> updateSettings(UpdateSettingsRequest request);
}
