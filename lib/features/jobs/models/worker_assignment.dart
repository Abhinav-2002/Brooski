import 'package:flutter/material.dart';

enum WorkerJobPhase { accepted, enRoute, arrived, working, completed, cancelled }

class WorkerAssignment {
  final String id;        // unique assignment id
  final String jobId;     // original discovery job id
  final String title;
  final String category;
  final IconData serviceIcon;

  final DateTime createdAt;
  final double price;

  // Poster
  final String posterName;
  final String posterImageUrl;
  final String? posterPhone;

  /// Destination: either "lat,lng" or an address string.
  final String destinationQuery;

  final WorkerJobPhase phase;
    // Back-compat alias for older code that expects `scheduledDateTime`
  DateTime get scheduledDateTime => createdAt;


  const WorkerAssignment({
    required this.id,
    required this.jobId,
    required this.title,
    required this.category,
    required this.serviceIcon,
    required this.createdAt,
    required this.price,
    required this.posterName,
    required this.posterImageUrl,
    required this.destinationQuery,
    this.posterPhone,
    this.phase = WorkerJobPhase.accepted,
  });

  WorkerAssignment copyWith({
    String? id,
    String? jobId,
    String? title,
    String? category,
    IconData? serviceIcon,
    DateTime? createdAt,
    double? price,
    String? posterName,
    String? posterImageUrl,
    String? posterPhone,
    String? destinationQuery,
    WorkerJobPhase? phase,
  }) {
    return WorkerAssignment(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      title: title ?? this.title,
      category: category ?? this.category,
      serviceIcon: serviceIcon ?? this.serviceIcon,
      createdAt: createdAt ?? this.createdAt,
      price: price ?? this.price,
      posterName: posterName ?? this.posterName,
      posterImageUrl: posterImageUrl ?? this.posterImageUrl,
      posterPhone: posterPhone ?? this.posterPhone,
      destinationQuery: destinationQuery ?? this.destinationQuery,
      phase: phase ?? this.phase,
    );
  }

  bool get isUpcoming =>
      phase == WorkerJobPhase.accepted ||
      phase == WorkerJobPhase.enRoute ||
      phase == WorkerJobPhase.arrived ||
      phase == WorkerJobPhase.working;

  bool get isDone => phase == WorkerJobPhase.completed || phase == WorkerJobPhase.cancelled;
}
