import 'package:brooski_app/core/models/signup_data_base.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Step3Kyc extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final SignupData signupData;

  const Step3Kyc({super.key, required this.formKey, required this.signupData});

  @override
  State<Step3Kyc> createState() => _Step3KycState();
}

class _Step3KycState extends State<Step3Kyc> {
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
              "KYC & Trust Setup",
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Help us build a secure community. You can complete this later.",
              style: GoogleFonts.montserrat(fontSize: 15, color: Colors.grey[700]),
            ),
            const SizedBox(height: 28),
            TextFormField(
              initialValue: widget.signupData.aadhaarNumber,
              decoration: _inputDecoration("Aadhaar Number (Optional)", "Enter 12-digit number"),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val != null && val.isNotEmpty && !RegExp(r'^\d{12}$').hasMatch(val)) {
                  return 'Enter a valid 12-digit Aadhaar number';
                }
                return null;
              },
              onSaved: (val) => widget.signupData.aadhaarNumber = val,
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: widget.signupData.panNumber,
              decoration: _inputDecoration("PAN Card Number (Optional)", "Enter 10-character PAN"),
              textCapitalization: TextCapitalization.characters,
              validator: (val) {
                if (val != null &&
                    val.isNotEmpty &&
                    !RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(val.toUpperCase())) {
                  return 'Enter a valid PAN number';
                }
                return null;
              },
              onSaved: (val) => widget.signupData.panNumber = val?.toUpperCase(),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle("Required Verifications"),
            const SizedBox(height: 15),
            _buildVerificationTile(
              icon: Icons.cloud_upload_outlined,
              title: "Aadhaar/Driving License",
              subtitle: "Upload a clear picture of your document.",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Document upload coming soon!")));
              },
            ),
            _buildVerificationTile(
              icon: Icons.camera_alt_outlined,
              title: "Selfie Verification",
              subtitle: "Take a live photo to verify your identity.",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selfie verification coming soon!")));
              },
            ),
            _buildVerificationTile(
              icon: Icons.phone_android_outlined,
              title: "OTP Verification",
              subtitle: "Verify your mobile number for secure access.",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP verification coming soon!")));
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                "You can complete verification later from your profile.\nPress 'Next' to continue.",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildVerificationTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: primaryGreen, size: 30),
        title: Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: GoogleFonts.montserrat()),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
 borderSide: BorderSide(color: primaryGreen.withAlpha(102)), // Approx 0.4 opacity
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
 fillColor: primaryGreen.withAlpha(12), // Approx 0.05 opacity
      filled: true,
    );
  }
}
