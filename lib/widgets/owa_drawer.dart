import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/custom_launch_url.dart';

class OWADrawer extends StatelessWidget {
  const OWADrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFEDE8E1),
      width: MediaQuery.of(context).size.width,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    _buildMenuItem('BECOME A MEMBER'),
                    const SizedBox(height: 32),
                    _buildMenuItem('BOOK A SESSION'),
                    const SizedBox(height: 32),
                    _buildMenuItem('SERVICES'),
                    const SizedBox(height: 32),
                    _buildMenuItem('SCIENCE'),
                    const SizedBox(height: 32),
                    _buildMenuItem('FAQ'),
                    const SizedBox(height: 32),
                    _buildMenuItemWithIcon('THERAPIES'),
                  ],
                ),
              ),
            ),
            _buildDrawerFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'O',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.8),
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 8.0,
                ),
              ),
              const SizedBox(width: 20),
              Text(
                'W',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.8),
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 8.0,
                ),
              ),
              const SizedBox(width: 20),
              Text(
                'A°',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.8),
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 8.0,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 28),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 2.0,
        height: 1.5,
      ),
    );
  }

  Widget _buildMenuItemWithIcon(String text) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 2.0,
            height: 1.5,
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          Icons.arrow_outward,
          size: 16,
          color: Colors.black.withValues(alpha: 0.7),
        ),
      ],
    );
  }

  Widget _buildDrawerFooter() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.3),
                width: 1.5,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 20,
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap:
                          () => customLaunchURL(
                            'https://www.latentestudio.com/en',
                          ),
                      child: _buildFooterLink('Creative Strategy'),
                    ),
                    const SizedBox(height: 12),
                    _buildFooterLink('Terms of Service'),
                    const SizedBox(height: 12),
                    _buildFooterLink('Privacy Policy'),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFooterLink('Cookies'),
                    const SizedBox(height: 12),
                    _buildFooterLink('Disclaimers'),
                    const SizedBox(height: 12),
                    _buildFooterLink(
                      '© All rights reserved ${DateTime.now().year}',
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

  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black.withValues(alpha: 0.4),
        fontSize: 11,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5,
        height: 1.3,
      ),
    );
  }
}
