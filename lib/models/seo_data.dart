class SeoData {
  final String title;
  final String description;

  SeoData({required this.title, required this.description});

  factory SeoData.fromMap(Map<String, dynamic> map) {
    return SeoData(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
