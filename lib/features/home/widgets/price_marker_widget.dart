import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A custom map marker widget designed as a 'price badge'.
///
/// It displays the job price and a category-specific icon, with a border
/// color that changes based on job urgency, all enclosed within a custom
/// shape that includes a triangular pointer.
class PriceMarkerWidget extends StatelessWidget {
  final String price;
  final String category;
  final bool isUrgent;

  const PriceMarkerWidget({
    super.key,
    required this.price,
    required this.category,
    this.isUrgent = false,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'electrical':
        return Icons.electrical_services_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'carpentry':
        return Icons.handyman;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isUrgent ? const Color(0xFFD32F2F) : const Color(0xFF388E3C);
    final Color primaryGreen = const Color(0xFF2ECC71); // Define primaryGreen here if needed elsewhere, otherwise remove
    return SizedBox(
      width: 100,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The main badge body
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 10, // Make space for the triangle
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 2.5),
                boxShadow: [
                  BoxShadow( // Consider replacing with a specific elevation for consistent shadow appearance
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(_getCategoryIcon(category), color: Colors.black87, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    '₹$price',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // The triangle pointer
          Positioned(
            bottom: 0,
            child: CustomPaint(
              size: const Size(20, 10),
              painter: _TrianglePainter(color: borderColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// A custom painter to draw the triangular pointer for the marker.
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
