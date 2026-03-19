import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_picker/src/country_service.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/widgets/header2_mobile.dart';
import 'package:owa_flutter/widgets/mobile_footer.dart';
import 'package:owa_flutter/widgets/login_section.dart';

class OWASignUpSectionMobile extends StatelessWidget {
  const OWASignUpSectionMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const OWAHeader2Mobile(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: _MobileSignUpCard(),
            ),
            OWAMobileFooter(key: UniqueKey()),
          ],
        ),
      ),
    );
  }
}

class _MobileSignUpCard extends StatelessWidget {
  const _MobileSignUpCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: colors.backgroundColor,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MobileImagePanel(),
          SizedBox(height: 28),
          _MobileLeftSignUpPanel(),
        ],
      ),
    );
  }
}

class _MobileImagePanel extends StatelessWidget {
  const _MobileImagePanel();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/discover_4.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'GET STARTED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Basier Square Mono',
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Already have an Account?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Basier Square Mono',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  _MobileRightPanelButton(text: 'LOG IN'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileLeftSignUpPanel extends StatelessWidget {
  const _MobileLeftSignUpPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      color: colors.backgroundColor,
      child: const _MobileSignUpForm(),
    );
  }
}

class _MobileSignUpForm extends StatefulWidget {
  const _MobileSignUpForm();

  @override
  State<_MobileSignUpForm> createState() => _MobileSignUpFormState();
}

class _MobileSignUpFormState extends State<_MobileSignUpForm> {
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
                width: 92,
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
                      (v) =>
                          (v == null || v.trim().isEmpty) ? "Required" : null,
                ),
              ),
              const SizedBox(width: 10),
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
                      (v) =>
                          (v == null || v.trim().isEmpty) ? "Required" : null,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CREATE YOUR ACCOUNT",
            style: TextStyle(
              fontFamily: 'Basier Square Mono',
              fontWeight: FontWeight.w400,
              fontSize: 24,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Fill in your details to access your dashboard.",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 18),
          _field("First name", _firstName),
          _field("Last name", _lastName),
          _field("Email", _email),
          _field("Password", _password, obscure: true),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "GENDER",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: _gender,
                  dropdownColor: colors.backgroundColor,
                  borderRadius: BorderRadius.zero,
                  decoration: _dec(),
                  items: const [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female")),
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
          _field("Birthday", _birthday, onTap: _selectBirthday),
          _phoneField(),
          _field(
            "Country of origin",
            _countryOrigin,
            onTap: () => _selectCountry(_countryOrigin),
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Color(0xFF2C2C2C),
            ),
          ),
          _field(
            "Country of residence",
            _countryResidence,
            onTap:
                () => _selectCountry(_countryResidence, updatePhoneCode: true),
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 14),
          const Text("ADDRESS", style: TextStyle(fontWeight: FontWeight.w800)),
          _field("Line 1", _line1),
          _field("Line 2", _line2),
          _field("City", _city),
          _field("State", _state),
          _field("Postal code", _postal),
          const SizedBox(height: 24),
          Center(
            child: _MobileSignUpButton(
              text: "SIGN UP",
              onTap: () {
                if (_formKey.currentState?.validate() ?? false) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Form Valid")));
                }
              },
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OWALoginSection()),
                );
              },
              child: const Text(
                'Already a member? Log In',
                style: TextStyle(
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  color: Color(0xFF2C2C2C),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileSignUpButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const _MobileSignUpButton({
    this.text = 'SIGN UP',
    this.onTap,
    this.backgroundColor = Colors.transparent,
    this.borderColor = const Color(0xFF2C2C2C),
    this.textColor = const Color(0xFF2C2C2C),
    super.key,
  });

  @override
  State<_MobileSignUpButton> createState() => _MobileSignUpButtonState();
}

class _MobileSignUpButtonState extends State<_MobileSignUpButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          border: Border.all(color: widget.borderColor, width: 1),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontSize: 14,
            letterSpacing: 1.2,
            color: widget.textColor,
          ),
        ),
      ),
    );
  }
}

class _MobileRightPanelButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const _MobileRightPanelButton({
    this.text = 'LOG IN',
    this.onTap,
    this.backgroundColor = Colors.transparent,
    this.borderColor = Colors.white,
    this.textColor = Colors.white,
    super.key,
  });

  @override
  State<_MobileRightPanelButton> createState() =>
      _MobileRightPanelButtonState();
}

class _MobileRightPanelButtonState extends State<_MobileRightPanelButton> {
  void _goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OWALoginSection()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? () => _goToLogin(context),
      child: Container(
        width: 180,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          border: Border.all(color: widget.borderColor, width: 1),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontSize: 13,
            letterSpacing: 1.2,
            color: widget.textColor,
          ),
        ),
      ),
    );
  }
}

Future<Country?> showCenteredCountryPicker(
  BuildContext context, {
  String title = 'Search country',
  bool showPhoneCode = false,
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
    this.showPhoneCode = false,
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

      _filteredCountries =
          _allCountries.where((country) {
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

    final dialogHeight = screenHeight * 0.72;
    final dialogWidth = screenWidth * 0.92;

    return Material(
      color: Colors.transparent,
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
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  itemCount: _filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = _filteredCountries[index];

                    return InkWell(
                      onTap: () => Navigator.of(context).pop(country),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        child:
                            widget.showPhoneCode
                                ? Row(
                                  children: [
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
                                )
                                : Text(
                                  country.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF2C2C2C),
                                  ),
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

  return showDatePicker(
    context: context,
    initialDate: init,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      );
    },
  );
}
