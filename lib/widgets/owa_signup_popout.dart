import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:owa_flutter/dashboard_service.dart';
import 'package:owa_flutter/models/popup_submission.dart';
import 'package:flutter_svg/svg.dart';
import 'package:owa_flutter/widgets/premium_calendar_dialog.dart'; // Necesario para HapticFeedback

// =============================================================================
// 1. MAIN SIGNUP POPOUT (ENTRY POINT)
// =============================================================================

Future<void> showOwaSignupPopout(BuildContext context, {ImageProvider? image}) {
  return showGeneralDialog(
    context: context,
    useRootNavigator: true,
    barrierLabel: 'Close',
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.30),
    transitionDuration: const Duration(milliseconds: 760),
    pageBuilder: (ctx, a1, a2) {
      return MediaQuery(
        data: MediaQuery.of(
          ctx,
        ).copyWith(textScaler: const TextScaler.linear(1.0)),
        child: SafeArea(
          child: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(ctx, rootNavigator: true).pop(),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: const SizedBox.expand(),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: OwaSignupPopout(
                    image: const AssetImage('assets/hero_right.png'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
    transitionBuilder: (ctx, anim, _, child) {
      final luxuryCurve = CurvedAnimation(
        parent: anim,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeInOutCubic,
      );

      return FadeTransition(
        opacity: luxuryCurve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.012),
            end: Offset.zero,
          ).animate(luxuryCurve),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.992, end: 1.0).animate(luxuryCurve),
            child: child,
          ),
        ),
      );
    },
  );
}

// =============================================================================
// 2. FORM STATE ENUM
// =============================================================================

enum _FormStatus { idle, loading, success, error }

// =============================================================================
// 3. MAIN FORM WIDGET
// =============================================================================

class OwaSignupPopout extends StatefulWidget {
  const OwaSignupPopout({super.key, required this.image});
  final ImageProvider image;

  @override
  State<OwaSignupPopout> createState() => _OwaSignupPopoutState();
}

