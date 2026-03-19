import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:owa_flutter/useful/colors.dart';
import 'package:owa_flutter/useful/custom_launch_url.dart';
import 'package:owa_flutter/useful/text_styles.dart';
import 'package:owa_flutter/widgets/fade_in_widget.dart';

class OWAMobileFooter extends StatefulWidget {
  const OWAMobileFooter({super.key});

  @override
  State<OWAMobileFooter> createState() => _OWAMobileFooterState();
}

class _OWAMobileFooterState extends State<OWAMobileFooter> {
  // Contact form controllers
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactMessageController = TextEditingController();

  // Newsletter controller
  final _newsletterEmailController = TextEditingController();

  // Validation states
  bool _isContactEmailValid = true;
  bool _isContactPhoneValid = true;
  bool _isContactMessageValid = true;
  bool _isNewsletterEmailValid = true;
  static const String _addressMapUrl = 'https://maps.apple/p/GHz_u4dboTIpQI';
  static final String _cancelMembershipWhatsAppUrl =
      'https://wa.me/5215610297637?text=Hello%2C%20I%20am%20an%20OWA%20WELLNESS%20client%2C%20and%20I%20would%20like%20Information%20and%20Help%20to%20Cancel%20my%20Membership';

  void _openCancelMembershipWhatsApp() {
    customLaunchURL(_cancelMembershipWhatsAppUrl);
  }

  @override
  void dispose() {
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _contactMessageController.dispose();
    _newsletterEmailController.dispose();
    super.dispose();
  }

