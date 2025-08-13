import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PosterSignupStep2 extends StatefulWidget {
  final Function(List<String>) onUpdate;
  final List<String> selectedCategories;

  const PosterSignupStep2({
    super.key,
    required this.onUpdate,
    required this.selectedCategories,
  });

  @override
  State<PosterSignupStep2> createState() => _PosterSignupStep2State();
}

class _PosterSignupStep2State extends State<PosterSignupStep2> {
  final Color primaryGreen = const Color(0xFF2ECC71);
  late List<String> _selectedCategories;

  final List<String> _topServiceCategories = [
    'Home & Maintenance',
    'Professional Services',
    'Personal Care & Wellness',
    'Education & Coaching',
    'Delivery & Transport',
    'Events & Hospitality',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Personalize Your Experience",
            style: GoogleFonts.montserrat(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Select services you're interested in. This helps us show you relevant workers.",
            style: GoogleFonts.montserrat(fontSize: 15, color: Colors.grey[700]),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: _topServiceCategories.map((category) {
              final isSelected = _selectedCategories.contains(category);
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                    }
                    widget.onUpdate(_selectedCategories);
                  });
                },
 backgroundColor: isSelected ? primaryGreen.withAlpha(51) : Colors.grey[200], // Approx 0.2 opacity
 selectedColor: primaryGreen.withAlpha(76), // Approx 0.3 opacity
                labelStyle: TextStyle(
                  color: isSelected ? primaryGreen : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                checkmarkColor: primaryGreen,
                shape: StadiumBorder(
                  side: BorderSide(
                    color: isSelected ? primaryGreen : Colors.grey[400]!,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                "You can skip this and decide later",
                style: GoogleFonts.montserrat(
                  color: Colors.grey,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
