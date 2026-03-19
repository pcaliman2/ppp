import 'package:flutter/material.dart';
import 'package:owa_flutter/api/bookings_repository.dart';
import 'package:owa_flutter/api/http_bookings_repository.dart';
import 'package:owa_flutter/api/mock_bookings_repository.dart';
import 'package:owa_flutter/config/api_config.dart';
import 'package:owa_flutter/models/booking_item.dart';
import 'package:owa_flutter/models/membership_status.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/is_desktop_from_context.dart';
import 'package:owa_flutter/useful/size_config.dart';

enum BookingFilter { upcoming, past }

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  BookingFilter _activeFilter = BookingFilter.upcoming;
  late final BookingsRepository _repository;

  MembershipStatus? _membershipStatus;
  List<BookingItem> _upcoming = const [];
  List<BookingItem> _past = const [];

  bool _isLoadingInitial = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = useMockBackend
        ? const MockBookingsRepository()
        : const HttpBookingsRepository();
    _load(initial: true);
  }

  Future<void> _load({bool initial = false}) async {
    if (initial) {
      setState(() {
        _isLoadingInitial = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _isRefreshing = true;
        _errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        _repository.getMembershipStatus(),
        _repository.getUpcomingBookings(),
        _repository.getPastBookings(),
      ]);
      if (!mounted) return;
      setState(() {
        _membershipStatus = results[0] as MembershipStatus;
        _upcoming = results[1] as List<BookingItem>;
        _past = results[2] as List<BookingItem>;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load bookings right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitial = false;
          _isRefreshing = false;
        });
      }
    }
  }

  List<BookingItem> get _currentList =>
      _activeFilter == BookingFilter.upcoming ? _upcoming : _past;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDesktop = isDesktopFromContext(context);
    final horizontalPadding = isDesktop ? SizeConfig.w(72) : SizeConfig.w(22);

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                SizeConfig.h(24),
                horizontalPadding,
                SizeConfig.h(28),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 820),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInOutCubic,
                    transitionBuilder: (child, animation) {
                      final offset = Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                      );
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: offset, child: child),
                      );
                    },
                    child: _buildMainContent(textTheme),
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: !_isRefreshing,
            child: AnimatedOpacity(
              opacity: _isRefreshing ? 1 : 0,
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOutCubic,
              child: const Center(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F2F2F)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(TextTheme textTheme) {
    if (_isLoadingInitial) {
      return _buildLoadingState(textTheme);
    }
    if (_errorMessage != null) {
      return _buildErrorState(textTheme);
    }

    return Column(
      key: const ValueKey('bookings-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(textTheme),
        SizedBox(height: SizeConfig.h(18)),
        _buildMembershipSection(textTheme),
        const Divider(height: 32, thickness: 1, color: Colors.black12),
        _buildSegmentedFilter(textTheme),
        SizedBox(height: SizeConfig.h(12)),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 620),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (child, animation) {
            final offset = Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offset, child: child),
            );
          },
          child: _currentList.isEmpty ? _buildEmptyState(textTheme) : _buildBookingList(textTheme),
        ),
      ],
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF5A5A5A),
                ),
              ),
              SizedBox(height: SizeConfig.h(6)),
              Text(
                'My Bookings',
                style: textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF222222),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit profile coming soon.')),
            );
          },
          child: Text(
            'Edit Profile',
            style: textTheme.labelLarge?.copyWith(
              color: const Color(0xFF2F2F2F),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMembershipSection(TextTheme textTheme) {
    final membership = _membershipStatus;
    final isActive = membership?.isActive == true;
    final startDate =
        membership?.startDate != null ? _formatDate(membership!.startDate!) : null;
    final endDate =
        membership?.endDate != null ? _formatDate(membership!.endDate!) : null;

    return Container(
      margin: EdgeInsets.symmetric(vertical: SizeConfig.h(8)),
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(16),
        vertical: SizeConfig.h(14),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF333333), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isActive ? Icons.workspace_premium_rounded : Icons.star_outline_rounded,
            color: const Color(0xFFF1E6C8),
            size: 22,
          ),
          SizedBox(width: SizeConfig.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? 'Active Membership' : 'No active membership',
                  style: textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFF1E6C8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isActive && membership?.membershipName != null) ...[
                  SizedBox(height: SizeConfig.h(4)),
                  Text(
                    membership!.membershipName!,
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
                if (startDate != null && endDate != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        _MembershipDateBlock(
                          label: 'VALID FROM',
                          value: startDate,
                        ),
                        SizedBox(width: 40),
                        _MembershipDateBlock(
                          label: 'NEXT PAYMENT',
                          value: endDate,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedFilter(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildFilterTextButton(
              label: 'Upcoming',
              selected: _activeFilter == BookingFilter.upcoming,
              onTap: () => setState(() => _activeFilter = BookingFilter.upcoming),
              textTheme: textTheme,
            ),
            SizedBox(width: SizeConfig.w(20)),
            _buildFilterTextButton(
              label: 'Past',
              selected: _activeFilter == BookingFilter.past,
              onTap: () => setState(() => _activeFilter = BookingFilter.past),
              textTheme: textTheme,
            ),
          ],
        ),
        SizedBox(height: SizeConfig.h(8)),
        const Divider(height: 1, thickness: 1, color: Colors.black12),
      ],
    );
  }

  Widget _buildFilterTextButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required TextTheme textTheme,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: selected ? const Color(0xFF232323) : const Color(0xFF7A7A7A),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: textTheme.titleSmall?.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          color: selected ? const Color(0xFF232323) : const Color(0xFF7A7A7A),
        ),
      ),
    );
  }

  Widget _buildBookingList(TextTheme textTheme) {
    return Column(
      key: ValueKey(_activeFilter),
      children: [
        for (int i = 0; i < _currentList.length; i++) ...[
          _BookingLineItem(
            booking: _currentList[i],
            textTheme: textTheme,
          ),
          const Divider(height: 32, thickness: 1, color: Colors.black12),
        ],
      ],
    );
  }

  Widget _buildLoadingState(TextTheme textTheme) {
    return Column(
      key: const ValueKey('loading-state'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Bookings',
          style: textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF222222),
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: SizeConfig.h(18)),
        Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F2F2F)),
              ),
            ),
            SizedBox(width: SizeConfig.w(10)),
            Text(
              'Loading bookings...',
              style: textTheme.bodyLarge?.copyWith(color: const Color(0xFF4A4A4A)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(TextTheme textTheme) {
    return Column(
      key: const ValueKey('error-state'),
      children: [
        Icon(Icons.error_outline_rounded, size: 30, color: const Color(0xFF4D4D4D)),
        SizedBox(height: SizeConfig.h(10)),
        Text(
          _errorMessage ?? 'Could not load bookings.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF3A3A3A),
          ),
        ),
        SizedBox(height: SizeConfig.h(14)),
        _InlineActionButton(
          label: 'Retry',
          onTap: () => _load(initial: true),
        ),
      ],
    );
  }

  Widget _buildEmptyState(TextTheme textTheme) {
    final label = _activeFilter == BookingFilter.upcoming ? 'upcoming' : 'past';
    return Column(
      key: ValueKey('empty-$label'),
      children: [
        SizedBox(height: SizeConfig.h(18)),
        Icon(Icons.event_busy_outlined, size: 28, color: const Color(0xFF494949)),
        SizedBox(height: SizeConfig.h(10)),
        Text(
          'No $label bookings found',
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF2B2B2B),
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: SizeConfig.h(6)),
        Text(
          'Your sessions will appear here once available.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF5A5A5A),
          ),
        ),
        const Divider(height: 32, thickness: 1, color: Colors.black12),
      ],
    );
  }

  String _formatDate(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[value.month - 1]} ${value.day.toString().padLeft(2, '0')}, ${value.year}';
  }
}