  // Email validation
  bool _validateEmail(String email) {
    if (email.isEmpty) return true;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Phone validation
  bool _validatePhone(String phone) {
    if (phone.isEmpty) return true;
    return phone.length >= 10;
  }

  // Message validation
  bool _validateMessage(String message) {
    if (message.isEmpty) return true;
    return message.length >= 10;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF120705), // Same as desktop footer
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo/Icon
          FadeInWidget(
            child: SvgPicture.asset(
              'assets/footer_icon.svg',
              fit: BoxFit.fill,
              alignment: Alignment.topLeft,
              clipBehavior: Clip.none,
              colorFilter: ColorFilter.mode(
                Color.fromRGBO(159, 145, 129, 1),
                BlendMode.srcIn,
              ),
            ),
          ),

          SizedBox(height: 40),

          // Sections in 2 columns layout
          FadeInWidget(
            child: Column(
              children: [
                // Row 1: GET IN TOUCH + EXPLORE
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildMobileSectionGetInTouch()),
                    SizedBox(width: 20),
                    Expanded(
                      child: _buildMobileSection('EXPLORE', [
                        'The OWA Experience',
                        // 'The Science',
                        'First Timers and FAQ\'s',
                        'Policies',
                      ]),
                    ),
                  ],
                ),

                SizedBox(height: 32),

                // Row 2: BOOK + CONNECT
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildMobileSectionBook(),
                    ),
                    SizedBox(width: 20),
                    Expanded(child: _buildMobileSectionConnect()),
                  ],
                ),

                SizedBox(height: 40),

                // CONTACT FORM (Full width)
                _buildContactSection(),

                SizedBox(height: 32),

                // NEWSLETTER FORM (Full width)
                _buildNewsletterSection(),
              ],
            ),
          ),

          SizedBox(height: 48),

          // Divider line
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.3),
            margin: EdgeInsets.only(bottom: 24),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => customLaunchURL('https://www.latentestudio.com/en'),
                child: Text(
                  'Creative Strategy @ Latente',
                  style: OWATextStyles.footerBottomItem,
                ),
              ),
              Text(
                '© All rights reserved OWA 2026',
                style: OWATextStyles.footerBottomItem,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSectionGetInTouch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GET IN TOUCH',
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.45,
            letterSpacing: 0.04 * 12,
            color: sectionFontColor,
          ),
        ),
        SizedBox(height: 12),
        InkWell(
          onTap: () => customLaunchURL(_addressMapUrl),
          child: Text(
            'Sinaloa 49 Col. Roma Norte\nMéxico, CDMX. CP. 6700',
            style: TextStyle(
              fontFamily: 'Basier Square Mono',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.73,
              letterSpacing: 0,
              color: Color(0xFFCFC6BC),
            ),
          ),
        ),
        SizedBox(height: 12),
        InkWell(
          onTap: () => customLaunchURL('mailto:hello@owawellness.com'),
          child: Text(
            'hello@owawellness.com',
            style: TextStyle(
              fontFamily: 'Basier Square Mono',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.73,
              letterSpacing: 0,
              color: Color(0xFFCFC6BC),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () => customLaunchURL('tel:+525555057158'),
          child: Text(
            '+52 555 505 7158',
            style: TextStyle(
              fontFamily: 'Basier Square Mono',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.73,
              letterSpacing: 0,
              color: Color(0xFFCFC6BC),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSectionConnect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONNECT',
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.45,
            letterSpacing: 0.04 * 12,
            color: sectionFontColor,
          ),
        ),
        SizedBox(height: 12),
        _buildMobileFooterLink(
          'Instagram',
          onTap: () => customLaunchURL('https://www.instagram.com/weare.owa/'),
        ),
        _buildMobileFooterLink(
          'Spotify',
          onTap: () => customLaunchURL('https://open.spotify.com/'),
        ),
        _buildMobileFooterLink('Careers'),
      ],
    );
  }

  Widget _buildMobileSectionBook() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BOOK',
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.45,
            letterSpacing: 0.04 * 12,
            color: sectionFontColor,
          ),
        ),
        SizedBox(height: 12),
        _buildMobileFooterLink('Book a Session'),
        _buildMobileFooterLink('Become a Member'),
        _buildMobileFooterLink('Stay at OWA'),
        _buildMobileFooterLink('Host Your Event'),
        _buildMobileFooterLink(
          'Cancel Membership',
          onTap: _openCancelMembershipWhatsApp,
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTACT',
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.45,
            letterSpacing: 0.04 * 12,
            color: sectionFontColor,
          ),
        ),
        SizedBox(height: 16),

        // Email field
        _buildFormField(
          controller: _contactEmailController,
          hintText: 'Email',
          isValid: _isContactEmailValid,
          onChanged: (value) {
            setState(() {
              _isContactEmailValid = _validateEmail(value);
            });
          },
        ),
        SizedBox(height: 12),

        // Phone field
        _buildFormField(
          controller: _contactPhoneController,
          hintText: 'Phone',
          isValid: _isContactPhoneValid,
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            setState(() {
              _isContactPhoneValid = _validatePhone(value);
            });
          },
        ),
        SizedBox(height: 12),

        // Message field
        _buildFormField(
          controller: _contactMessageController,
          hintText: 'Message',
          isValid: _isContactMessageValid,
          maxLines: 3,
          onChanged: (value) {
            setState(() {
              _isContactMessageValid = _validateMessage(value);
            });
          },
        ),
        SizedBox(height: 16),

        // Submit button
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () {
              setState(() {
                _isContactEmailValid = _validateEmail(
                  _contactEmailController.text,
                );
                _isContactPhoneValid = _validatePhone(
                  _contactPhoneController.text,
                );
                _isContactMessageValid = _validateMessage(
                  _contactMessageController.text,
                );
              });

              if (_isContactEmailValid &&
                  _isContactPhoneValid &&
                  _isContactMessageValid &&
                  _contactEmailController.text.isNotEmpty &&
                  _contactPhoneController.text.isNotEmpty &&
                  _contactMessageController.text.isNotEmpty) {
                print('Contact form submitted');
                _contactEmailController.clear();
                _contactPhoneController.clear();
                _contactMessageController.clear();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Message sent successfully!'),
                    backgroundColor: sectionFontColor,
                  ),
                );
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Submit',
                  style: TextStyle(
                    fontFamily: 'Basier Square Mono',
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    height: 1.73,
                    letterSpacing: 0,
                    color: Color(0xFFCFC6BC),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Color(0xFFCFC6BC), size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewsletterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NEWSLETTER',
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.45,
            letterSpacing: 0.04 * 12,
            color: sectionFontColor,
          ),
        ),
        SizedBox(height: 16),

        Text(
          'Be the first to know about our new\nexperiences and collaborations',
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 1.73,
            letterSpacing: 0,
            color: Color(0xFFCFC6BC),
          ),
        ),
        SizedBox(height: 20),

        // Email Address field
        _buildFormField(
          controller: _newsletterEmailController,
          hintText: 'Email Address',
          isValid: _isNewsletterEmailValid,
          onChanged: (value) {
            setState(() {
              _isNewsletterEmailValid = _validateEmail(value);
            });
          },
        ),
        SizedBox(height: 16),

        // Submit button
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () {
              setState(() {
                _isNewsletterEmailValid = _validateEmail(
                  _newsletterEmailController.text,
                );
              });

              if (_isNewsletterEmailValid &&
                  _newsletterEmailController.text.isNotEmpty) {
                print(
                  'Newsletter subscription: ${_newsletterEmailController.text}',
                );
                _newsletterEmailController.clear();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Successfully subscribed to newsletter!'),
                    backgroundColor: sectionFontColor,
                  ),
                );
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Submit',
                  style: TextStyle(
                    fontFamily: 'Basier Square Mono',
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    height: 1.73,
                    letterSpacing: 0,
                    color: Color(0xFFCFC6BC),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Color(0xFFCFC6BC), size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String hintText,
    required bool isValid,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isValid ? Color(0xFFCFC6BC) : Colors.red,
            width: 1,
          ),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        style: TextStyle(
          fontFamily: 'Basier Square Mono',
          fontWeight: FontWeight.w400,
          fontSize: 11,
          height: 1.73,
          letterSpacing: 0,
          color: Color(0xFFCFC6BC),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 1.73,
            letterSpacing: 0,
            color: Color(0xFFCFC6BC).withOpacity(0.5),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.only(bottom: 8, top: 8),
        ),
      ),
    );
  }

  Widget _buildMobileSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.45,
            letterSpacing: 0.04 * 12,
            color: sectionFontColor,
          ),
        ),
        SizedBox(height: 12),
        ...items.map((item) => _buildMobileFooterLink(item)).toList(),
      ],
    );
  }

  Widget _buildMobileFooterLink(String text, {VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: 11,
            height: 1.73,
            letterSpacing: 0,
            color: Color(0xFFCFC6BC),
          ),
        ),
      ),
    );
  }
}



