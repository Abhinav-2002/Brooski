import 'package:brooski_app/core/models/worker_signup_model.dart';
import 'package:brooski_app/features/onboarding/widgets/step_1_personal_info.dart';
import 'package:brooski_app/features/onboarding/widgets/worker_step_2_role_info.dart';
import 'package:brooski_app/features/onboarding/widgets/step_3_kyc.dart';
import 'package:brooski_app/features/onboarding/widgets/step_4_emergency_contact.dart';
import 'package:brooski_app/features/onboarding/widgets/worker_step_5_final_review.dart';
import 'package:brooski_app/features/worker/screens/worker_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkerSignupScreen extends StatefulWidget {
  const WorkerSignupScreen({super.key});

  @override
  State<WorkerSignupScreen> createState() => _WorkerSignupScreenState();
}

class _WorkerSignupScreenState extends State<WorkerSignupScreen> {
  final PageController _pageController = PageController();
  final WorkerSignupData _signupData = WorkerSignupData();
  late final List<GlobalKey<FormState>> _formKeys;
  late final List<Widget> _steps;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    // There are 4 steps with forms, so we need 4 keys.
    _formKeys = List.generate(4, (index) => GlobalKey<FormState>());
    _steps = [
      Step1PersonalInfo(formKey: _formKeys[0], signupData: _signupData),
      WorkerStep2RoleInfo(formKey: _formKeys[1], signupData: _signupData),
      Step3Kyc(formKey: _formKeys[2], signupData: _signupData),
      Step4EmergencyContact(formKey: _formKeys[3], signupData: _signupData),
      // The final review step doesn't have a form, so no key is needed.
      WorkerStep5FinalReview(signupData: _signupData),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // If we are on the final review step, which has no form, submit.
    if (_currentStep == _steps.length - 1) {
      _submitForm();
      return;
    }

    // For all other steps, validate the form before proceeding.
    if (_formKeys[_currentStep].currentState!.validate()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _submitForm() {
    // All previous steps have been validated. We can now submit.

    print("Submitting form data:");
    print("Name: ${_signupData.fullName}");
    print("Gender: ${_signupData.gender}");
    print("DOB: ${_signupData.dob}");
    print("City: ${_signupData.city}");
    print("Job Category: ${_signupData.jobCategory}");
    print("Experience: ${_signupData.experienceLevel}");
    print("Aadhaar: ${_signupData.aadhaarNumber}");
    print("PAN: ${_signupData.panNumber}");
    print("Emergency Contact: ${_signupData.emergencyContactName}");

    if (!mounted) return;

    try {
      print("Navigating to Worker Dashboard...");
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/worker-dashboard',
        (Route<dynamic> route) => false,
      );
      print("Navigation command issued.");
    } catch (e, stackTrace) {
      print("Error during navigation: $e");
      print("Stack trace: $stackTrace");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred during navigation: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF2ECC71);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: _previousStep,
              )
            : null,
        title: Text(
          'Become a Worker',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / _steps.length,
                    minHeight: 7,
                    backgroundColor: primaryGreen.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step ${_currentStep + 1} of ${_steps.length}',
                    style: GoogleFonts.montserrat(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentStep = page;
                  });
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) => _steps[index],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: ElevatedButton.icon(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: Icon(_currentStep == _steps.length - 1
              ? Icons.check_circle
              : Icons.arrow_forward),
          label: Text(
            _currentStep == _steps.length - 1 ? 'Submit' : 'Next',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
