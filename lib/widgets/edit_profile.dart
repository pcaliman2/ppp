import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_picker/src/country_service.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/is_desktop_from_context.dart';
import 'package:owa_flutter/widgets/header2.dart';
import 'package:owa_flutter/widgets/footer_section.dart';

class OWAEditProfile extends StatelessWidget {
  final OWAEditProfileData? initialData;
  final ValueChanged<OWAEditProfileData>? onSave;

  const OWAEditProfile({super.key, this.initialData, this.onSave});

  @override
  Widget build(BuildContext context) {
    if (!isDesktopFromContext(context)) {
      return Scaffold(
        backgroundColor: colors.backgroundColor,
        body: const SafeArea(
          child: Center(
            child: Text(
              'OWAEditProfile mobile version is not implemented yet.',
              style: TextStyle(fontSize: 16, color: Color(0xFF2C2C2C)),
            ),
          ),
        ),
      );
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
              child: _EditProfileCard(initialData: initialData, onSave: onSave),
            ),
            OWAFooter(key: UniqueKey()),
          ],
        ),
      ),
    );
  }
}

class OWAEditProfileData {
  final String firstName;
  final String lastName;
  final String gender;
  final String birthday;
  final String phoneCode;
  final String phone;
  final String countryOrigin;
  final String countryResidence;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String postalCode;

  const OWAEditProfileData({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthday,
    required this.phoneCode,
    required this.phone,
    required this.countryOrigin,
    required this.countryResidence,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
  });
}

class _EditProfileCard extends StatelessWidget {
  final OWAEditProfileData? initialData;
  final ValueChanged<OWAEditProfileData>? onSave;

  const _EditProfileCard({required this.initialData, required this.onSave});

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
            children: [
              Expanded(
                flex: 11,
                child: _LeftEditProfilePanel(
                  initialData: initialData,
                  onSave: onSave,
                ),
              ),
              const SizedBox(width: 24),
              const Expanded(flex: 9, child: _RightImagePanel()),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeftEditProfilePanel extends StatelessWidget {
  final OWAEditProfileData? initialData;
  final ValueChanged<OWAEditProfileData>? onSave;

  const _LeftEditProfilePanel({
    required this.initialData,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: _EditProfileForm(initialData: initialData, onSave: onSave),
    );
  }
}

class _RightImagePanel extends StatelessWidget {
  const _RightImagePanel();

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/discover_1.jpg', fit: BoxFit.cover);
  }
}

class _EditProfileForm extends StatefulWidget {
  final OWAEditProfileData? initialData;
  final ValueChanged<OWAEditProfileData>? onSave;

  const _EditProfileForm({required this.initialData, required this.onSave});

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _birthday;
  late final TextEditingController _phone;
  late final TextEditingController _phoneCodeController;
  late final TextEditingController _countryOrigin;
  late final TextEditingController _countryResidence;
  late final TextEditingController _line1;
  late final TextEditingController _line2;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _postal;

  late String _gender;
  late String _phoneCode;

  @override
  void initState() {
    super.initState();

    final data = widget.initialData;

    _firstName = TextEditingController(text: data?.firstName ?? '');
    _lastName = TextEditingController(text: data?.lastName ?? '');
    _birthday = TextEditingController(text: data?.birthday ?? '');
    _phone = TextEditingController(text: data?.phone ?? '');
    _phoneCode = data?.phoneCode ?? '+1';
    _phoneCodeController = TextEditingController(text: _phoneCode);
    _countryOrigin = TextEditingController(text: data?.countryOrigin ?? '');
    _countryResidence = TextEditingController(
      text: data?.countryResidence ?? '',
    );
    _line1 = TextEditingController(text: data?.line1 ?? '');
    _line2 = TextEditingController(text: data?.line2 ?? '');
    _city = TextEditingController(text: data?.city ?? '');
    _state = TextEditingController(text: data?.state ?? '');
    _postal = TextEditingController(text: data?.postalCode ?? '');
    _gender = data?.gender ?? 'Male';
  }

