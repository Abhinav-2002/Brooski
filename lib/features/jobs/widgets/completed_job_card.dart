import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/job_model.dart';

class CompletedJobCard extends StatelessWidget {
  final Job job;

  const CompletedJobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.jobTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('with ${job.posterName}'),
            const SizedBox(height: 12),
            Text('Completed on ${DateFormat('E, MMM d, yyyy').format(job.completionDate!)}'),
            const SizedBox(height: 12),
            Text('Final Earnings: ₹${job.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 32),
            _buildFeedbackSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildRatingDisplay(context, 'Your Rating', job.workerRating ?? 0),
        _buildRatingDisplay(context, 'Poster\'s Rating', job.posterRating ?? 0),
      ],
    );
  }

  Widget _buildRatingDisplay(BuildContext context, String title, double rating) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 20,
            );
          }),
        ),
      ],
    );
  }
}
