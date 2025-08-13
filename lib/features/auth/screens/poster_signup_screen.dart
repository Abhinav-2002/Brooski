import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Use the *features* model so types match PosterSignupStep2/4.
import 'package:brooski_app/features/models/poster_signup_model.dart';

import 'package:brooski_app/features/onboarding/widgets/poster_step_2_personalize.dart';
import 'package:brooski_app/features/onboarding/widgets/poster_step_4_final_review.dart';

class PosterSignupScreen extends StatefulWidget {
  const PosterSignupScreen({super.key});

  @override
  State<PosterSignupScreen> createState() => _PosterSignupScreenState();
}

class _PosterSignupScreenState extends State<PosterSignupScreen> {
  final PageController _pageController = PageController();

  // Single source of truth for data (from *features/models*).
  final PosterSignupData _signupData = PosterSignupData();

  // We validate Step 1 and Step 3. Steps 2 and 4 are non-form steps.
  final GlobalKey<FormState> _step1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step3FormKey = GlobalKey<FormState>();

  late final List<Widget> _steps;
  int _currentStep = 0;
  bool _isLoading = false;

  Color get _primaryGreen => const Color(0xFF2ECC71);

  @override
  void initState() {
    super.initState();
    _steps = <Widget>[
      // 0: Step 1 - Personal Info (Form)
      _Step1PersonalInfoPlaceholder(formKey: _step1FormKey, data: _signupData),

      // 1: Step 2 - Personalize (no form validation)
      PosterSignupStep2(
        selectedCategories: _signupData.selectedCategories,
        onUpdate: (categories) {
          setState(() {
            _signupData.selectedCategories = categories;
          });
        },
      ),

      // 2: Step 3 - KYC (Form)
      _Step3KycPlaceholder(formKey: _step3FormKey, data: _signupData),

      // 3: Step 4 - Final Review (no form; consumes PosterSignupData)
      PosterSignupStep4(data: _signupData),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _validateCurrentStepIfNeeded() {
    // Steps requiring validation
    if (_currentStep == 0) {
      final form = _step1FormKey.currentState;
      if (form != null && form.validate()) {
        form.save();
        return true;
      }
      return false;
    }
    if (_currentStep == 2) {
      final form = _step3FormKey.currentState;
      if (form != null && form.validate()) {
        form.save();
        return true;
      }
      return false;
    }
    // Steps without validation (1, 3) always pass
    return true;
    }

  void _nextStep() {
    final isLast = _currentStep == _steps.length - 1;
    if (isLast) {
      _submitForm();
      return;
    }

    if (_validateCurrentStepIfNeeded()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors to continue.')),
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

  Future<void> _submitForm() async {
    setState(() => _isLoading = true);

    // Simulate network request (replace with your API call)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signup submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSteps = _steps.length;

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
            // Progress header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / totalSteps,
                      minHeight: 7,
                      backgroundColor: _primaryGreen.withAlpha(51), // ~20% opacity
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryGreen),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step ${_currentStep + 1} of $totalSteps',
                    style: GoogleFonts.montserrat(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Steps content (non-scrollable pages; use internal scrolling in step widgets if needed)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalSteps,
                onPageChanged: (page) {
                  setState(() => _currentStep = page);
                },
                itemBuilder: (context, index) => _steps[index],
              ),
            ),
          ],
        ),
      ),

      // Primary CTA
      floatingActionButton: _isLoading
          ? FloatingActionButton(
              onPressed: null,
              backgroundColor: Colors.grey,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : FloatingActionButton.extended(
              onPressed: _nextStep,
              backgroundColor: _primaryGreen,
              icon: Icon(
                _currentStep == totalSteps - 1 ? Icons.check : Icons.arrow_forward,
              ),
              label: Text(_currentStep == totalSteps - 1 ? 'Submit' : 'Next'),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

/// ---------------------------------------------------------------------------
/// PLACEHOLDER WIDGETS
/// Replace these with your actual implementations if you have them already.
/// They both use the *features/models* PosterSignupData, to avoid type clashes.
/// ---------------------------------------------------------------------------

class _Step1PersonalInfoPlaceholder extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final PosterSignupData data;

  const _Step1PersonalInfoPlaceholder({
    required this.formKey,
    required this.data,
  });

  @override
  State<_Step1PersonalInfoPlaceholder> createState() => _Step1PersonalInfoPlaceholderState();
}

class _Step1PersonalInfoPlaceholderState extends State<_Step1PersonalInfoPlaceholder> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController; // Local-only: model has no `email`.

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data.fullName ?? '');
    _emailController = TextEditingController(text: ''); // Local field; not bound to model.
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Form(
        key: widget.formKey,
        child: ListView(
          children: [
            Text(
              'Basic Details',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
              onSaved: (v) => widget.data.fullName = v?.trim(),
            ),
            const SizedBox(height: 12),
            // Email kept for UI/validation, but NOT stored in model (model lacks `email`).
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email (optional)'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                final val = (v ?? '').trim();
                if (val.isEmpty) return null; // Optional
                final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(val);
                return ok ? null : 'Enter a valid email';
              },
              onSaved: (v) {
                // No-op: model does not have an email field.
                // If you add `email` later to PosterSignupData, set it here.
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Step3KycPlaceholder extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final PosterSignupData data;

  const _Step3KycPlaceholder({
    required this.formKey,
    required this.data,
  });

  @override
  State<_Step3KycPlaceholder> createState() => _Step3KycPlaceholderState();
}

class _Step3KycPlaceholderState extends State<_Step3KycPlaceholder> {
  late final TextEditingController _aadhaarController;

  @override
  void initState() {
    super.initState();
    _aadhaarController = TextEditingController(text: widget.data.aadhaarNumber ?? '');
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Form(
        key: widget.formKey,
        child: ListView(
          children: [
            Text(
              'KYC Verification',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _aadhaarController,
              decoration: const InputDecoration(labelText: 'Aadhaar Number'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final val = (v ?? '').trim();
                if (val.isEmpty) return 'Please enter your Aadhaar number';
                if (val.length != 12) return 'Aadhaar must be 12 digits';
                if (!RegExp(r'^\d{12}$').hasMatch(val)) return 'Only digits allowed';
                return null;
              },
              onSaved: (v) => widget.data.aadhaarNumber = v?.trim(),
            ),
            const SizedBox(height: 12),
            // Add more KYC fields if your model supports them.
          ],
        ),
      ),
    );
  }
}
