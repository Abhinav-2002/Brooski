import 'package:brooski_app/core/models/poster_signup_model.dart';
import 'package:brooski_app/features/onboarding/widgets/poster_step_2_personalize.dart';
import 'package:brooski_app/features/onboarding/widgets/poster_step_4_final_review.dart';
import 'package:brooski_app/features/onboarding/widgets/step_1_personal_info.dart';
import 'package:brooski_app/features/onboarding/widgets/step_3_kyc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PosterSignupScreen extends StatefulWidget {
  const PosterSignupScreen({super.key});

  @override
  State<PosterSignupScreen> createState() => _PosterSignupScreenState();
}

class _PosterSignupScreenState extends State<PosterSignupScreen> {
  final PageController _pageController = PageController();
  final PosterSignupData _signupData = PosterSignupData();
  late final List<GlobalKey<FormState>> _formKeys;
  late final List<Widget> _steps;
  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Form keys for Step 1 (Personal Info) and Step 3 (KYC)
    // Step 2 (Personalize) and Step 4 (Review) do not use form keys from this list.
    _formKeys = List.generate(3, (index) => GlobalKey<FormState>()); 
    _steps = [
      SignupStep1PersonalInfo(formKey: _formKeys[0], data: _signupData),
      PosterSignupStep2(
        onUpdate: (categories) {
          setState(() {
            _signupData.selectedCategories = categories;
          });
        },
        selectedCategories: _signupData.selectedCategories,
      ),
      SignupStep3Kyc(formKey: _formKeys[2], data: _signupData), // Uses _formKeys[2]
      PosterSignupStep4(data: _signupData),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == _steps.length - 1) {
      _submitForm();
      return;
    }

    // Determine the correct form key index based on the current step
    // Step 0 (Personal Info) uses _formKeys[0]
    // Step 1 (Personalize) has no form key in _formKeys, validation is skipped
    // Step 2 (KYC) uses _formKeys[2]
    bool shouldValidate = true;
    GlobalKey<FormState>? currentFormKey;

    if (_currentStep == 0) {
      currentFormKey = _formKeys[0];
    } else if (_currentStep == 1) { // Personalization step, no form key from _formKeys
      shouldValidate = false;
    } else if (_currentStep == 2) { // KYC step
      currentFormKey = _formKeys[2];
    }

    if (shouldValidate) {
      if (currentFormKey != null && currentFormKey.currentState!.validate()) {
        currentFormKey.currentState!.save();
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } 
    } else {
      // For steps without validation or with custom validation handled elsewhere
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

    await Future.delayed(const Duration(seconds: 3));

    print("--- Poster Signup Data Submitted ---");
    print("Full Name: ${_signupData.fullName}");
    print("Gender: ${_signupData.gender}");
    print("DOB: ${_signupData.dob}");
    print("City: ${_signupData.city}");
    print("Selected Categories: ${_signupData.selectedCategories.join(', ')}");
    print("Aadhaar: ${_signupData.aadhaarNumber}");
    print("PAN: ${_signupData.panNumber}");
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
          'Create a Poster Account',
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
