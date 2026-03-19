class MembershipStatus {
  const MembershipStatus({
    required this.isActive,
    this.membershipName,
    this.startDate,
    this.endDate,
  });

  final bool isActive;
  final String? membershipName;
  final DateTime? startDate;
  final DateTime? endDate;
}
