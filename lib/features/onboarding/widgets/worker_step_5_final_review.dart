import 'package:brooski_app/core/models/worker_signup_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class WorkerStep5FinalReview extends StatelessWidget {
  final WorkerSignupData signupData;
  const WorkerStep5FinalReview({super.key, required this.signupData});

  final Color primaryGreen = const Color(0xFF2ECC71);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Review & Submit",
            style: GoogleFonts.montserrat(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please review your information carefully before submitting.",
            style: GoogleFonts.montserrat(fontSize: 15, color: Colors.grey[700]),
          ),
          const SizedBox(height: 28),
          _buildReviewSection(
            context,
            title: 'Personal Information',
            children: [
              _buildReviewRow('Full Name', signupData.fullName),
              _buildReviewRow('Gender', signupData.gender),
              _buildReviewRow('Date of Birth', signupData.dob != null ? DateFormat('d MMMM yyyy').format(signupData.dob!) : null),
              _buildReviewRow('City', signupData.city),
            ],
          ),
          _buildReviewSection(
            context,
            title: 'Your Profession',
            children: [
              _buildReviewRow('Job Category', signupData.jobCategory),
              _buildReviewRow('Subcategory', signupData.subCategory),
              _buildReviewRow('Experience Level', signupData.experienceLevel),
            ],
          ),
          _buildReviewSection(
            context,
            title: 'KYC Details',
            children: [
              _buildReviewRow('Aadhaar Number', signupData.aadhaarNumber),
              _buildReviewRow('PAN Number', signupData.panNumber),
            ],
          ),
          _buildReviewSection(
            context,
            title: 'Emergency Contact',
            children: [
              _buildReviewRow('Contact Name', signupData.emergencyContactName),
              _buildReviewRow('Contact Phone', signupData.emergencyContactPhone),
              _buildReviewRow('Consent Given', signupData.emergencyContactConsent ? 'Yes' : 'No'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: primaryGreen.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: primaryGreen)),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: children,
      ),
    );
  }

  Widget _buildReviewRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.montserrat(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value ?? 'N/A',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
