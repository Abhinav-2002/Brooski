import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthScreen extends StatefulWidget {
  final String role;

  const AuthScreen({Key? key, required this.role}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool isOtpSent = false;
  bool isVerified = false;
  bool isLoading = false;
  int _timer = 30;
  late FocusNode _otpFocus;
  late FocusNode _phoneFocus;

  @override
  void initState() {
    super.initState();
    _otpFocus = FocusNode();
    _phoneFocus = FocusNode();
  }

  @override
  void dispose() {
    _otpFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void sendOtp() async {
    if (_phoneController.text.length == 10) {
      setState(() {
        isLoading = true;
      });

      // Simulate OTP sending
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        isOtpSent = true;
        isLoading = false;
        _startTimer();
      });
      _otpFocus.requestFocus();
    }
  }

  void _startTimer() {
    _timer = 30;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_timer == 0) return false;
      setState(() => _timer--);
      return true;
    });
  }

  void verifyOtp() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 2)); // Simulate verification
    setState(() {
      isLoading = false;
      isVerified = true;
    });
    // Proceed to role-based form navigation
 final role = widget.role.toLowerCase();

if (role == 'poster') {
  Navigator.pushReplacementNamed(context, '/poster-signup');
} else {
  Navigator.pushReplacementNamed(context, '/worker-signup');
}


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text('Brooski',
                  style: TextStyle(
                      color: Color(0xFF2ECC71),
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Hyperlocal Help. Instantly.',
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 40),

              // Mobile Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                focusNode: _phoneFocus,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: const Icon(Icons.phone),
                  prefixText: '+91 ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF2ECC71)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              if (isOtpSent) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        focusNode: _otpFocus,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: 'OTP',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Color(0xFF2ECC71)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _timer > 0
                        ? Text('$_timer s')
                        : TextButton(
                            onPressed: sendOtp,
                            child: const Text('Resend OTP'),
                          )
                  ],
                )
              ],

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => isOtpSent ? verifyOtp() : sendOtp(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isOtpSent ? 'Verify OTP' : 'Continue'),
              ),

              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user, color: Colors.grey, size: 16),
                  SizedBox(width: 5),
                  Text("100% Verified & Secure",
                      style: TextStyle(fontSize: 12, color: Colors.black45))
                ],
              ),

              const SizedBox(height: 10),
              TextButton(
                  onPressed: () {},
                  child: const Text('Terms & Privacy Policy')),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
