import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/worker_assignment.dart';
import 'package:brooski_app/features/jobs/models/job_model.dart' as discovery;

class WorkerJobsService extends ChangeNotifier {
  WorkerJobsService._();
  static final WorkerJobsService instance = WorkerJobsService._();

  final _uuid = const Uuid();
  final List<WorkerAssignment> _assignments = [];
  WorkerAssignment? _active;

  // READ
  WorkerAssignment? get active => _active;
  List<WorkerAssignment> get upcoming => _assignments.where((a) => a.isUpcoming).toList();
  List<WorkerAssignment> get completed => _assignments.where((a) => a.phase == WorkerJobPhase.completed).toList();

  /// Enforce: only one active job at a time.
  bool get hasActive => _active != null;

  /// Returns false if an active job already exists.
  bool canAccept() => !hasActive;

  /// Accept from discovery and mark as active. Returns null if not allowed.
  WorkerAssignment? startActiveFromDiscovery(discovery.Job job) {
    if (!canAccept()) return null;

    final dest = (job.address != null && job.address!.trim().isNotEmpty)
        ? job.address!.trim()
        : '${job.location.latitude},${job.location.longitude}';

    final assignment = WorkerAssignment(
      id: _uuid.v4(),
      jobId: job.id,
      title: job.title,
      category: job.category,
      serviceIcon: _iconForCategory(job.category),
      createdAt: DateTime.now(),
      price: job.pay.toDouble(),
      posterName: job.poster.name,
      posterImageUrl: job.poster.imageUrl,
      posterPhone: job.poster.phoneNumber,
      destinationQuery: dest,
      phase: WorkerJobPhase.accepted,
    );

    _assignments.add(assignment);
    _active = assignment;
    notifyListeners();
    return assignment;
  }

  /// Re-activate an existing assignment (from My Jobs).
  void resumeActive(WorkerAssignment assignment) {
    _active = assignment;
    notifyListeners();
  }

  // —— Transitions for the active job ——
  void startEnRoute() => _setActivePhase(WorkerJobPhase.enRoute);
  void markArrived()  => _setActivePhase(WorkerJobPhase.arrived);
  void startWorking() => _setActivePhase(WorkerJobPhase.working);
  void completeActive() {
    _setActivePhase(WorkerJobPhase.completed);
    _active = null;
    notifyListeners();
  }

  void cancelActive() {
    if (_active == null) return;
    _updateAssignment(_active!.id, (a) => a.copyWith(phase: WorkerJobPhase.cancelled));
    _active = null;
    notifyListeners();
  }

  // Withdraw removes the assignment entirely (only if not active or not working).
  void withdraw(String assignmentId) {
    if (_active?.id == assignmentId) {
      // If trying to withdraw an active job, treat as cancel
      cancelActive();
      return;
    }
    _assignments.removeWhere((a) => a.id == assignmentId);
    notifyListeners();
  }

  // —— Helpers ——
  void _setActivePhase(WorkerJobPhase phase) {
    if (_active == null) return;
    _updateAssignment(_active!.id, (a) => a.copyWith(phase: phase));
    notifyListeners();
  }

  void _updateAssignment(String id, WorkerAssignment Function(WorkerAssignment) updater) {
    final idx = _assignments.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    _assignments[idx] = updater(_assignments[idx]);

    if (_active?.id == id) {
      _active = _assignments[idx];
    }
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'plumbing': return Icons.plumbing;
      case 'electrical': return Icons.electrical_services;
      case 'cleaning': return Icons.cleaning_services_outlined;
      case 'gardening': return Icons.eco_outlined;
      case 'carpentry': return Icons.handyman_outlined;
      default: return Icons.work_outline;
    }
  }
}
