class ImageData {
  final String alt;
  final String url;

  ImageData({this.alt = '', required this.url});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      alt: json['alt'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
  factory ImageData.fromMap(Map<String, dynamic> json) {
    return ImageData(
      alt: json['alt'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'alt': alt, 'url': url};
  }
}