  InputDecoration _dec() {
    return const InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.only(bottom: 8),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFBDBDBD)),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF2C2C2C), width: 1.5),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    bool obscure = false,
    int lines = 1,
    VoidCallback? onTap,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
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
            keyboardType: keyboardType,
            textAlignVertical: TextAlignVertical.bottom,
            decoration: _dec().copyWith(suffixIcon: suffixIcon),
            validator:
                validator ??
                (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
          ),
        ],
      ),
    );
  }

  Widget _phoneField() {
    const TextStyle inputTextStyle = TextStyle(
      fontSize: 14,
      color: Color(0xFF2C2C2C),
      height: 1.2,
    );

    final InputDecoration baseDecoration = _dec().copyWith(
      isDense: true,
      contentPadding: const EdgeInsets.only(bottom: 8),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PHONE NUMBER',
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final String year = d.year.toString().padLeft(4, '0');
    final String month = d.month.toString().padLeft(2, '0');
    final String day = d.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _selectCountry(
    TextEditingController controller, {
    bool updatePhoneCode = false,
  }) async {
    final Country? selected = await showCenteredCountryPicker(
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
    final Country? selected = await showCenteredCountryPicker(
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
    final DateTime? initial = DateTime.tryParse(_birthday.text);

    final DateTime? picked = await showOwaCalendarPicker(
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

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final OWAEditProfileData result = OWAEditProfileData(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      gender: _gender,
      birthday: _birthday.text.trim(),
      phoneCode: _phoneCodeController.text.trim(),
      phone: _phone.text.trim(),
      countryOrigin: _countryOrigin.text.trim(),
      countryResidence: _countryResidence.text.trim(),
      line1: _line1.text.trim(),
      line2: _line2.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      postalCode: _postal.text.trim(),
    );

    if (widget.onSave != null) {
      widget.onSave!(result);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile changes saved')));
    }
  }

  @override
  void dispose() {
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
                        'EDIT YOUR PROFILE',
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
                      Text(
                        'Update your personal details and keep your profile information accurate.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _field('First name', _firstName)),
                    const SizedBox(width: 12),
                    Expanded(child: _field('Last name', _lastName)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GENDER',
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
                                DropdownMenuItem<String>(
                                  value: 'Male',
                                  child: Text('Male'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Female',
                                  child: Text('Female'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Non-Disclosed',
                                  child: Text('Non-Disclosed'),
                                ),
                              ],
                              onChanged: (String? value) {
                                if (value == null) return;
                                setState(() {
                                  _gender = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        'Birthday',
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
                        'Country of origin',
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
                        'Country of residence',
                        _countryResidence,
                        onTap:
                            () => _selectCountry(
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
                  'ADDRESS',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                _field('Line 1', _line1),
                _field('Line 2', _line2),
                Row(
                  children: [
                    Expanded(child: _field('City', _city)),
                    const SizedBox(width: 12),
                    Expanded(child: _field('State', _state)),
                  ],
                ),
                _field('Postal code', _postal),
                const Spacer(),
                Center(
                  child: _ProfileActionButton(
                    text: 'SAVE CHANGES',
                    onTap: _submit,
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

class _ProfileActionButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color textHoverColor;
  final Color hoverBackgroundColor;

  const _ProfileActionButton({
    super.key,
    this.text = 'SAVE CHANGES',
    this.onTap,
    this.backgroundColor = Colors.transparent,
    this.borderColor = const Color(0xFF2C2C2C),
    this.textColor = const Color(0xFF2C2C2C),
    this.textHoverColor = const Color(0xFF2C2C2C),
    this.hoverBackgroundColor = const Color(0x14000000),
  });

  @override
  State<_ProfileActionButton> createState() => _ProfileActionButtonState();
}

class _ProfileActionButtonState extends State<_ProfileActionButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          width: 220,
          height: 51,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                isHovered
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
      final Animation<double> curved = CurvedAnimation(
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
  List<Country> _filteredCountries = <Country>[];

  @override
  void initState() {
    super.initState();
    _allCountries = CountryService().getAll();
    _filteredCountries = List<Country>.from(_allCountries);
    _searchController.addListener(_applyFilter);
  }

  void _applyFilter() {
    final String query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredCountries = List<Country>.from(_allCountries);
        return;
      }

      _filteredCountries =
          _allCountries.where((Country country) {
            final String name = country.name.toLowerCase();
            final String code = country.countryCode.toLowerCase();
            final String phone = country.phoneCode.toLowerCase();

            return name.contains(query) ||
                code.contains(query) ||
                phone.contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final double originalHeight = screenHeight * 0.50;
    final double extraTop = originalHeight * 0.20;
    final double extraBottom = originalHeight * 0.15;
    final double dialogHeight = originalHeight + extraTop + extraBottom;
    final double verticalShift = -(extraTop - extraBottom) / 2;

    final double dialogWidth =
        screenWidth > 1200
            ? 640
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
                      final Country country = _filteredCountries[index];

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
}) {
  final DateTime now = DateTime.now();
  final DateTime init = initial ?? DateTime(now.year, now.month, now.day);

  return showGeneralDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (ctx, anim1, anim2) => const SizedBox(),
    transitionBuilder: (ctx, anim1, anim2, child) {
      final Animation<double> curve = CurvedAnimation(
        parent: anim1,
        curve: Curves.easeOutQuart,
      );

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
  final DateTime initial;
  final DateTime firstDate;
  final DateTime lastDate;

  const _PremiumCalendarDialog({
    required this.initial,
    required this.firstDate,
    required this.lastDate,
  });

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
    setState(() {
      _selected = date;
    });
  }

  void _close() {
    Navigator.of(context).pop();
  }

  void _apply() {
    Navigator.of(context).pop(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context).copyWith(
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
                dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((
                  states,
                ) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF4A4A4A);
                  }
                  return null;
                }),
                dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((
                  states,
                ) {
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
    const List<String> months = [
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

    final String month = months[_selected.month - 1];
    final String day = _selected.day.toString().padLeft(2, '0');
    final int year = _selected.year;

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
                  fontFamily: fontBody,
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
