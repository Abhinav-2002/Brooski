import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/job_model.dart';

class UpcomingJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onWithdraw;

  /// Optional: pass these if your `Job` model doesn't expose phone/destination.
  final String? posterPhone;
  final String? destinationQuery;

  const UpcomingJobCard({
    super.key,
    required this.job,
    required this.onWithdraw,
    this.posterPhone,
    this.destinationQuery,
  });

  bool get _isAccepted => job.status == JobStatus.accepted;

  String get _buttonText => _isAccepted ? 'Start Travel & View Route' : 'View Live Route';

  String get _statusText => _isAccepted ? 'ACCEPTED' : 'IN PROGRESS';

  Color get _statusColor => _isAccepted ? Colors.blue : Colors.green;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('E, MMM d, yyyy hh:mm a').format(job.scheduledDateTime);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: poster + menu
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(job.posterImageUrl),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    job.posterName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    switch (value) {
                      case 'withdraw':
                        onWithdraw();
                        break;
                      case 'contact':
                        if (posterPhone != null && posterPhone!.trim().isNotEmpty) {
                          await _contactPoster(posterPhone!);
                        } else {
                          _toast(context, 'Poster phone not available.');
                        }
                        break;
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

            // Title row: service icon + job title
            Row(
              children: [
                Icon(job.serviceIcon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.jobTitle,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Schedule
            Text(
              dateStr,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),

            const SizedBox(height: 16),

            // Price + status pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Final Price: ₹${job.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusText,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Primary CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final query = destinationQuery;
                  if (query == null || query.trim().isEmpty) {
                    _toast(context, 'Destination not available.');
                    return;
                  }
                  await _viewRoute(query);
                },
                child: Text(_buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // Helpers (class-level)
  // -------------------------

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _contactPoster(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _viewRoute(String destination) async {
    // Cross-platform Google Maps Directions link
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(destination)}&travelmode=driving',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
