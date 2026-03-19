class UpdateSettingsRequest {
  const UpdateSettingsRequest({
    this.email,
    this.country,
    this.phone,
    this.currentPassword,
    this.newPassword,
  });

  final String? email;
  final String? country;
  final String? phone;
  final String? currentPassword;
  final String? newPassword;
}
