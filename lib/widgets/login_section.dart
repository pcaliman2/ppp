import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/widgets/header2.dart';
import 'package:owa_flutter/widgets/footer_section.dart';
import 'package:owa_flutter/widgets/signup_section.dart';
import 'package:owa_flutter/widgets/login_section_mobile.dart';
import 'package:owa_flutter/useful/is_desktop_from_context.dart';

class OWALoginSection extends StatelessWidget {
  const OWALoginSection({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isDesktopFromContext(context)) {
      return const OWALoginSectionMobile();
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
              child: const _LoginCard(),
            ),
            OWAFooter(key: UniqueKey()),
          ],
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: colors.backgroundColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 32),
                  child: _LoginForm(),
                ),
              ),
              Expanded(child: _LoginRightImage()),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _password = TextEditingController();

  InputDecoration _dec() => const InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(vertical: 8),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
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
            validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
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
    return SizedBox(
      height: 430,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            const Text(
              "WELCOME BACK",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Basier Square Mono',
                fontWeight: FontWeight.w400,
                fontSize: 30.4,
                color: Colors.black,
                letterSpacing: 0,
                height: 1.25,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Log In to access your dashboard.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: _field("Email", _email),
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: _field("Password", _password, obscure: true),
            ),

            const Spacer(),

            _LoginImageButton(
              text: "LOG IN",
              onTap: () {
                if (_formKey.currentState?.validate() ?? false) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Login form valid")),
                  );
                }
              },
            ),

            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _LoginRightImage extends StatelessWidget {
  const _LoginRightImage();

  void _goToSignUp(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OWASignUpSection()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 430,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/events4.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Welcome Back',
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
                  'Not a Member yet?',
                  style: TextStyle(
                    fontFamily: 'Basier Square Mono',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                _LoginImageButton(
                  text: 'SIGN UP',
                  backgroundColor: Colors.transparent,
                  borderColor: Colors.white,
                  textColor: Colors.white,
                  textHoverColor: Colors.white,
                  hoverBackgroundColor: const Color(0x14FFFFFF),
                  onTap: () => _goToSignUp(context),
                ),
              ],
            ),
          ),
        ],
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