class _OwaSignupPopoutState extends State<OwaSignupPopout>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _birth = TextEditingController();
  String? _gender;

  _FormStatus _status = _FormStatus.idle;
  String? _errorMessage;

  late final AnimationController _feedbackAnim;
  late final Animation<double> _feedbackFade;

  static const double kCardW = 900;
  static const double kCardH = 588;
  static const double kRightW = 399;
  static const double kLeftW = kCardW - kRightW;
  static const Color kBorder = Color(0x1F000000);
  static const Color kLeftBg = Color(0xFFE6E6E6);

  @override
  void initState() {
    super.initState();
    _feedbackAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _feedbackFade = CurvedAnimation(
      parent: _feedbackAnim,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _birth.dispose();
    _feedbackAnim.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context, rootNavigator: true).pop();

  Future<void> _submit() async {
    if (_status == _FormStatus.loading) return;

    // Basic client-side check
    if (_email.text.trim().isEmpty || _gender == null || _birth.text.isEmpty) {
      setState(() {
        _status = _FormStatus.error;
        _errorMessage = 'Please fill in all fields before submitting.';
      });
      _feedbackAnim.forward(from: 0);
      return;
    }

    setState(() {
      _status = _FormStatus.loading;
      _errorMessage = null;
    });

    final service = OWADashboardService();

    try {
      await service.submitPopup(
        PopupSubmission(
          email: _email.text.trim(),
          gender: _gender ?? '',
          birthDate: _birth.text,
        ),
      );

      if (!mounted) return;
      setState(() => _status = _FormStatus.success);
      _feedbackAnim.forward(from: 0);

      // Auto-close after the user reads the confirmation
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) _close();
    } on OWAValidationException {
      if (!mounted) return;
      setState(() {
        _status = _FormStatus.error;
        _errorMessage = 'Please check your information and try again.';
      });
      _feedbackAnim.forward(from: 0);
    } on OWADashboardException catch (e) {
      if (!mounted) return;
      setState(() {
        _status = _FormStatus.error;
        _errorMessage =
            e.statusCode == 409
                ? 'This email is already registered with us.'
                : 'Something went wrong. Please try again in a moment.';
      });
      _feedbackAnim.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;
    final maxW = s.width * 0.96;
    final maxH = s.height * 0.92;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
          child: LayoutBuilder(
            builder: (context, c) {
              final scaleW = c.maxWidth / kCardW;
              final scaleH = c.maxHeight / kCardH;
              var scale = math.min(1.0, math.min(scaleW, scaleH));
              scale = (scale - 0.002).clamp(0.0, 1.0);

              return SizedBox(
                width: kCardW * scale,
                height: kCardH * scale,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.center,
                    minWidth: kCardW,
                    maxWidth: kCardW,
                    minHeight: kCardH,
                    maxHeight: kCardH,
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: kCardW,
                        height: kCardH,
                        child: _card(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _card() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            blurRadius: 40,
            offset: const Offset(0, 20),
            color: Colors.black.withOpacity(0.2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 501,
                child: SizedBox(width: kLeftW, child: _leftPanel()),
              ),
              Flexible(
                flex: 399,
                child: SizedBox(width: kRightW, child: _rightPanel()),
              ),
            ],
          ),
          // Success overlay — fades in over the entire card
          if (_status == _FormStatus.success)
            FadeTransition(opacity: _feedbackFade, child: _successOverlay()),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUCCESS OVERLAY
  // ---------------------------------------------------------------------------

  Widget _successOverlay() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '✦',
              style: TextStyle(
                fontFamily: 'Basier Square Mono',
                fontSize: 28,
                color: Colors.white,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "YOU'RE IN.",
              style: TextStyle(
                fontFamily: 'Basier Square Mono',
                fontSize: 32,
                color: Colors.white,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Welcome to the community.\nExpect something worth opening.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Arbeit',
                fontWeight: FontWeight.w300,
                fontSize: 13,
                height: 1.7,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LEFT PANEL
  // ---------------------------------------------------------------------------

  Widget _leftPanel() {
    return Container(
      color: kLeftBg,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 472,
                child: Text(
                  'MODERN TRAINING GROUND\nFOR BEING HUMAN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Basier Square Mono',
                    fontSize: 30.4,
                    height: 1.25,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(
                width: 314,
                child: Text(
                  'NOTHING EXTRA. NOTHING SUPERFICIAL.\nJUST SCIENCE-DRIVEN WELLBEING, COMMUNITY,\nAND PRACTICE. JOIN TO RECEIVE UPDATES AND\nMEMBER BENEFITS.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Arbeit',
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 361,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildField(
                        'Email Address',
                        TextFormField(
                          controller: _email,
                          enabled: _status != _FormStatus.loading,
                          style: const TextStyle(
                            fontFamily: 'Arbeit',
                            fontSize: 12,
                          ),
                          decoration: _inputDeco(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildField(
                        'Gender',
                        DropdownButtonFormField<String>(
                          value: _gender,
                          decoration: _inputDeco(),
                          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                          items:
                              ['Female', 'Male', 'Other']
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              _status == _FormStatus.loading
                                  ? null
                                  : (v) => setState(() => _gender = v),
                          style: const TextStyle(
                            fontFamily: 'Arbeit',
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildField(
                        'Birth Date',
                        TextFormField(
                          controller: _birth,
                          readOnly: true,
                          enabled: _status != _FormStatus.loading,
                          onTap: _pickDate,
                          style: const TextStyle(
                            fontFamily: 'Arbeit',
                            fontSize: 12,
                          ),
                          decoration: _inputDeco(),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // ── Error message ──────────────────────────────────────
                      if (_status == _FormStatus.error && _errorMessage != null)
                        FadeTransition(
                          opacity: _feedbackFade,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '— ',
                                  style: TextStyle(
                                    fontFamily: 'Basier Square Mono',
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      fontFamily: 'Arbeit',
                                      fontSize: 11,
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // ── Submit button ──────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 51,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color:
                                  _status == _FormStatus.loading
                                      ? Colors.black38
                                      : Colors.black,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            overlayColor: Colors.black.withOpacity(0.1),
                          ),
                          onPressed:
                              _status == _FormStatus.loading ? null : _submit,
                          child:
                              _status == _FormStatus.loading
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Colors.black54,
                                    ),
                                  )
                                  : const Text(
                                    'SUBMIT',
                                    style: TextStyle(
                                      fontFamily: 'Basier Square Mono',
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Text(
                        'By submitting this form, you consent to receive marketing messages from OWA.\nUnsubscribe at any time. Privacy Policy & Terms.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Arbeit',
                          fontSize: 8,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RIGHT PANEL
  // ---------------------------------------------------------------------------

  Widget _rightPanel() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(
          image: widget.image,
          fit: BoxFit.cover,
          alignment: const Alignment(0.85, 0),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: GestureDetector(
            onTap: _close,
            child: SvgPicture.asset(
              'assets/icons/close.svg',
              fit: BoxFit.fitWidth,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(Color(0x73FFFFFF), BlendMode.srcIn),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  Widget _buildField(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Arbeit',
            fontSize: 12,
            color: Colors.black.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDeco() => InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.only(bottom: 8),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black.withOpacity(0.2)),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
  );

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_birth.text);
    final d = await showOwaCalendarPicker(
      context,
      initial: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _birth.text = d.toString().split(' ')[0]);
  }
}

// =============================================================================
// 4. PREMIUM OWA CALENDAR COMPONENT (LUXURY EDITORIAL STYLE)
// =============================================================================

Future<DateTime?> showOwaCalendarPicker(
  BuildContext context, {
  DateTime? initial,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  final now = DateTime.now();
  final init = initial ?? DateTime(now.year, now.month, now.day);

  return showGeneralDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (ctx, anim1, anim2) => const SizedBox(),
    transitionBuilder: (ctx, anim1, anim2, child) {
      final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutQuart);
      return ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(curve),
        child: FadeTransition(
          opacity: curve,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: PremiumCalendarDialog(
                initial: init,
                firstDate: firstDate,
                lastDate: lastDate,
              ),
            ),
          ),
        ),
      );
    },
  );
}
