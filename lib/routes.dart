import 'package:flutter/material.dart';

// Screens
import 'package:brooski_app/features/screens/choose_role/choose_role_screen.dart';
import 'package:brooski_app/features/screens/auth/auth_screen.dart';
import 'package:brooski_app/features/auth/screens/poster_signup_screen.dart';
import 'package:brooski_app/features/auth/screens/worker_signup_screen.dart';
import 'package:brooski_app/features/worker/screens/worker_dashboard_screen.dart';

/// Centralized app routes.
/// Use: Navigator.pushNamed(context, '/auth', arguments: 'poster' /* or 'worker' */);
final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const ChooseRoleScreen(),
  '/auth': (context) {
    // Safely read the role argument; fall back to a sensible default.
    final args = ModalRoute.of(context)?.settings.arguments;
    final role = (args is String && args.isNotEmpty) ? args : 'poster';
    return AuthScreen(role: role);
  },
  '/poster-signup': (context) => const PosterSignupScreen(),
  '/worker-signup': (context) => const WorkerSignupScreen(),
  '/worker-dashboard': (context) => const WorkerDashboardScreen(),
};
