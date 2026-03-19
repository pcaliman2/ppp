import 'package:owa_flutter/api/bookings_repository.dart';
import 'package:owa_flutter/models/booking_item.dart';
import 'package:owa_flutter/models/membership_status.dart';

const bool kMockHasActiveMembership = true;

class MockBookingsRepository implements BookingsRepository {
  const MockBookingsRepository();

  @override
  Future<MembershipStatus> getMembershipStatus() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!kMockHasActiveMembership) {
      return const MembershipStatus(isActive: false);
    }
    return MembershipStatus(
      isActive: true,
      membershipName: 'OWA Prime Membership',
      startDate: DateTime(2026, 2, 1),
      endDate: DateTime(2026, 3, 1),
    );
  }

  @override
  Future<List<BookingItem>> getUpcomingBookings() async {
    await Future.delayed(const Duration(milliseconds: 1100));
    return [
      BookingItem(
        id: 'UP-1001',
        kind: BookingKind.service,
        title: 'Deep Tissue Therapy',
        subtitle: 'With Dr. Rivera',
        start: DateTime(2026, 2, 24, 10, 30),
        end: DateTime(2026, 2, 24, 11, 30),
        status: BookingStatus.confirmed,
        location: 'OWA Wellness Room A',
      ),
      BookingItem(
        id: 'UP-1002',
        kind: BookingKind.event,
        title: 'Breathwork Group Session',
        subtitle: 'Hosted by Coach Kim',
        start: DateTime(2026, 2, 27, 18, 0),
        status: BookingStatus.pending,
        location: 'OWA Studio North',
      ),
      BookingItem(
        id: 'UP-1003',
        kind: BookingKind.service,
        title: 'Infrared Recovery',
        subtitle: 'Recovery Lab',
        start: DateTime(2026, 3, 2, 9, 0),
        status: BookingStatus.cancelled,
        location: 'OWA Recovery Lab',
      ),
    ];
  }

  @override
  Future<List<BookingItem>> getPastBookings() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return [
      BookingItem(
        id: 'PA-0991',
        kind: BookingKind.event,
        title: 'Mobility Reset Workshop',
        subtitle: 'Guest Trainer: Daniel Fox',
        start: DateTime(2026, 1, 18, 17, 0),
        status: BookingStatus.confirmed,
        location: 'OWA Studio South',
      ),
      BookingItem(
        id: 'PA-0987',
        kind: BookingKind.service,
        title: 'Recovery Massage',
        subtitle: 'With Ana West',
        start: DateTime(2026, 1, 10, 12, 30),
        end: DateTime(2026, 1, 10, 13, 15),
        status: BookingStatus.confirmed,
        location: 'OWA Wellness Room C',
      ),
      BookingItem(
        id: 'PA-0982',
        kind: BookingKind.event,
        title: 'Cold Plunge Fundamentals',
        subtitle: 'OWA Coaching Team',
        start: DateTime(2025, 12, 28, 11, 0),
        status: BookingStatus.cancelled,
        location: 'OWA Events Hall',
      ),
    ];
  }
}
