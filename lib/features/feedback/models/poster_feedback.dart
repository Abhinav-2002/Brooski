import 'package:flutter/foundation.dart';

class PosterFeedback {
  final String assignmentId;       // WorkerAssignment.id
  final String jobId;              // discovery.Job.id
  final String posterName;         // snapshot for display
  final String posterImageUrl;     // snapshot for display
  final int rating;                // 1..5
  final List<String> tags;         // quick reasons
  final String comment;            // free text
  final DateTime createdAt;

  const PosterFeedback({
    required this.assignmentId,
    required this.jobId,
    required this.posterName,
    required this.posterImageUrl,
    required this.rating,
    required this.tags,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'assignmentId': assignmentId,
    'jobId': jobId,
    'posterName': posterName,
    'posterImageUrl': posterImageUrl,
    'rating': rating,
    'tags': tags,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
  };
}
