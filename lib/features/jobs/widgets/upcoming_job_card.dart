import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../jobs/models/worker_assignment.dart';

class UpcomingJobCard extends StatelessWidget {
  final WorkerAssignment assignment;
  final VoidCallback onWithdraw;
  final VoidCallback onResumeInApp; // new: to reopen in-app Action Map

  const UpcomingJobCard({
    super.key,
    required this.assignment,
    required this.onWithdraw,
    required this.onResumeInApp,
  });

 String get _statusText {
  switch (assignment.phase) {
    case WorkerJobPhase.accepted:  return 'ACCEPTED';
    case WorkerJobPhase.enRoute:   return 'EN ROUTE';
    case WorkerJobPhase.arrived:   return 'ARRIVED';
    case WorkerJobPhase.working:   return 'WORKING';
    case WorkerJobPhase.completed: return 'COMPLETED';
    case WorkerJobPhase.cancelled: return 'CANCELLED';
  }
}

Color get _statusColor {
  switch (assignment.phase) {
    case WorkerJobPhase.accepted:  return Colors.blue;
    case WorkerJobPhase.enRoute:   return Colors.indigo;
    case WorkerJobPhase.arrived:   return Colors.orange;
    case WorkerJobPhase.working:   return Colors.teal;
    case WorkerJobPhase.completed: return Colors.green;
    case WorkerJobPhase.cancelled: return Colors.red;
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('E, MMM d, yyyy hh:mm a').format(assignment.scheduledDateTime);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(assignment.posterImageUrl),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    assignment.posterName,
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
                        final phone = assignment.posterPhone;
                        if (phone == null || phone.trim().isEmpty) {
                          _toast(context, 'Poster phone not available.');
                        } else {
                          final Uri launchUri = Uri(scheme: 'tel', path: phone.trim());
                          await launchUrl(launchUri, mode: LaunchMode.externalApplication);
                        }
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'withdraw', child: Text('Withdraw from Job')),
                    PopupMenuItem(value: 'contact', child: Text('Contact Poster')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Row(
              children: [
                Icon(assignment.serviceIcon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    assignment.title,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(dateStr, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
            const SizedBox(height: 16),

            // Price + status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Final Price: ₹${assignment.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: _statusColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(_statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.directions),
                    label: const Text('Open in Maps'),
                    onPressed: () async {
                      final url = Uri.parse(
                        'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(assignment.destinationQuery)}&travelmode=driving',
                      );
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.navigation),
                    label: const Text('Resume In-App'),
                    onPressed: onResumeInApp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
