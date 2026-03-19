import 'package:owa_flutter/models/booking_item.dart';
import 'package:owa_flutter/models/membership_status.dart';

abstract class BookingsRepository {
  Future<MembershipStatus> getMembershipStatus();
  Future<List<BookingItem>> getUpcomingBookings();
  Future<List<BookingItem>> getPastBookings();
}
