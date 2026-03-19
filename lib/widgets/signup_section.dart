import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_picker/src/country_service.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/widgets/header2.dart';
import 'package:owa_flutter/widgets/footer_section.dart';
import 'package:owa_flutter/widgets/login_section.dart';
import 'package:owa_flutter/widgets/signup_section_mobile.dart';
import 'package:owa_flutter/useful/is_desktop_from_context.dart';

class OWASignUpSection extends StatelessWidget {
  const OWASignUpSection({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isDesktopFromContext(context)) {
      return const OWASignUpSectionMobile();
    }

    return Material(
      color: colors.backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const OWAHeader2(),
            Container(
              width: SizeConfig.w(1440),
              color: colors.backgroundColor,
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.w(42),
                vertical: SizeConfig.h(40),
              ),
              child: const _SignUpCard(),
            ),
            OWAFooter(key: UniqueKey()),
          ],
        ),
      ),
    );
  }
}

class _SignUpCard extends StatelessWidget {
  const _SignUpCard();

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double cardHeight = math.max(screenHeight * 0.95, 930);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: SizedBox(
          height: cardHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Expanded(flex: 11, child: _LeftSignUpPanel()),
              SizedBox(width: 24),
              Expanded(flex: 9, child: _RightImagePanel()),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeftSignUpPanel extends StatelessWidget {
  const _LeftSignUpPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const _SignUpForm(),
    );
  }
}

