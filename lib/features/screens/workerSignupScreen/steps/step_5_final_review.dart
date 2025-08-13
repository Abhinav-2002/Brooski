import 'package:brooski_app/features/models/worker_signup_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class WorkerSignupStep5 extends StatelessWidget {
  final WorkerSignupData data;
  const WorkerSignupStep5({super.key, required this.data});

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
              _buildReviewRow('Full Name', data.fullName),
              _buildReviewRow('Gender', data.gender),
              _buildReviewRow('Date of Birth', data.dob != null ? DateFormat('d MMMM yyyy').format(data.dob!) : null),
              _buildReviewRow('City', data.city),
            ],
          ),
          _buildReviewSection(
            context,
            title: 'Your Profession',
            children: [
              _buildReviewRow('Job Category', data.jobCategory),
              _buildReviewRow('Subcategory', data.subCategory),
              _buildReviewRow('Experience Level', data.experienceLevel),
            ],
          ),
          _buildReviewSection(
            context,
            title: 'KYC Details',
            children: [
              _buildReviewRow('Aadhaar Number', data.aadhaarNumber),
              _buildReviewRow('PAN Number', data.panNumber),
            ],
          ),
          _buildReviewSection(
            context,
            title: 'Emergency Contact',
            children: [
              _buildReviewRow('Contact Name', data.emergencyContactName),
              _buildReviewRow('Contact Phone', data.emergencyContactPhone),
              _buildReviewRow('Consent Given', data.emergencyContactConsent ? 'Yes' : 'No'),
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
