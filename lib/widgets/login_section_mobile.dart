import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/widgets/header2_mobile.dart';
import 'package:owa_flutter/widgets/mobile_footer.dart';
import 'package:owa_flutter/widgets/signup_section.dart';

class OWALoginSectionMobile extends StatelessWidget {
  const OWALoginSectionMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const OWAHeader2Mobile(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: const _LoginCardMobile(),
            ),
            OWAMobileFooter(key: UniqueKey()),
          ],
        ),
      ),
    );
  }
}

class _LoginCardMobile extends StatelessWidget {
  const _LoginCardMobile();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.backgroundColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LoginRightImageMobile(),
            SizedBox(height: 24),
            _LoginFormMobile(),
          ],
        ),
      ),
    );
  }
}

class _LoginFormMobile extends StatefulWidget {
  const _LoginFormMobile();

  @override
  State<_LoginFormMobile> createState() => _LoginFormMobileState();
}

class _LoginFormMobileState extends State<_LoginFormMobile> {
  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _password = TextEditingController();

  InputDecoration _dec() => const InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(vertical: 10),
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
            decoration: _dec(),
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  void _goToSignUp() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OWASignUpSection()),
      );
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
            'WELCOME BACK',
            style: TextStyle(
              fontFamily: 'Basier Square Mono',
              fontWeight: FontWeight.w400,
              fontSize: 24,
              color: Colors.black,
              letterSpacing: 0,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Log In to access your dashboard.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 18),
          _field('Email', _email),
          _field('Password', _password, obscure: true),
          const SizedBox(height: 22),
          Center(
            child: Column(
              children: [
                _LoginImageButtonMobile(
                  text: 'LOG IN',
                  onTap: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login form valid')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _goToSignUp,
                  child: const Text(
                    'Not a member yet? Sign Up',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Basier Square Mono',
                      fontSize: 13,
                      color: Colors.black87,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginRightImageMobile extends StatelessWidget {
  const _LoginRightImageMobile();

  void _goToSignUp(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OWASignUpSection()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/events4.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Basier Square Mono',
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Not a Member yet?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Basier Square Mono',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _LoginImageButtonMobile(
                    text: 'SIGN UP',
                    backgroundColor: Colors.transparent,
                    borderColor: Colors.white,
                    textColor: Colors.white,
                    pressedBackgroundColor: Color(0x14FFFFFF),
                    onTap: () => _goToSignUp(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginImageButtonMobile extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color pressedBackgroundColor;

  const _LoginImageButtonMobile({
    this.text = 'SIGN UP',
    this.onTap,
    this.backgroundColor = Colors.transparent,
    this.borderColor = const Color(0xFF2C2C2C),
    this.textColor = const Color(0xFF2C2C2C),
    this.pressedBackgroundColor = const Color(0x14000000),
    super.key,
  });

  @override
  State<_LoginImageButtonMobile> createState() =>
      _LoginImageButtonMobileState();
}

class _LoginImageButtonMobileState extends State<_LoginImageButtonMobile> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 280),
        height: 51,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              isPressed
                  ? widget.pressedBackgroundColor
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
            color: widget.textColor,
          ),
        ),
      ),
    );
  }
}
