import 'package:flutter/material.dart';
import 'package:brooski_app/features/screens/choose_role/choose_role_screen.dart';
import 'package:brooski_app/features/screens/auth/auth_screen.dart';
import 'package:brooski_app/features/screens/PosterSignupScreen/PosterSignupScreen.dart';
import 'package:brooski_app/features/auth/screens/worker_signup_screen.dart';
import 'package:brooski_app/features/worker/screens/worker_dashboard_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const ChooseRoleScreen(),
  '/auth': (context) {
    final role = ModalRoute.of(context)!.settings.arguments as String;
    return AuthScreen(role: role);
  },
  '/poster-signup': (context) => const PosterSignupScreen(),
  '/worker-signup': (context) => const WorkerSignupScreen(),
  '/worker-dashboard': (context) => const WorkerDashboardScreen(),
};
