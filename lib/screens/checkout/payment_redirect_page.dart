import 'dart:async';

import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/size_config.dart';

enum RedirectStatus { successful, pending, rejected, cancelled }
enum RedirectPaymentMethod { card, transfer, cash, unknown }

const Duration kPendingPollInterval = Duration(seconds: 4);
const int kPendingMaxAttempts = 5;
const bool kPendingAutoResolveToSuccess = true;
const int kPendingSuccessAttempt = 3;

class PaymentRedirectPage extends StatefulWidget {
  const PaymentRedirectPage({
    super.key,
    this.routeName,
    this.routeArguments,
  });

  final String? routeName;
  final Object? routeArguments;

  @override
  State<PaymentRedirectPage> createState() => _PaymentRedirectPageState();
}

class _PaymentRedirectPageState extends State<PaymentRedirectPage> {
  bool _isPreparing = true;
  bool _showBanner = false;
  bool _isRefreshing = false;
  bool _isNavigating = false;
  RedirectStatus _status = RedirectStatus.pending;
  RedirectPaymentMethod _paymentMethod = RedirectPaymentMethod.unknown;
  String _message = 'Payment pending.';
  String? _referenceId;
  int _pollAttempt = 0;

  Timer? _prepareTimer;
  Timer? _pollTimer;
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _resolveParams();
    _prepareTimer = Timer(const Duration(milliseconds: 780), () {
      if (!mounted) return;
      setState(() {
        _isPreparing = false;
        _showBanner = true;
      });
      _syncStatusSideEffects();
    });
  }

  @override
  void dispose() {
    _prepareTimer?.cancel();
    _pollTimer?.cancel();
    _redirectTimer?.cancel();
    super.dispose();
  }

  void _resolveParams() {
    final fromUriBase = Uri.base.queryParameters;
    final fromRouteName = _queryParamsFromRouteName(widget.routeName);
    final fromArguments = _mapFromArguments(widget.routeArguments);

    final merged = <String, String>{}
      ..addAll(fromUriBase)
      ..addAll(fromRouteName)
      ..addAll(fromArguments);

    final statusRaw = (merged['status'] ?? 'pending').toLowerCase();
    final parsedStatus = _statusFromString(statusRaw);
    final paymentMethodRaw = (merged['paymentMethod'] ?? '').toLowerCase();
    final providedMessage = merged['message']?.trim();
    final reference = merged['transactionId'] ?? merged['bookingId'];

    _status = parsedStatus;
    _paymentMethod = _paymentMethodFromString(paymentMethodRaw);
    _message = (providedMessage == null || providedMessage.isEmpty)
        ? _defaultMessageFor(parsedStatus)
        : providedMessage;
    _referenceId = (reference == null || reference.trim().isEmpty)
        ? null
        : reference.trim();
  }

  Map<String, String> _queryParamsFromRouteName(String? routeName) {
    if (routeName == null || !routeName.startsWith('/redirect')) {
      return const {};
    }
    try {
      final uri = Uri.parse(routeName);
      return uri.queryParameters;
    } catch (_) {
      return const {};
    }
  }

  Map<String, String> _mapFromArguments(Object? arguments) {
    if (arguments is! Map) return const {};
    final mapped = <String, String>{};
    for (final entry in arguments.entries) {
      final key = entry.key?.toString();
      final value = entry.value?.toString();
      if (key == null || value == null) continue;
      mapped[key] = value;
    }
    return mapped;
  }

  RedirectStatus _statusFromString(String raw) {
    switch (raw) {
      case 'successful':
        return RedirectStatus.successful;
      case 'rejected':
        return RedirectStatus.rejected;
      case 'cancelled':
        return RedirectStatus.cancelled;
      default:
        return RedirectStatus.pending;
    }
  }

  String _defaultMessageFor(RedirectStatus status) {
    switch (status) {
      case RedirectStatus.successful:
        return 'Payment confirmed.';
      case RedirectStatus.pending:
        return 'Payment pending.';
      case RedirectStatus.rejected:
        return 'Payment rejected.';
      case RedirectStatus.cancelled:
        return 'Payment cancelled.';
    }
  }

  void _syncStatusSideEffects() {
    _pollTimer?.cancel();
    _redirectTimer?.cancel();

    if (_status == RedirectStatus.pending) {
      _startPendingPolling();
      return;
    }

    if (_status == RedirectStatus.successful) {
      _scheduleRedirectToBookings();
    }
  }

  void _startPendingPolling() {
    _pollTimer = Timer.periodic(kPendingPollInterval, (_) {
      _performPendingCheck();
    });
  }

  Future<void> _performPendingCheck() async {
    if (!mounted || _isRefreshing || _status != RedirectStatus.pending) return;
    if (_pollAttempt >= kPendingMaxAttempts) return;

    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    _pollAttempt += 1;

    if (kPendingAutoResolveToSuccess && _pollAttempt >= kPendingSuccessAttempt) {
      setState(() {
        _status = RedirectStatus.successful;
        _message = 'Payment confirmed.';
        _isRefreshing = false;
      });
      _syncStatusSideEffects();
      return;
    }

    setState(() {
      _message = _pollAttempt >= kPendingMaxAttempts
          ? 'Payment is still pending. Please try again shortly.'
          : 'Checking payment status...';
      _isRefreshing = false;
    });
  }

  void _scheduleRedirectToBookings() {
    if (_isNavigating) return;
    _isNavigating = true;
    _redirectTimer = Timer(const Duration(milliseconds: 1200), () async {
      if (!mounted) return;
      try {
        await Navigator.of(context).pushNamed('/profile/bookings');
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Destination /profile/bookings is not available yet.'),
          ),
        );
      } finally {
        _isNavigating = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = _statusScheme(_status);

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _showBanner ? 1 : 0,
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOutCubic,
              child: Container(
                color: const Color(0xFF1E1E1E).withValues(alpha: 0.09),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(24)),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 820),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInOutCubic,
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                      );
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    child: _isPreparing
                        ? _buildLoaderCard(textTheme)
                        : _buildFlashCard(textTheme, scheme),
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: !_isRefreshing,
            child: AnimatedOpacity(
              opacity: _isRefreshing ? 1 : 0,
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeInOutCubic,
              child: Container(
                color: const Color(0xFF1B1B1B).withValues(alpha: 0.12),
                alignment: Alignment.center,
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(31),
                    border: Border.all(color: const Color(0xFFC9C0B5)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.1,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F2F2F)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoaderCard(TextTheme textTheme) {
    return Container(
      key: const ValueKey('loader-card'),
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(30),
        vertical: SizeConfig.h(26),
      ),
      decoration: BoxDecoration(
        color: colors.membershipsBackgroundColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8BFB4), width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.1,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F2F2F)),
            ),
          ),
          SizedBox(width: SizeConfig.w(14)),
          Text(
            'Finalizing payment status...',
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF2F2F2F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashCard(TextTheme textTheme, _StatusScheme scheme) {
    if (_status == RedirectStatus.pending) {
      return _buildPendingCenteredState(textTheme);
    }

    return AnimatedSlide(
      key: ValueKey('flash-${_status.name}'),
      duration: const Duration(milliseconds: 620),
      curve: Curves.easeInOutCubic,
      offset: _showBanner ? Offset.zero : const Offset(0, 0.04),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 620),
        curve: Curves.easeOutCubic,
        opacity: _showBanner ? 1 : 0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 620),
          curve: Curves.easeInOutCubic,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.w(26),
            vertical: SizeConfig.h(24),
          ),
          decoration: BoxDecoration(
            color: scheme.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.border, width: 0.9),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF000000).withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 620),
                    curve: Curves.easeInOutCubic,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: scheme.iconBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(scheme.icon, size: 23, color: scheme.iconColor),
                  ),
                  SizedBox(width: SizeConfig.w(14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scheme.title,
                          style: textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF232323),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(6)),
                        Text(
                          _message,
                          style: textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF383838),
                            height: 1.35,
                          ),
                        ),
                        if (_referenceId != null) ...[
                          SizedBox(height: SizeConfig.h(10)),
                          Text(
                            'Reference: $_referenceId',
                            style: textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF5C5C5C),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.h(18)),
              Wrap(
                spacing: SizeConfig.w(10),
                runSpacing: SizeConfig.h(10),
                children: [
                  _ActionButton(
                    label: 'Go to My Bookings',
                    onTap: _isRefreshing
                        ? null
                        : () => Navigator.of(context).pushNamed('/profile/bookings'),
                  ),
                  if (_status == RedirectStatus.rejected ||
                      _status == RedirectStatus.cancelled)
                    _ActionButton(
                      label: 'Try again',
                      onTap: _isRefreshing
                          ? null
                          : () => Navigator.of(context).pushNamed('/checkout'),
                      isSecondary: true,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  RedirectPaymentMethod _paymentMethodFromString(String raw) {
    switch (raw) {
      case 'card':
        return RedirectPaymentMethod.card;
      case 'transfer':
        return RedirectPaymentMethod.transfer;
      case 'cash':
        return RedirectPaymentMethod.cash;
      default:
        return RedirectPaymentMethod.unknown;
    }
  }

  Widget _buildPendingCenteredState(TextTheme textTheme) {
    return SizedBox(
      key: const ValueKey('pending-centered'),
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F2F2F)),
              ),
            ),
            SizedBox(height: SizeConfig.h(32)),
            Text(
              'Payment Pending',
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF232323),
              ),
            ),
            SizedBox(height: SizeConfig.h(10)),
            Text(
              'Checking payment status...',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: const Color(0xFF4D4D4D),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: SizeConfig.h(8)),
            Text(
              _pendingMethodCopy(),
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5A5A5A),
              ),
            ),
            SizedBox(height: SizeConfig.h(16)),
            if (_referenceId != null)
              Text(
                'Reference: $_referenceId',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            SizedBox(height: SizeConfig.h(4)),
            Text(
              'Check $_pollAttempt/$kPendingMaxAttempts',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: SizeConfig.h(40)),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: SizeConfig.w(12),
              runSpacing: SizeConfig.h(12),
              children: [
                SizedBox(
                  height: SizeConfig.h(44),
                  child: ElevatedButton(
                    onPressed: _isRefreshing
                        ? null
                        : () => Navigator.of(context).pushNamed('/profile/bookings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF242424),
                      disabledBackgroundColor: const Color(0xFF4A4A4A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(18)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Go to My Bookings',
                      style: textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.h(44),
                  child: OutlinedButton(
                    onPressed: _isRefreshing ? null : _performPendingCheck,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2E2E2E),
                      side: const BorderSide(color: Color(0xFFC6BCAD), width: 0.9),
                      padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(18)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Refresh',
                      style: textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF2E2E2E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _pendingMethodCopy() {
    switch (_paymentMethod) {
      case RedirectPaymentMethod.card:
        return 'Card payment in verification.';
      case RedirectPaymentMethod.transfer:
        return 'Transfer validation in progress.';
      case RedirectPaymentMethod.cash:
        return 'Cash payment pending front desk confirmation.';
      case RedirectPaymentMethod.unknown:
        return 'Waiting for payment confirmation.';
    }
  }

  _StatusScheme _statusScheme(RedirectStatus status) {
    switch (status) {
      case RedirectStatus.successful:
        return const _StatusScheme(
          title: 'Payment Successful',
          icon: Icons.check_rounded,
          background: Color(0xFFF2F0EA),
          border: Color(0xFFBDB5A9),
          iconBackground: Color(0xFFDAD3C7),
          iconColor: Color(0xFF242424),
        );
      case RedirectStatus.pending:
        return const _StatusScheme(
          title: 'Payment Pending',
          icon: Icons.schedule_rounded,
          background: Color(0xFFF4F1EB),
          border: Color(0xFFC4BCAF),
          iconBackground: Color(0xFFE1D9CB),
          iconColor: Color(0xFF303030),
        );
      case RedirectStatus.rejected:
        return const _StatusScheme(
          title: 'Payment Rejected',
          icon: Icons.close_rounded,
          background: Color(0xFFF5F0EC),
          border: Color(0xFFC7B8AE),
          iconBackground: Color(0xFFE4D5CC),
          iconColor: Color(0xFF3A2C2C),
        );
      case RedirectStatus.cancelled:
        return const _StatusScheme(
          title: 'Payment Cancelled',
          icon: Icons.remove_rounded,
          background: Color(0xFFF3EFEA),
          border: Color(0xFFC5BBAD),
          iconBackground: Color(0xFFE0D5C7),
          iconColor: Color(0xFF343434),
        );
    }
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.label,
    this.onTap,
    this.isSecondary = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isSecondary;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final baseColor = widget.isSecondary ? const Color(0xFFE7DFD2) : const Color(0xFF2B2B2B);
    final hoverColor = widget.isSecondary ? const Color(0xFFDCD2C2) : const Color(0xFF343434);
    final textColor = widget.isSecondary ? const Color(0xFF2A2A2A) : Colors.white;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.w(14),
            vertical: SizeConfig.h(10),
          ),
          decoration: BoxDecoration(
            color: enabled
                ? (_isHovered ? hoverColor : baseColor)
                : baseColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isSecondary ? const Color(0xFFC9BEAF) : const Color(0xFF1E1E1E),
              width: 0.8,
            ),
          ),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: enabled ? textColor : textColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _StatusScheme {
  const _StatusScheme({
    required this.title,
    required this.icon,
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.iconColor,
  });

  final String title;
  final IconData icon;
  final Color background;
  final Color border;
  final Color iconBackground;
  final Color iconColor;
}
