class PopupSubmission {
  final String email;
  final String gender;
  final String birthDate; // Format: YYYY-MM-DD

  const PopupSubmission({
    required this.email,
    required this.gender,
    required this.birthDate,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'gender': gender.toLowerCase(),
    'birth_date': birthDate,
  };
}
