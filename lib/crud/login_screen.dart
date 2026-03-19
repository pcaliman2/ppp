import 'package:flutter/material.dart';
import 'package:owa_flutter/crud/models.dart';
import 'dart:async';

import 'package:owa_flutter/crud/page_crud_screen.dart';
import 'package:owa_flutter/crud/spec.dart' show spec;
// import 'package:owa_flutter/backend/auth_service.dart'; // Uncomment when backend is ready

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late AnimationController _loadingController;

  // Animations
  late Animation<double> _backgroundZoomAnimation;
  late Animation<double> _backgroundOpacityAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _loadingRotationAnimation;

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(
    //  text: 'admin@owa.com'
  );
  final _passwordController = TextEditingController(
    //  text: 'admin123'
  );

  // State
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  // Colors
  static const backgroundColor = Color.fromRGBO(239, 236, 228, 1.0);
  // static const onHoverButtonColor = Color(0xFFE3FE23);

  @override
  void initState() {
    super.initState();

    // Background animation controller
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    // Content animation controller
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Loading animation controller
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Background animations
    _backgroundZoomAnimation = Tween<double>(begin: 1.08, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeOutCubic,
      ),
    );

    _backgroundOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Content animations
    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Loading animation
    _loadingRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.linear),
    );

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _backgroundController.forward();
      Future.delayed(const Duration(milliseconds: 600), () {
        _contentController.forward();
      });
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    _loadingController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _loadingController.repeat();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Uncomment when backend is ready
      // final authService = ClaudeAuthService(
      //   domain: 'https://latente-cms-415c09785677.herokuapp.com',
      // );
      //
      // final result = await authService.authenticateAndGetUser(
      //   email: _emailController.text.trim(),
      //   password: _passwordController.text,
      // );

      // Hardcoded success for development
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email == 'admin@owa.com' && password == 'admin123') {
        // Navigate to main app or show success
        _showSuccessDialog();
      } else {
        setState(() {
          _errorMessage = 'Invalid credentials. Use admin@owa.com / admin123';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      _loadingController.stop();
      _loadingController.reset();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'LOGIN SUCCESSFUL',
                    style: TextStyle(
                      fontFamily: 'Basier Square Mono',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to OWA°',
                    style: TextStyle(
                      fontFamily: 'Basier Circle Mono',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _AnimatedButton(
                    text: 'CONTINUE',
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to main app

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => SectionsCRUDScreen(
                                onPageUpdated: (p0) {},
                                pageSpec: PageSpec.fromMap(spec),
                              ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            // Split Background Images
            _buildSplitBackgrounds(),

            // Navigation Header
            _buildNavigationHeader(),

            // Login Form
            _buildLoginForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitBackgrounds() {
    return Row(
      children: [
        // Left Half - Water/Ocean Image
        Expanded(
          child: ClipRect(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _backgroundZoomAnimation,
                _backgroundOpacityAnimation,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _backgroundZoomAnimation.value,
                  child: Opacity(
                    opacity: _backgroundOpacityAnimation.value,
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/hero_left.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Right Half - Person Image
        Expanded(
          child: ClipRect(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _backgroundZoomAnimation,
                _backgroundOpacityAnimation,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _backgroundZoomAnimation.value,
                  child: Opacity(
                    opacity: _backgroundOpacityAnimation.value,
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/hero_right.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.2),
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
          child: AnimatedBuilder(
            animation: _contentFadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _contentFadeAnimation,
                child: SlideTransition(
                  position: _contentSlideAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'BACK',
                                style: TextStyle(
                                  fontFamily: 'Basier Square Mono',
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Center Logo
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'O',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 4.0,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'W',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 4.0,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'A°',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 4.0,
                            ),
                          ),
                        ],
                      ),

                      // Help Text
                      Text(
                        'NEED HELP?',
                        style: TextStyle(
                          fontFamily: 'Basier Circle Mono',
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.0,
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
    );
  }

  Widget _buildLoginForm() {
    return Positioned.fill(
      child: Center(
        child: AnimatedBuilder(
          animation: _contentFadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _contentFadeAnimation,
              child: SlideTransition(
                position: _contentSlideAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(32),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: backgroundColor.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        Text(
                          'WELCOME BACK',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Basier Square Mono',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 3.0,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Sign in to your account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Basier Circle Mono',
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Email Field
                        _buildInputField(
                          controller: _emailController,
                          label: 'EMAIL',
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Password Field
                        _buildInputField(
                          controller: _passwordController,
                          label: 'PASSWORD',
                          hintText: 'Enter your password',
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Error Message
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontFamily: 'Basier Circle Mono',
                                color: Colors.red.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Login Button
                        _AnimatedButton(
                          text: 'SIGN IN',
                          isLoading: _isLoading,
                          loadingAnimation: _loadingRotationAnimation,
                          onPressed: _isLoading ? null : _handleLogin,
                        ),

                        const SizedBox(height: 24),

                        // Forgot Password
                        Center(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                // TODO: Implement forgot password
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Forgot password feature coming soon',
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot your password?',
                                style: TextStyle(
                                  fontFamily: 'Basier Circle Mono',
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Demo Credentials
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'DEMO CREDENTIALS',
                                style: TextStyle(
                                  fontFamily: 'Basier Square Mono',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Email: admin@owa.com\nPassword: admin123',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Basier Circle Mono',
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType? keyboardType,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && !_isPasswordVisible,
          validator: validator,
          style: TextStyle(
            fontFamily: 'Basier Circle Mono',
            fontSize: 14,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontFamily: 'Basier Circle Mono',
              color: Colors.grey[400],
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade600, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2),
            ),
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                    : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Animation<double>? loadingAnimation;

  const _AnimatedButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.loadingAnimation,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<Color?> _colorAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.black,
      end: const Color(0xFFE3FE23), // onHoverButtonColor
    ).animate(_hoverController);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          widget.onPressed != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
      onEnter: (_) {
        if (widget.onPressed != null) {
          setState(() => _isHovered = true);
          _hoverController.forward();
        }
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: widget.onPressed,
                child: Center(
                  child:
                      widget.isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: AnimatedBuilder(
                              animation: widget.loadingAnimation!,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle:
                                      widget.loadingAnimation!.value *
                                      2.0 *
                                      3.14159,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _isHovered ? Colors.black : Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                          : Text(
                            widget.text,
                            style: TextStyle(
                              fontFamily: 'Basier Square Mono',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                              color: _isHovered ? Colors.black : Colors.white,
                            ),
                          ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
