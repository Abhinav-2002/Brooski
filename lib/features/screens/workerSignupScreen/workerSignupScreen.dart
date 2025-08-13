import 'package:brooski_app/features/models/worker_signup_model.dart';
import 'package:brooski_app/features/screens/shared/step_1_personal_info.dart';
import 'package:brooski_app/features/screens/workerSignupScreen/steps/step_2_role_info.dart';
import 'package:brooski_app/features/screens/shared/step_3_kyc.dart';
import 'package:brooski_app/features/screens/shared/step_4_emergency_contact.dart';
import 'package:brooski_app/features/screens/workerSignupScreen/steps/step_5_final_review.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // We have 4 forms for the first 4 steps. Step 5 is review only.
    _formKeys = List.generate(4, (index) => GlobalKey<FormState>());
    _steps = [
      SignupStep1PersonalInfo(formKey: _formKeys[0], data: _signupData),
      WorkerSignupStep2(formKey: _formKeys[1], data: _signupData),
      SignupStep3Kyc(formKey: _formKeys[2], data: _signupData),
      SignupStep4EmergencyContact(formKey: _formKeys[3], data: _signupData),
      WorkerSignupStep5(data: _signupData),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // If we are on the final review step, submit the form.
    if (_currentStep == _steps.length - 1) {
      _submitForm();
      return;
    }

    // Otherwise, validate the current step's form and move to the next.
    if (_formKeys[_currentStep].currentState!.validate()) {
      _formKeys[_currentStep].currentState!.save(); // Save the form data
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate a network call to the backend.
    await Future.delayed(const Duration(seconds: 3));

    // In a real app, you would send the data to your backend here.
    print("--- Worker Signup Data Submitted ---");
    print("Full Name: ${_signupData.fullName}");
    print("Gender: ${_signupData.gender}");
    print("DOB: ${_signupData.dob}");
    print("City: ${_signupData.city}");
    print("Job Category: ${_signupData.jobCategory}");
    print("Subcategory: ${_signupData.subCategory}");
    print("Experience: ${_signupData.experienceLevel}");
    print("Aadhaar: ${_signupData.aadhaarNumber}");
    print("PAN: ${_signupData.panNumber}");
    print("Emergency Contact Name: ${_signupData.emergencyContactName}");
    print("Emergency Contact Phone: ${_signupData.emergencyContactPhone}");
    print("Emergency Contact Consent: ${_signupData.emergencyContactConsent}");
    print("------------------------------------");

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signup submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Optional: Navigate to a success screen or home screen after a short delay
    // await Future.delayed(const Duration(seconds: 1));
    // Navigator.of(context).pushReplacementNamed('/home');
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
                itemCount: _steps.length,
                onPageChanged: (page) {
                  setState(() {
                    _currentStep = page;
                  });
                },
                itemBuilder: (context, index) => _steps[index],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isLoading
          ? FloatingActionButton(
              onPressed: null,
              backgroundColor: Colors.grey,
              child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            )
          : FloatingActionButton.extended(
              onPressed: _nextStep,
              backgroundColor: primaryGreen,
              icon: Icon(_currentStep == _steps.length - 1
                  ? Icons.check
                  : Icons.arrow_forward),
              label: Text(_currentStep == _steps.length - 1 ? 'Submit' : 'Next'),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
