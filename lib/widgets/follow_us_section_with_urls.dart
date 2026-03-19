import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/size_config.dart';

class OWAFollowUsSectionWithUrls extends StatelessWidget {
  final List<String> imageUrls;

  const OWAFollowUsSectionWithUrls({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color.fromRGBO(239, 236, 228, 1),
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(120),
        vertical: SizeConfig.h(80),
      ),
      child: Column(
        children: [
          // Header section
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.w(20),
                  vertical: SizeConfig.h(8),
                ),
                // decoration: const BoxDecoration(color: Color(0xFF000000)),
                child: Text(
                  'FOLLOW US',
                  style: TextStyle(
                    fontFamily: 'Basier Square Mono',
                    fontWeight: FontWeight.w400,
                    fontSize: SizeConfig.t(19),
                    height: 1.51,
                    letterSpacing: SizeConfig.t(19) * 0.12,
                    color: Color(0xFF000000),
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.h(10)),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.w(16),
                  vertical: SizeConfig.h(6),
                ),
                // decoration: const BoxDecoration(color: Color(0xFF14181F)),
                child: Text(
                  '@owa.wellness',
                  style: TextStyle(
                    fontFamily: 'Arbeit',
                    fontWeight: FontWeight.w500,
                    fontSize: SizeConfig.t(12),
                    height: 1.73,
                    letterSpacing: 0,

                    color: Color(0xFF14181F),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: SizeConfig.h(60)),

          // Images grid
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              imageUrls.length > 4 ? 4 : imageUrls.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  right: index < 3 ? SizeConfig.w(20) : 0,
                ),
                child: _buildNetworkImage(imageUrls[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return GestureDetector(
      onTap: () {
        // Handle tap - open Instagram or specific post
      },
      child: Container(
        width: SizeConfig.w(264.77),
        height: SizeConfig.h(270.76),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.w(9.99)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SizeConfig.w(9.99)),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: const Color(0xFF2C2C2C),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white.withOpacity(0.6),
                    strokeWidth: 2,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF2C2C2C),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: SizeConfig.w(40),
                      ),
                      SizedBox(height: SizeConfig.h(8)),
                      Text(
                        'Image',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: SizeConfig.t(12),
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
}
