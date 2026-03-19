class UserProfile {
  const UserProfile({
    required this.email,
    required this.country,
    required this.phone,
    this.fullName,
  });

  final String email;
  final String country;
  final String phone;
  final String? fullName;
}
