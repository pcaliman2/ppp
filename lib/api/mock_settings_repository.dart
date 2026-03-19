import 'package:owa_flutter/api/settings_repository.dart';
import 'package:owa_flutter/models/update_settings_request.dart';
import 'package:owa_flutter/models/update_settings_response.dart';
import 'package:owa_flutter/models/user_profile.dart';

const bool kMockForceUpdateError = false;

class MockSettingsRepository implements SettingsRepository {
  const MockSettingsRepository();

  @override
  Future<UserProfile> getMyProfile() async {
    await Future.delayed(const Duration(milliseconds: 850));
    return const UserProfile(
      email: 'aldo@example.com',
      country: 'Mexico',
      phone: '+52 55 1234 5678',
      fullName: 'Aldo Martinez',
    );
  }

  @override
  Future<UpdateSettingsResponse> updateSettings(UpdateSettingsRequest request) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final email = request.email?.trim();
    final country = request.country?.trim();
    final phone = request.phone?.trim();
    final currentPassword = request.currentPassword ?? '';
    final newPassword = request.newPassword ?? '';

    if (email != null && email.isNotEmpty && !email.contains('@')) {
      return const UpdateSettingsResponse(
        ok: false,
        message: 'Enter a valid email.',
      );
    }
    if (country != null && country.isEmpty) {
      return const UpdateSettingsResponse(
        ok: false,
        message: 'Country is required.',
      );
    }
    if (phone != null && phone.isEmpty) {
      return const UpdateSettingsResponse(
        ok: false,
        message: 'Telephone is required.',
      );
    }
    if (newPassword.isNotEmpty) {
      if (currentPassword.isEmpty) {
        return const UpdateSettingsResponse(
          ok: false,
          message: 'Current password is required.',
        );
      }
      if (newPassword.length < 8) {
        return const UpdateSettingsResponse(
          ok: false,
          message: 'New password must contain at least 8 characters.',
        );
      }
    }

    if (kMockForceUpdateError) {
      return const UpdateSettingsResponse(
        ok: false,
        message: 'Could not save settings at this moment.',
      );
    }

    return const UpdateSettingsResponse(
      ok: true,
      message: 'Settings saved',
    );
  }
}
