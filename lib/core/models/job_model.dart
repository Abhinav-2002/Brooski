import 'package:flutter/material.dart';

enum JobStatus { accepted, inProgress, completed, cancelled }

class Job {
  final String id;
  final String jobTitle;
  final String category;
  final IconData serviceIcon;
  final DateTime scheduledDateTime;
  final double price;

  // poster
  final String posterName;
  final String posterImageUrl;
  final String? posterPhone; // optional

  // routing
  /// This can be "lat,lng" or a plain address string.
  final String? destinationQuery;

  // state
  final JobStatus status;

  const Job({
    required this.id,
    required this.jobTitle,
    required this.category,
    required this.serviceIcon,
    required this.scheduledDateTime,
    required this.price,
    required this.posterName,
    required this.posterImageUrl,
    this.posterPhone,
    this.destinationQuery,
    this.status = JobStatus.accepted,
  });

  Job copyWith({
    String? id,
    String? jobTitle,
    String? category,
    IconData? serviceIcon,
    DateTime? scheduledDateTime,
    double? price,
    String? posterName,
    String? posterImageUrl,
    String? posterPhone,
    String? destinationQuery,
    JobStatus? status,
  }) {
    return Job(
      id: id ?? this.id,
      jobTitle: jobTitle ?? this.jobTitle,
      category: category ?? this.category,
      serviceIcon: serviceIcon ?? this.serviceIcon,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      price: price ?? this.price,
      posterName: posterName ?? this.posterName,
      posterImageUrl: posterImageUrl ?? this.posterImageUrl,
      posterPhone: posterPhone ?? this.posterPhone,
      destinationQuery: destinationQuery ?? this.destinationQuery,
      status: status ?? this.status,
    );
  }
}
