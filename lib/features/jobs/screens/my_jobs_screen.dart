import 'package:flutter/material.dart';
import '../../../core/models/job_model.dart';
import '../services/dummy_job_service.dart';
import '../widgets/upcoming_job_card.dart';
import '../widgets/completed_job_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/withdraw_job_dialog.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Job> _upcomingJobs = [];
  List<Job> _completedJobs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadJobs();
  }

  void _loadJobs() {
    final allJobs = DummyJobService.getJobs();
    setState(() {
      _upcomingJobs = allJobs.where((job) => job.status == JobStatus.accepted || job.status == JobStatus.inProgress).toList();
      _completedJobs = allJobs.where((job) => job.status == JobStatus.completed).toList();
    });
  }

  void _withdrawJob(String jobId) {
    // In a real app, this would be an API call.
    // For now, we'll just remove it from the list.
    setState(() {
      _upcomingJobs.removeWhere((job) => job.id == jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingJobsList(),
          _buildCompletedJobsList(),
        ],
      ),
    );
  }

  Widget _buildUpcomingJobsList() {
    if (_upcomingJobs.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.map,
        title: 'No upcoming jobs yet.',
        subtitle: 'When a poster accepts your application, you\'ll see the job here.',
        actionText: 'Find New Jobs',
        onActionPressed: () { Navigator.of(context).pop(); }, // Navigate back to home
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _upcomingJobs.length,
      itemBuilder: (context, index) {
        return UpcomingJobCard(
          job: _upcomingJobs[index],
          onWithdraw: () => _showWithdrawDialog(_upcomingJobs[index].id),
        );
      },
    );
  }

  Widget _buildCompletedJobsList() {
    if (_completedJobs.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.checklist,
        title: 'Your job history is empty.',
        subtitle: 'Finish your first job to see a summary of your work and earnings here.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _completedJobs.length,
      itemBuilder: (context, index) {
        return CompletedJobCard(job: _completedJobs[index]);
      },
    );
  }

  void _showWithdrawDialog(String jobId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WithdrawJobDialog(
          jobId: jobId,
          onConfirm: (id) {
            _withdrawJob(id);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
