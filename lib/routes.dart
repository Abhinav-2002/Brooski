// lib/routes.dart
import 'package:flutter/material.dart';

// Screens
import 'package:brooski_app/features/screens/choose_role/choose_role_screen.dart';
import 'package:brooski_app/features/screens/auth/auth_screen.dart';
import 'package:brooski_app/features/auth/screens/poster_signup_screen.dart';
import 'package:brooski_app/features/auth/screens/worker_signup_screen.dart';
import 'package:brooski_app/features/worker/screens/worker_dashboard_screen.dart';
import 'package:brooski_app/features/feedback/screens/feedback_screen.dart';
import 'package:brooski_app/features/chat/screens/chat_thread_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const ChooseRoleScreen(),

  '/auth': (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final role = (args is String && args.isNotEmpty) ? args : 'poster';
    return AuthScreen(role: role);
  },

  '/poster-signup': (context) => const PosterSignupScreen(),
  '/worker-signup': (context) => const WorkerSignupScreen(),
  '/worker-dashboard': (context) => const WorkerDashboardScreen(),

  '/feedback': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return FeedbackScreen(
      assignmentId: args['assignmentId'] as String,
      jobId: args['jobId'] as String,
      posterName: args['posterName'] as String,
      posterImageUrl: args['posterImageUrl'] as String,
    );
  },

  // Canonical chat route (works with full payload OR just name/avatar)
  ChatThreadScreen.routeName: (context) {
    final raw = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

    // Build a normalized arg map with safe defaults
    final args = <String, dynamic>{
      'sessionId': raw['sessionId'] ?? 'ad-hoc:${DateTime.now().millisecondsSinceEpoch}',
      'jobId': raw['jobId'] ?? '',
      'posterId': raw['posterId'] ?? (raw['peerId'] ?? 'poster-unknown'),
      'workerId': raw['workerId'] ?? 'worker-unknown',
      'isWorker': raw['isWorker'] ?? true,
      'suggestedPrice': (raw['suggestedPrice'] as num?)?.toDouble() ?? 0.0,
      'suggestedEta': raw['suggestedEta'] ?? 15,
      // optional UI hints
      'peerName': raw['peerName'],
      'peerAvatar': raw['peerAvatar'],
    };

    return ChatThreadScreen.fromArgs(args);
  },
};