class _RightImagePanel extends StatelessWidget {
  const _RightImagePanel();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/discover_4.jpg', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.35)),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GET STARTED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Basier Square Mono',
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Already have an Account?',
                style: TextStyle(
                  fontFamily: 'Basier Square Mono',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _RightPanelButton(text: 'LOG IN'),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm();

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _birthday = TextEditingController();
  final _phone = TextEditingController();
  final _phoneCodeController = TextEditingController(text: '+1');
  final _countryOrigin = TextEditingController();
  final _countryResidence = TextEditingController();
  final _line1 = TextEditingController();
  final _line2 = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _postal = TextEditingController();

  String _gender = "Male";
  String _phoneCode = "+1";

  InputDecoration _dec() => const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.only(bottom: 8),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFBDBDBD)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF2C2C2C), width: 1.5),
        ),
      );

  Widget _field(
    String label,
    TextEditingController ctrl, {
    bool obscure = false,
    int lines = 1,
    VoidCallback? onTap,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: ctrl,
            obscureText: obscure,
            maxLines: lines,
            readOnly: onTap != null,
            onTap: onTap,
            inputFormatters: inputFormatters,
            textAlignVertical: TextAlignVertical.bottom,
            decoration: _dec().copyWith(suffixIcon: suffixIcon),
            validator:
                (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
          ),
        ],
      ),
    );
  }

  Widget _phoneField() {
    const inputTextStyle = TextStyle(
      fontSize: 14,
      color: Color(0xFF2C2C2C),
      height: 1.2,
    );

    final baseDecoration = _dec().copyWith(
      isDense: true,
      contentPadding: const EdgeInsets.only(bottom: 8),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PHONE NUMBER",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 108,
                child: TextFormField(
                  controller: _phoneCodeController,
                  readOnly: true,
                  onTap: _selectPhoneCode,
                  style: inputTextStyle,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: baseDecoration.copyWith(
                    suffixIcon: const Padding(
                      padding: EdgeInsets.only(left: 6, bottom: 1),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                  ),
                  validator:
                      (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _phone,
                  style: inputTextStyle,
                  keyboardType: TextInputType.phone,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: baseDecoration,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\s()]')),
                  ],
                  validator:
                      (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-"
      "${d.month.toString().padLeft(2, '0')}-"
      "${d.day.toString().padLeft(2, '0')}";

  Future<void> _selectCountry(
    TextEditingController controller, {
    bool updatePhoneCode = false,
  }) async {
    final selected = await showCenteredCountryPicker(
      context,
      title: 'Search country',
      showPhoneCode: false,
    );

    if (selected == null) return;

    controller.text = selected.name;

    if (updatePhoneCode) {
      setState(() {
        _phoneCode = '+${selected.phoneCode}';
        _phoneCodeController.text = _phoneCode;
      });
    }
  }

  Future<void> _selectPhoneCode() async {
    final selected = await showCenteredCountryPicker(
      context,
      title: 'Search phone code',
      showPhoneCode: true,
    );

    if (selected == null) return;

    setState(() {
      _phoneCode = '+${selected.phoneCode}';
      _phoneCodeController.text = _phoneCode;
    });
  }

  Future<void> _selectBirthday() async {
    final initial = DateTime.tryParse(_birthday.text);

    final picked = await showOwaCalendarPicker(
      context,
      initial: initial ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _birthday.text = _formatDate(picked);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _birthday.dispose();
    _phone.dispose();
    _phoneCodeController.dispose();
    _countryOrigin.dispose();
    _countryResidence.dispose();
    _line1.dispose();
    _line2.dispose();
    _city.dispose();
    _state.dispose();
    _postal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(0, -32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "CREATE YOUR ACCOUNT",
                        style: TextStyle(
                          fontFamily: 'Basier Square Mono',
                          fontWeight: FontWeight.w400,
                          fontSize: 30.4,
                          color: Colors.black,
                          letterSpacing: 0,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text("Fill in your details to access your dashboard."),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _field("First name", _firstName)),
                    const SizedBox(width: 12),
                    Expanded(child: _field("Last name", _lastName)),
                  ],
                ),
                _field("Email", _email),
                _field("Password", _password, obscure: true),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "GENDER",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: _gender,
                              dropdownColor: colors.backgroundColor,
                              borderRadius: BorderRadius.zero,
                              decoration: _dec(),
                              items: const [
                                DropdownMenuItem(
                                  value: "Male",
                                  child: Text("Male"),
                                ),
                                DropdownMenuItem(
                                  value: "Female",
                                  child: Text("Female"),
                                ),
                                DropdownMenuItem(
                                  value: "Non-Disclosed",
                                  child: Text("Non-Disclosed"),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _gender = value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        "Birthday",
                        _birthday,
                        onTap: _selectBirthday,
                      ),
                    ),
                  ],
                ),
                _phoneField(),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        "Country of origin",
                        _countryOrigin,
                        onTap: () => _selectCountry(_countryOrigin),
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        "Country of residence",
                        _countryResidence,
                        onTap: () => _selectCountry(
                          _countryResidence,
                          updatePhoneCode: true,
                        ),
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "ADDRESS",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                _field("Line 1", _line1),
                _field("Line 2", _line2),
                Row(
                  children: [
                    Expanded(child: _field("City", _city)),
                    const SizedBox(width: 12),
                    Expanded(child: _field("State", _state)),
                  ],
                ),
                _field("Postal code", _postal),
                const Spacer(),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LoginImageButton(
                        text: "SIGN UP",
                        onTap: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Form Valid")),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LoginImageButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color textHoverColor;
  final Color hoverBackgroundColor;

  const _LoginImageButton({
    this.text = 'SIGN UP',
    this.onTap,
    this.backgroundColor = Colors.transparent,
    this.borderColor = const Color(0xFF2C2C2C),
    this.textColor = const Color(0xFF2C2C2C),
    this.textHoverColor = const Color(0xFF2C2C2C),
    this.hoverBackgroundColor = const Color(0x14000000),
    super.key,
  });

  @override
  State<_LoginImageButton> createState() => _LoginImageButtonState();
}

class _LoginImageButtonState extends State<_LoginImageButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          width: 220,
          height: 51,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isHovered
                ? widget.hoverBackgroundColor
                : widget.backgroundColor,
            border: Border.all(color: widget.borderColor, width: 1),
            borderRadius: BorderRadius.zero,
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontFamily: 'Basier Square Mono',
              fontSize: 14,
              letterSpacing: 1.2,
              color: isHovered ? widget.textHoverColor : widget.textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _RightPanelButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color textHoverColor;
  final Color hoverBackgroundColor;

  const _RightPanelButton({
    this.text = 'LOG IN',
    this.onTap,
    this.backgroundColor = Colors.transparent,
    this.borderColor = Colors.white,
    this.textColor = Colors.white,
    this.textHoverColor = Colors.white,
    this.hoverBackgroundColor = const Color(0x14FFFFFF),
    super.key,
  });

  @override
  State<_RightPanelButton> createState() => _RightPanelButtonState();
}

class _RightPanelButtonState extends State<_RightPanelButton> {
  bool isHovered = false;

  void _goToLogin(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OWALoginSection()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap ?? () => _goToLogin(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          width: 220,
          height: 51,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isHovered
                ? widget.hoverBackgroundColor
                : widget.backgroundColor,
            border: Border.all(color: widget.borderColor, width: 1),
            borderRadius: BorderRadius.zero,
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontFamily: 'Basier Square Mono',
              fontSize: 14,
              letterSpacing: 1.2,
              color: isHovered ? widget.textHoverColor : widget.textColor,
            ),
          ),
        ),
      ),
    );
  }
}

Future<Country?> showCenteredCountryPicker(
  BuildContext context, {
  String title = 'Search country',
  bool showPhoneCode = true,
}) {
  return showGeneralDialog<Country>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withOpacity(0.28),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, __, ___) => const SizedBox(),
    transitionBuilder: (_, animation, __, ___) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
          child: Center(
            child: _CenteredCountryPickerDialog(
              title: title,
              showPhoneCode: showPhoneCode,
            ),
          ),
        ),
      );
    },
  );
}

class _CenteredCountryPickerDialog extends StatefulWidget {
  final String title;
  final bool showPhoneCode;

  const _CenteredCountryPickerDialog({
    required this.title,
    this.showPhoneCode = true,
  });

  @override
  State<_CenteredCountryPickerDialog> createState() =>
      _CenteredCountryPickerDialogState();
}

