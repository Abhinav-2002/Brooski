import 'package:flutter/material.dart';

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({Key? key}) : super(key: key);

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen>
    with SingleTickerProviderStateMixin {
  String? selectedRole;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  void onSelectRole(String role) {
    setState(() {
      selectedRole = role;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPoster = selectedRole == 'poster';
    final isWorker = selectedRole == 'worker';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    'Brooski',
                    style: TextStyle(
                      fontSize: 55,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2ECC71), // Emerald Green
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Choose your role',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => onSelectRole('poster'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 24),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isPoster ? Color(0xFF2ECC71) : Colors.grey.shade300,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              children: const [
                                Icon(Icons.assignment, size: 60, color: Color(0xFF2ECC71)),
                                SizedBox(height: 16),
                                Text('Poster', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                                Text('I want to hire help', style: TextStyle(fontSize: 20)),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => onSelectRole('worker'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isWorker ? Color(0xFF2ECC71) : Colors.grey.shade300,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xFFD5F5E3),
                            ),
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              children: const [
                                Icon(Icons.build_circle, size: 60, color: Color(0xFF2ECC71)),
                                SizedBox(height: 16),
                                Text('Worker', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                                Text('I want to earn money', style: TextStyle(fontSize: 20)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: selectedRole != null ? Color(0xFF2ECC71) : Colors.grey,
                    ),
                    onPressed: selectedRole != null
                      ? () {
                          Navigator.pushNamed(
                            context,
                            '/auth',
                            arguments: selectedRole,
                          );
                        }
                      : null,
                    child: const Text('Continue', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
