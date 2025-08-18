import 'package:flutter/material.dart';

import '../../jobs/data/worker_jobs_service.dart';
import '../../jobs/models/worker_assignment.dart';
import '../../worker/screens/worker_dashboard_screen.dart';
import '../widgets/upcoming_job_card.dart';
import '../../feedback/data/feedback_service.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final WorkerJobsService _svc = WorkerJobsService.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _withdraw(String assignmentId) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Withdraw from job?'),
        content: const Text(
            'Withdrawing may affect your reliability score. Do you want to continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('No')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              _svc.withdraw(assignmentId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You withdrew from the job.')),
              );
            },
            child: const Text('Yes, withdraw'),
          ),
        ],
      ),
    );
  }

 // inside _resumeInApp
void _resumeInApp(WorkerAssignment a) {
  WorkerJobsService.instance.resumeActive(a);
  // Jump to Home tab where Action Map will show
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const WorkerDashboardScreen(initialIndex: 0)),
    (route) => false,
  );
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _svc,
      builder: (context, _) {
        final upcoming = _svc.upcoming;
        final completed = _svc.completed;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: const Text('My Jobs'),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _UpcomingTab(
                jobs: upcoming,
                onWithdraw: _withdraw,
                onResumeInApp: _resumeInApp,
              ),
              _CompletedTab(jobs: completed),
            ],
          ),
        );
      },
    );
  }
}

class _UpcomingTab extends StatelessWidget {
  final List<WorkerAssignment> jobs;
  final void Function(String id) onWithdraw;
  final void Function(WorkerAssignment a) onResumeInApp;

  const _UpcomingTab({
    required this.jobs,
    required this.onWithdraw,
    required this.onResumeInApp,
  });

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) return const Center(child: Text('No upcoming jobs'));
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final a = jobs[index];
        return UpcomingJobCard(
          assignment: a,
          onWithdraw: () => onWithdraw(a.id),
          onResumeInApp: () => onResumeInApp(a),
        );
      },
    );
  }
}

class _CompletedTab extends StatelessWidget {
  final List<WorkerAssignment> jobs;

  const _CompletedTab({required this.jobs});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) return const Center(child: Text('No completed jobs yet'));
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: jobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final j = jobs[i];
        final hasFb = FeedbackService.instance.hasForAssignment(j.id);
        
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          leading: CircleAvatar(backgroundImage: NetworkImage(j.posterImageUrl)),
          title: Text(j.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Completed on ${j.scheduledDateTime.toLocal().toString().substring(0, 16)}'),
              if (hasFb)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Text('Feedback submitted', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
            ],
          ),
          trailing: Text('₹${j.price.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: Colors.green.shade50,
        );
      },
    );
  }
}
