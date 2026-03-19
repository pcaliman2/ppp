class PopupSubmissionResult {
  final int id;
  final String email;
  final String gender;
  final String birthDate;
  final int? age;
  final String? submittedAt;

  const PopupSubmissionResult({
    required this.id,
    required this.email,
    required this.gender,
    required this.birthDate,
    this.age,
    this.submittedAt,
  });

  factory PopupSubmissionResult.fromJson(Map<String, dynamic> json) {
    return PopupSubmissionResult(
      id: json['id'] as int,
      email: (json['email'] ?? json['emailAddress'] ?? '') as String,
      gender: (json['gender'] ?? '') as String,
      birthDate: (json['birth_date'] ?? json['birthDate'] ?? '') as String,
      age: json['age'] as int?,
      submittedAt: (json['submitted_at'] ?? json['submittedAt']) as String?,
    );
  }
}
