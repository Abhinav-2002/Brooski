import 'package:brooski_app/core/models/signup_data_base.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Step1PersonalInfo extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final SignupData signupData;

  const Step1PersonalInfo({super.key, required this.formKey, required this.signupData});

  @override
  State<Step1PersonalInfo> createState() => _Step1PersonalInfoState();
}

class _Step1PersonalInfoState extends State<Step1PersonalInfo> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim, _slideAnim;
  final Color primaryGreen = const Color(0xFF2ECC71);

  final TextEditingController _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.signupData.dob != null) {
      _dobController.text = DateFormat('d MMMM yyyy').format(widget.signupData.dob!);
    }
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim =
        Tween<double>(begin: 30, end: 0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDOB(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.signupData.dob ?? DateTime(DateTime.now().year - 20),
      firstDate: DateTime(1960),
      lastDate: DateTime(DateTime.now().year - 18),
    );
    if (picked != null) {
      setState(() {
        widget.signupData.dob = picked;
        _dobController.text = DateFormat('d MMMM yyyy').format(picked);
      });
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
              "Personal Information",
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Let's get to know you. This helps us keep your profile safe & professional.",
              style: GoogleFonts.montserrat(fontSize: 15, color: Colors.grey[700]),
            ),
            const SizedBox(height: 28),
            TextFormField(
              initialValue: widget.signupData.fullName,
              decoration: _inputDecoration("Full Name", "Enter your name"),
              validator: (val) => (val == null || val.trim().length < 2) ? "Name is required" : null,
              onSaved: (val) => widget.signupData.fullName = val,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: widget.signupData.gender,
              decoration: _inputDecoration("Gender", "Select gender"),
              items: ['Male', 'Female', 'Other']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (val) => setState(() => widget.signupData.gender = val),
              validator: (val) => val == null ? "Please select gender" : null,
              onSaved: (val) => widget.signupData.gender = val,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _dobController,
              decoration: _inputDecoration("Date of Birth", "Choose date"),
              readOnly: true,
              onTap: () => _selectDOB(context),
              validator: (val) => widget.signupData.dob == null ? "Select your Date of Birth" : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: widget.signupData.city,
              decoration: _inputDecoration("City", "Enter your city"),
              validator: (val) => (val == null || val.trim().length < 2) ? "City is required" : null,
              onSaved: (val) => widget.signupData.city = val,
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
