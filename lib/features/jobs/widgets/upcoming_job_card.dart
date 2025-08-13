import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/job_model.dart';

class UpcomingJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onWithdraw;

  const UpcomingJobCard({super.key, required this.job, required this.onWithdraw});

  @override
  Widget build(BuildContext context) {
    final isAccepted = job.status == JobStatus.accepted;
    final buttonText = isAccepted ? 'Start Travel & View Route' : 'View Live Route';
    final statusText = isAccepted ? 'ACCEPTED' : 'IN PROGRESS';
    final statusColor = isAccepted ? Colors.blue : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(job.posterImageUrl),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(job.posterName, style: const TextStyle(fontWeight: FontWeight.bold))),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'withdraw') {
                      onWithdraw();
                    } else if (value == 'contact') {
                      // TODO: Implement contact poster functionality
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'withdraw',
                      child: Text('Withdraw from Job'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'contact',
                      child: Text('Contact Poster'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(job.serviceIcon, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(job.jobTitle, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 8),
            Text(DateFormat('E, MMM d, yyyy hh:mm a').format(job.scheduledDateTime)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Final Price: ₹${job.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { /* TODO: Implement route viewing */ },
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
