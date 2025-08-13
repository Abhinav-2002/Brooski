import 'package:flutter/material.dart';
import '../../../core/models/job_model.dart';

class DummyJobService {
  static List<Job> getJobs() {
    return [
      Job(
        id: '1',
        jobTitle: 'Urgent AC Repair',
        posterName: 'John Doe',
        posterImageUrl: 'https://via.placeholder.com/150',
        serviceIcon: Icons.ac_unit,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 2)),
        price: 750,
        status: JobStatus.accepted,
      ),
      Job(
        id: '2',
        jobTitle: 'Garden Landscaping',
        posterName: 'Jane Smith',
        posterImageUrl: 'https://via.placeholder.com/150',
        serviceIcon: Icons.eco,
        scheduledDateTime: DateTime.now().add(const Duration(days: 1)),
        price: 2500,
        status: JobStatus.accepted,
      ),
      Job(
        id: '3',
        jobTitle: 'House Deep Cleaning',
        posterName: 'Peter Jones',
        posterImageUrl: 'https://via.placeholder.com/150',
        serviceIcon: Icons.cleaning_services,
        scheduledDateTime: DateTime.now().subtract(const Duration(days: 2)),
        price: 1200,
        status: JobStatus.completed,
        completionDate: DateTime.now().subtract(const Duration(days: 2)),
        workerRating: 5,
        posterRating: 4.5,
      ),
       Job(
        id: '4',
        jobTitle: 'Kitchen Sink Plumbing',
        posterName: 'Sam Wilson',
        posterImageUrl: 'https://via.placeholder.com/150',
        serviceIcon: Icons.plumbing,
        scheduledDateTime: DateTime.now().add(const Duration(hours: 3)),
        price: 500,
        status: JobStatus.inProgress,
      ),
      Job(
        id: '5',
        jobTitle: 'Exterior Painting',
        posterName: 'Maria Hill',
        posterImageUrl: 'https://via.placeholder.com/150',
        serviceIcon: Icons.format_paint,
        scheduledDateTime: DateTime.now().subtract(const Duration(days: 5)),
        price: 8000,
        status: JobStatus.completed,
        completionDate: DateTime.now().subtract(const Duration(days: 5)),
        workerRating: 4,
        posterRating: 5,
      ),
    ];
  }
}