class _CenteredCountryPickerDialogState
    extends State<_CenteredCountryPickerDialog> {
  final TextEditingController _searchController = TextEditingController();

  late final List<Country> _allCountries;
  List<Country> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _allCountries = CountryService().getAll();
    _filteredCountries = List<Country>.from(_allCountries);
    _searchController.addListener(_applyFilter);
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredCountries = List<Country>.from(_allCountries);
        return;
      }

      _filteredCountries = _allCountries.where((country) {
        final name = country.name.toLowerCase();
        final code = country.countryCode.toLowerCase();
        final phone = country.phoneCode.toLowerCase();
        return name.contains(query) ||
            code.contains(query) ||
            phone.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_applyFilter)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final originalHeight = screenHeight * 0.50;
    final extraTop = originalHeight * 0.20;
    final extraBottom = originalHeight * 0.15;
    final dialogHeight = originalHeight + extraTop + extraBottom;
    final verticalShift = -(extraTop - extraBottom) / 2;

    final dialogWidth = screenWidth > 1200
        ? 640.0
        : screenWidth > 900
            ? screenWidth * 0.56
            : screenWidth * 0.88;

    return Material(
      color: Colors.transparent,
      child: Transform.translate(
        offset: Offset(0, verticalShift),
        child: Container(
          width: dialogWidth,
          height: dialogHeight,
          decoration: BoxDecoration(
            color: colors.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: widget.title,
                    prefixIcon: const Icon(Icons.search),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFBDBDBD)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF2C2C2C),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    itemCount: _filteredCountries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];

                      return InkWell(
                        onTap: () => Navigator.of(context).pop(country),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              if (widget.showPhoneCode)
                                SizedBox(
                                  width: 64,
                                  child: Text(
                                    '+${country.phoneCode}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF2C2C2C),
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  country.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF2C2C2C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
              child: _PremiumCalendarDialog(
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

class _PremiumCalendarDialog extends StatefulWidget {
  const _PremiumCalendarDialog({
    required this.initial,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initial;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_PremiumCalendarDialog> createState() => _PremiumCalendarDialogState();
}

class _PremiumCalendarDialogState extends State<_PremiumCalendarDialog> {
  late DateTime _selected;

  static const String fontMono = 'Basier Square Mono';
  static const String fontBody = 'Arbeit';

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  void _onDateChanged(DateTime date) {
    HapticFeedback.selectionClick();
    setState(() => _selected = date);
  }

  void _close() => Navigator.of(context).pop();
  void _apply() => Navigator.of(context).pop(_selected);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      colorScheme: const ColorScheme.light(
        primary: Colors.black,
        onPrimary: Colors.white,
        onSurface: Colors.black,
        surface: Colors.white,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.black,
          textStyle: const TextStyle(
            fontFamily: fontMono,
            fontSize: 13,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );

    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 50,
            spreadRadius: -10,
            offset: const Offset(0, 30),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCustomHeader(),
          Theme(
            data: theme.copyWith(
              datePickerTheme: DatePickerThemeData(
                backgroundColor: Colors.white,
                headerBackgroundColor: Colors.white,
                headerForegroundColor: Colors.black,
                surfaceTintColor: Colors.transparent,
                dividerColor: Colors.transparent,
                dayStyle: const TextStyle(
                  fontFamily: fontBody,
                  fontSize: 13,
                  color: Colors.black,
                ),
                weekdayStyle: const TextStyle(
                  fontFamily: fontMono,
                  fontSize: 10,
                  letterSpacing: 2.0,
                  color: Colors.black45,
                  fontWeight: FontWeight.w400,
                ),
                yearStyle: const TextStyle(
                  fontFamily: fontBody,
                  fontSize: 14,
                  color: Colors.black,
                ),
                headerHeadlineStyle: const TextStyle(fontSize: 14),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                dayShape: const WidgetStatePropertyAll(CircleBorder()),
                dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF4A4A4A);
                  }
                  return null;
                }),
                dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return Colors.black;
                }),
              ),
            ),
            child: SizedBox(
              height: 320,
              child: CalendarDatePicker(
                initialDate: _selected,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                onDateChanged: _onDateChanged,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 10, 28, 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _close,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black38,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: const Text('CLOSE'),
                ),
                ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    textStyle: const TextStyle(
                      fontFamily: fontMono,
                      fontSize: 11,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('CONFIRM'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    final months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];

    final month = months[_selected.month - 1];
    final day = _selected.day.toString().padLeft(2, '0');
    final year = _selected.year;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 4, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                'SELECTED DATE',
                style: TextStyle(
                  fontFamily: fontMono,
                  fontSize: 9,
                  letterSpacing: 3.0,
                  color: Colors.black.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                day,
                style: const TextStyle(
                  fontFamily: 'Arbeit',
                  fontSize: 72,
                  height: 0.8,
                  fontWeight: FontWeight.w100,
                  color: Colors.black,
                  letterSpacing: -2.0,
                ),
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      month,
                      style: const TextStyle(
                        fontFamily: fontMono,
                        fontSize: 14,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$year',
                      style: TextStyle(
                        fontFamily: fontMono,
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}