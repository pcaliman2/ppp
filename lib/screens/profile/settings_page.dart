import 'package:flutter/material.dart';
import 'package:owa_flutter/api/http_settings_repository.dart';
import 'package:owa_flutter/api/mock_settings_repository.dart';
import 'package:owa_flutter/api/settings_repository.dart';
import 'package:owa_flutter/config/api_config.dart';
import 'package:owa_flutter/models/update_settings_request.dart';
import 'package:owa_flutter/models/user_profile.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/is_desktop_from_context.dart';
import 'package:owa_flutter/useful/size_config.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final SettingsRepository _repository;

  UserProfile? _initialProfile;
  bool _isLoadingProfile = true;
  bool _isSaving = false;
  bool _showPasswordSection = false;
  bool _saveHovered = false;
  String? _loadError;
  _FlashState? _flash;

  @override
  void initState() {
    super.initState();
    _repository = useMockBackend
        ? const MockSettingsRepository()
        : const HttpSettingsRepository();
    _loadProfile();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _loadError = null;
      _flash = null;
    });
    try {
      final profile = await _repository.getMyProfile();
      if (!mounted) return;
      _initialProfile = profile;
      _emailController.text = profile.email;
      _countryController.text = profile.country;
      _phoneController.text = profile.phone;
    } catch (_) {
      if (!mounted) return;
      _loadError = 'Could not load settings.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  bool get _hasPasswordInput =>
      _currentPasswordController.text.trim().isNotEmpty ||
      _newPasswordController.text.isNotEmpty ||
      _confirmPasswordController.text.isNotEmpty;

  bool get _hasProfileChanges {
    final p = _initialProfile;
    if (p == null) return false;
    return _emailController.text.trim() != p.email ||
        _countryController.text.trim() != p.country ||
        _phoneController.text.trim() != p.phone;
  }

  bool get _canSave => !_isSaving && (_hasProfileChanges || _hasPasswordInput);

  Future<void> _saveChanges() async {
    if (!_canSave) return;

    final email = _emailController.text.trim();
    final country = _countryController.text.trim();
    final phone = _phoneController.text.trim();
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isNotEmpty && !email.contains('@')) {
      _showFlash(false, 'Enter a valid email.');
      return;
    }
    if (country.isEmpty && _hasProfileChanges) {
      _showFlash(false, 'Country is required.');
      return;
    }
    if (phone.isEmpty && _hasProfileChanges) {
      _showFlash(false, 'Telephone is required.');
      return;
    }
    if (newPassword.isNotEmpty || confirmPassword.isNotEmpty || currentPassword.isNotEmpty) {
      if (newPassword != confirmPassword) {
        _showFlash(false, 'New password and confirmation must match.');
        return;
      }
    }

    setState(() {
      _isSaving = true;
      _flash = null;
    });

    try {
      final response = await _repository.updateSettings(
        UpdateSettingsRequest(
          email: _hasProfileChanges ? email : null,
          country: _hasProfileChanges ? country : null,
          phone: _hasProfileChanges ? phone : null,
          currentPassword: currentPassword.isEmpty ? null : currentPassword,
          newPassword: newPassword.isEmpty ? null : newPassword,
        ),
      );
      if (!mounted) return;
      _showFlash(response.ok, response.message);
      if (response.ok) {
        _initialProfile = UserProfile(
          email: email,
          country: country,
          phone: phone,
          fullName: _initialProfile?.fullName,
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (_) {
      if (!mounted) return;
      _showFlash(false, 'Could not save settings right now.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showFlash(bool ok, String message) {
    setState(() {
      _flash = _FlashState(ok: ok, message: message);
    });
  }

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
            child: AbsorbPointer(
              absorbing: _isSaving,
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
                      child: _buildBody(textTheme),
                    ),
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: !_isSaving,
            child: AnimatedOpacity(
              opacity: _isSaving ? 1 : 0,
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOutCubic,
              child: Container(
                color: const Color(0xFF1E1E1E).withValues(alpha: 0.1),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C2C2C)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(TextTheme textTheme) {
    if (_isLoadingProfile) {
      return Column(
        key: const ValueKey('settings-loading'),
        children: [
          _placeholderCard(height: 74),
          SizedBox(height: SizeConfig.h(12)),
          _placeholderCard(height: 220),
          SizedBox(height: SizeConfig.h(12)),
          _placeholderCard(height: 150),
        ],
      );
    }

    if (_loadError != null) {
      return Container(
        key: const ValueKey('settings-error'),
        width: double.infinity,
        padding: EdgeInsets.all(SizeConfig.w(24)),
        decoration: BoxDecoration(
          color: colors.membershipsBackgroundColor.withValues(alpha: 0.36),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFC8BFB3), width: 0.9),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded, size: 30, color: const Color(0xFF474747)),
            SizedBox(height: SizeConfig.h(10)),
            Text(
              _loadError!,
              style: textTheme.bodyLarge?.copyWith(color: const Color(0xFF3A3A3A)),
            ),
            SizedBox(height: SizeConfig.h(12)),
            _InlineActionButton(
              label: 'Retry',
              onTap: _loadProfile,
            ),
          ],
        ),
      );
    }

    return Column(
      key: const ValueKey('settings-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Profile',
          style: textTheme.titleMedium?.copyWith(color: const Color(0xFF5B5B5B)),
        ),
        SizedBox(height: SizeConfig.h(6)),
        Text(
          'Settings',
          style: textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF222222),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: SizeConfig.h(8)),
        Text(
          'Manage your account and security preferences.',
          style: textTheme.bodyLarge?.copyWith(color: const Color(0xFF4E4E4E)),
        ),
        SizedBox(height: SizeConfig.h(16)),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 560),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          child: _flash == null
              ? const SizedBox.shrink(key: ValueKey('flash-empty'))
              : _buildFlashBanner(textTheme, _flash!),
        ),
        SizedBox(height: SizeConfig.h(10)),
        _sectionCard(
          title: 'Account',
          child: Column(
            children: [
              _field(controller: _emailController, label: 'Email'),
              SizedBox(height: SizeConfig.h(10)),
              _field(controller: _countryController, label: 'Country of residence'),
              SizedBox(height: SizeConfig.h(10)),
              _field(controller: _phoneController, label: 'Telephone'),
            ],
          ),
        ),
        SizedBox(height: SizeConfig.h(14)),
        _sectionCard(
          title: 'Security',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => setState(() => _showPasswordSection = !_showPasswordSection),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOutCubic,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.w(12),
                    vertical: SizeConfig.h(11),
                  ),
                  decoration: BoxDecoration(
                    color: _showPasswordSection
                        ? const Color(0xFFEEE7DD)
                        : const Color(0xFFF5EFE5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFC9C0B5), width: 0.9),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Change password',
                          style: textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF2A2A2A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        _showPasswordSection
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF3B3B3B),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 560),
                curve: Curves.easeInOutCubic,
                child: _showPasswordSection
                    ? Padding(
                        padding: EdgeInsets.only(top: SizeConfig.h(12)),
                        child: Column(
                          children: [
                            _field(
                              controller: _currentPasswordController,
                              label: 'Current password',
                              obscureText: true,
                            ),
                            SizedBox(height: SizeConfig.h(10)),
                            _field(
                              controller: _newPasswordController,
                              label: 'New password',
                              obscureText: true,
                            ),
                            SizedBox(height: SizeConfig.h(10)),
                            _field(
                              controller: _confirmPasswordController,
                              label: 'Confirm new password',
                              obscureText: true,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        SizedBox(height: SizeConfig.h(18)),
        _saveButton(textTheme),
      ],
    );
  }

  Widget _buildFlashBanner(TextTheme textTheme, _FlashState flash) {
    final ok = flash.ok;
    return Container(
      key: ValueKey('flash-${flash.message}'),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(14),
        vertical: SizeConfig.h(12),
      ),
      decoration: BoxDecoration(
        color: ok ? const Color(0xFFE7E0D4) : const Color(0xFFEDE2DA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ok ? const Color(0xFFBEB2A3) : const Color(0xFFC9B5AA),
          width: 0.9,
        ),
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
            size: 18,
            color: const Color(0xFF333333),
          ),
          SizedBox(width: SizeConfig.w(8)),
          Expanded(
            child: Text(
              flash.message,
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF2F2F2F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!ok)
            _InlineActionButton(
              label: 'Retry',
              onTap: _isSaving ? null : _saveChanges,
            ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeConfig.w(18)),
      decoration: BoxDecoration(
        color: colors.membershipsBackgroundColor.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC8BFB3), width: 0.9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              color: const Color(0xFF252525),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: SizeConfig.h(12)),
          child,
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFBEB4A9), width: 0.9),
    );
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF2F2F2F),
          ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF666666),
            ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.62),
        isDense: true,
        enabledBorder: border,
        border: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: Color(0xFF2C2C2C), width: 1.1),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _saveButton(TextTheme textTheme) {
    final enabled = _canSave;
    final bgColor = _saveHovered ? const Color(0xFF323232) : const Color(0xFF292929);
    return MouseRegion(
      onEnter: (_) => setState(() => _saveHovered = true),
      onExit: (_) => setState(() => _saveHovered = false),
      child: GestureDetector(
        onTap: enabled ? _saveChanges : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOutCubic,
          width: double.infinity,
          height: SizeConfig.h(52),
          decoration: BoxDecoration(
            color: enabled ? bgColor : const Color(0xFF545454),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E1E), width: 0.9),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              child: _isSaving
                  ? Row(
                      key: const ValueKey('settings-loading'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: SizeConfig.w(10)),
                        Text(
                          'Saving...',
                          style: textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Save changes',
                      key: const ValueKey('settings-idle'),
                      style: textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderCard({required double height}) {
    return Container(
      width: double.infinity,
      height: SizeConfig.h(height),
      decoration: BoxDecoration(
        color: colors.membershipsBackgroundColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC8BFB3), width: 0.9),
      ),
    );
  }
}

class _InlineActionButton extends StatefulWidget {
  const _InlineActionButton({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  State<_InlineActionButton> createState() => _InlineActionButtonState();
}

class _InlineActionButtonState extends State<_InlineActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.w(10),
            vertical: SizeConfig.h(7),
          ),
          decoration: BoxDecoration(
            color: enabled
                ? (_isHovered ? const Color(0xFF383838) : const Color(0xFF2E2E2E))
                : const Color(0xFF555555),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _FlashState {
  const _FlashState({
    required this.ok,
    required this.message,
  });

  final bool ok;
  final String message;
}