class _MembershipDateBlock extends StatelessWidget {
  const _MembershipDateBlock({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFAFAFAF),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFF1E6C8),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _BookingLineItem extends StatelessWidget {
  const _BookingLineItem({
    required this.booking,
    required this.textTheme,
  });

  final BookingItem booking;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(booking.status);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConfig.h(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.title,
                      style: textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF232323),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (booking.subtitle != null) ...[
                      SizedBox(height: SizeConfig.h(4)),
                      Text(
                        booking.subtitle!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF4A4A4A),
                        ),
                      ),
                    ],
                    SizedBox(height: SizeConfig.h(12)),
                    Wrap(
                      spacing: SizeConfig.w(16),
                      runSpacing: SizeConfig.h(6),
                      children: [
                        _metaLine(Icons.sell_outlined, _kindLabel(booking.kind)),
                        _metaLine(Icons.calendar_today_outlined, _formatDateTime(booking.start)),
                        if (booking.location != null) _metaLine(Icons.place_outlined, booking.location!),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: SizeConfig.w(14)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusPill(style: statusStyle),
                  SizedBox(height: SizeConfig.h(12)),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booking ${booking.id} details coming soon.')),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: const Color(0xFF2F2F2F),
                    ),
                    child: Text(
                      'View details',
                      style: textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF2F2F2F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaLine(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF505050)),
        SizedBox(width: SizeConfig.w(6)),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(color: const Color(0xFF505050)),
        ),
      ],
    );
  }

  String _kindLabel(BookingKind kind) {
    switch (kind) {
      case BookingKind.service:
        return 'Service';
      case BookingKind.event:
        return 'Event';
    }
  }

  String _formatDateTime(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour12 = value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    final minute = value.minute.toString().padLeft(2, '0');
    return '${months[value.month - 1]} ${value.day}, ${value.year}  $hour12:$minute $suffix';
  }

  _StatusStyle _statusStyle(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return const _StatusStyle(
          label: 'Confirmed',
          background: Color(0xFF1F1F1F),
          text: Color(0xFFF1E6C8),
        );
      case BookingStatus.pending:
        return const _StatusStyle(
          label: 'Pending',
          background: Colors.transparent,
          text: Color(0xFF5A5A5A),
          border: Color(0xFFC8BFB3),
        );
      case BookingStatus.cancelled:
        return const _StatusStyle(
          label: 'Cancelled',
          background: Color(0xFFE5E0D8),
          text: Color(0xFF90877C),
        );
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.style});

  final _StatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(10),
        vertical: SizeConfig.h(4),
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
        border: style.border != null ? Border.all(color: style.border!, width: 0.8) : null,
      ),
      child: Text(
        style.label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: style.text,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              fontSize: 10,
            ),
      ),
    );
  }
}

class _InlineActionButton extends StatelessWidget {
  const _InlineActionButton({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2C2C2C),
        side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.w(14),
          vertical: SizeConfig.h(10),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF2C2C2C),
              letterSpacing: 0.7,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.background,
    required this.text,
    this.border,
  });

  final String label;
  final Color background;
  final Color text;
  final Color? border;
}

