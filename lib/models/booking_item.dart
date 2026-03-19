enum BookingKind { service, event }
enum BookingStatus { confirmed, pending, cancelled }

class BookingItem {
  const BookingItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.start,
    required this.status,
    this.end,
    this.location,
    this.subtitle,
  });

  final String id;
  final BookingKind kind;
  final String title;
  final DateTime start;
  final DateTime? end;
  final BookingStatus status;
  final String? location;
  final String? subtitle;
}
