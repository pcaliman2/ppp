class ValidationErrorDetail {
  final List<dynamic> loc;
  final String msg;
  final String type;

  ValidationErrorDetail({
    required this.loc,
    required this.msg,
    required this.type,
  });

  factory ValidationErrorDetail.fromJson(Map<String, dynamic> json) {
    return ValidationErrorDetail(
      loc: json['loc'],
      msg: json['msg'],
      type: json['type'],
    );
  }
}
