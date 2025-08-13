import 'package:flutter/material.dart';

// Enum to represent the status of a job. This provides type-safety and clarity.
enum JobStatus { accepted, inProgress, completed, canceled }

class Job {
  final String id;
  final String jobTitle;
  final String posterName;
  final String posterImageUrl;
  final IconData serviceIcon;
  final DateTime scheduledDateTime;
  final double price;
  final JobStatus status;
  final DateTime? completionDate;
  final double? workerRating;
  final double? posterRating;

  Job({
    required this.id,
    required this.jobTitle,
    required this.posterName,
    required this.posterImageUrl,
    required this.serviceIcon,
    required this.scheduledDateTime,
    required this.price,
    required this.status,
    this.completionDate,
    this.workerRating,
    this.posterRating,
  });
}
