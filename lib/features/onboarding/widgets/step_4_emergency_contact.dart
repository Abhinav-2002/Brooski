import 'package:brooski_app/core/models/signup_data_base.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Step4EmergencyContact extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final SignupData signupData;

  const Step4EmergencyContact({super.key, required this.formKey, required this.signupData});

  @override
  State<Step4EmergencyContact> createState() => _Step4EmergencyContactState();
}

class _Step4EmergencyContactState extends State<Step4EmergencyContact> {
  final Color primaryGreen = const Color(0xFF2ECC71);

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
              "Emergency Contact",
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Provide a contact for emergencies. We'll only use this if we can't reach you.",
              style: GoogleFonts.montserrat(fontSize: 15, color: Colors.grey[700]),
            ),
            const SizedBox(height: 28),
            TextFormField(
              initialValue: widget.signupData.emergencyContactName,
              decoration: _inputDecoration("Contact Person's Name", "Enter full name"),
              validator: (val) => (val == null || val.trim().length < 2) ? "Name is required" : null,
              onSaved: (val) => widget.signupData.emergencyContactName = val,
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: widget.signupData.emergencyContactPhone,
              decoration: _inputDecoration("Contact Person's Phone", "Enter 10-digit number"),
              keyboardType: TextInputType.phone,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Phone number is required';
                if (!RegExp(r'^\d{10}$').hasMatch(val)) return 'Enter a valid 10-digit phone number';
                return null;
              },
              onSaved: (val) => widget.signupData.emergencyContactPhone = val,
            ),
            const SizedBox(height: 20),
            FormField<bool>(
              initialValue: widget.signupData.emergencyContactConsent,
              validator: (value) {
                if (value == false) {
                  return 'You must consent to contact this person in an emergency.';
                }
                return null;
              },
              onSaved: (val) => widget.signupData.emergencyContactConsent = val ?? false,
              builder: (FormFieldState<bool> state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                          "I confirm I have permission from this person to share their details."),
                      value: state.value,
                      onChanged: (bool? value) {
                        state.didChange(value);
                      },
                      subtitle: state.hasError
                          ? Text(
                              state.errorText!,
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            )
                          : null,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                );
              },
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
