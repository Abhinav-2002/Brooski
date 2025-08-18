import 'dart:async';
import 'package:flutter/material.dart';
import '../models/poster_feedback.dart';

class FeedbackService extends ChangeNotifier {
  FeedbackService._();
  static final FeedbackService instance = FeedbackService._();

  // Simple store; replace with Firestore/REST later
  final Map<String, PosterFeedback> _byAssignment = {};

  PosterFeedback? getByAssignment(String assignmentId) => _byAssignment[assignmentId];
  bool hasForAssignment(String assignmentId) => _byAssignment.containsKey(assignmentId);

  Future<void> submit(PosterFeedback fb) async {
    // Simulate latency
    await Future.delayed(const Duration(milliseconds: 500));
    _byAssignment[fb.assignmentId] = fb;
    notifyListeners();
  }
}
