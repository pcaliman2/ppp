class ValidationError {
  final List<dynamic> loc;
  final String msg;
  final String type;

  ValidationError({required this.loc, required this.msg, required this.type});

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      loc: json['loc'],
      msg: json['msg'],
      type: json['type'],
    );
  }

  @override
  String toString() => '$msg (${loc.join('.')})';
}
