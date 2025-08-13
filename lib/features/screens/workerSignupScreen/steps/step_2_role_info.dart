import 'package:brooski_app/features/models/worker_signup_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkerSignupStep2 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final WorkerSignupData data;

  const WorkerSignupStep2({super.key, required this.formKey, required this.data});

  @override
  State<WorkerSignupStep2> createState() => _WorkerSignupStep2State();
}

class _WorkerSignupStep2State extends State<WorkerSignupStep2> {
  final Color primaryGreen = const Color(0xFF2ECC71);

  final Map<String, List<String>> _categories = {
    'Home & Maintenance': [
      'Plumbing',
      'Electrical',
      'Carpentry',
      'Painting',
      'Cleaning',
      'Pest Control',
      'HVAC',
      'Handyman'
    ],
    'Professional Services': [
      'Accounting',
      'Legal Advice',
      'Digital Marketing',
      'Graphic Design',
      'Photography',
      'Content Writing',
      'Translation'
    ],
    'Personal Care & Wellness': [
      'Beauty & Salon',
      'Massage Therapy',
      'Fitness Training',
      'Yoga Instruction',
      'Diet/Nutrition Coaching'
    ],
    'Education & Coaching': [
      'Academic Tutoring (Math, Science, Languages)',
      'Test Prep',
      'Music Lessons',
      'Art Classes',
      'Career Coaching'
    ],
    'Delivery & Transport': [
      'Parcel Delivery',
      'Grocery Shopping',
      'Ride-Hailing',
      'Vehicle Repair',
      'Bike/Motorbike Courier'
    ],
    'Events & Hospitality': [
      'Catering',
      'Event Planning',
      'DJ/MC',
      'Photography/Videography',
      'Decorations',
      'Venue Setup'
    ],
    'Industrial & Technical': [
      'Machine Maintenance',
      'Welding',
      'Electrical Fitting',
      'Fabrication',
      'Quality Inspection',
      'Factory Clean-up'
    ],
    'Healthcare & Home Care': [
      'Elderly Care',
      'Baby Sitting',
      'Physiotherapy',
      'Medical Equipment Repair',
      'Lab Sample Pickup'
    ],
    'Agriculture & Outdoors': [
      'Farm Labor',
      'Harvesting',
      'Landscaping',
      'Gardening',
      'Livestock Care'
    ],
    'IT & Emerging Tech': [
      'App Development',
      'Web Development',
      'IoT Device Installation',
      'Drone Operations',
      'Robotics Maintenance'
    ]
  };

  List<String> _subcategories = [];

  @override
  void initState() {
    super.initState();
    if (widget.data.jobCategory != null) {
      _subcategories = _categories[widget.data.jobCategory!] ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Profession",
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tell us what you do. This helps us find the right jobs for you.",
              style: GoogleFonts.montserrat(fontSize: 15, color: Colors.grey[700]),
            ),
            const SizedBox(height: 28),
            DropdownButtonFormField<String>(
              value: widget.data.jobCategory,
              decoration: _inputDecoration("Primary Job Category", "Select a category"),
              items: _categories.keys.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (val) {
                setState(() {
                  widget.data.jobCategory = val;
                  widget.data.subCategory = null; // Reset subcategory
                  _subcategories = _categories[val!] ?? [];
                });
              },
              validator: (val) => val == null ? 'Please select a job category' : null,
            ),
            const SizedBox(height: 20),
            if (_subcategories.isNotEmpty)
              DropdownButtonFormField<String>(
                value: widget.data.subCategory,
                decoration: _inputDecoration("Subcategory", "Select a subcategory"),
                items: _subcategories.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (val) => setState(() => widget.data.subCategory = val),
                validator: (val) => val == null ? 'Please select a subcategory' : null,
              ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: widget.data.experienceLevel,
              decoration: _inputDecoration("Experience Level", "Select your experience"),
              items: ['Beginner', 'Intermediate', 'Professional']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (val) => setState(() => widget.data.experienceLevel = val),
              validator: (val) => val == null ? 'Please select your experience level' : null,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.montserrat(
        color: primaryGreen,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      hintStyle: GoogleFonts.montserrat(
        color: Colors.grey[400],
        fontSize: 15,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryGreen.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryGreen, width: 2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      fillColor: primaryGreen.withOpacity(0.05),
      filled: true,
    );
  }
}
