import 'package:owa_flutter/api/bookings_repository.dart';
import 'package:owa_flutter/models/booking_item.dart';
import 'package:owa_flutter/models/membership_status.dart';

class HttpBookingsRepository implements BookingsRepository {
  const HttpBookingsRepository();

  @override
  Future<MembershipStatus> getMembershipStatus() async {
    // TODO(api): call backend membership endpoint when contract is defined.
    throw UnimplementedError('HTTP membership status integration pending.');
  }

  @override
  Future<List<BookingItem>> getUpcomingBookings() async {
    // TODO(api): call backend upcoming bookings endpoint and parse list.
    throw UnimplementedError('HTTP upcoming bookings integration pending.');
  }

  @override
  Future<List<BookingItem>> getPastBookings() async {
    // TODO(api): call backend past bookings endpoint and parse list.
    throw UnimplementedError('HTTP past bookings integration pending.');
  }
}
