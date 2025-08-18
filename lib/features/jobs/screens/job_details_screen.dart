import 'package:brooski_app/features/jobs/models/job_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brooski_app/features/poster/screens/poster_profile_screen.dart';
import 'package:brooski_app/features/chat/screens/chat_thread_screen.dart';


// Accept flow (single active job) + jump to Action Map
import 'package:brooski_app/features/jobs/data/worker_jobs_service.dart';
import 'package:brooski_app/features/worker/screens/worker_dashboard_screen.dart';

class JobDetailsScreen extends StatelessWidget {
  final Job job;

  const JobDetailsScreen({super.key, required this.job});

  WorkerJobsService get _jobs => WorkerJobsService.instance;

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2ECC71);
    const Color primaryDark = Color(0xFF27AE60);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Job Details', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              _Header(job: job, primary: primary, primaryDark: primaryDark),
              _GlassInfoCard(job: job, primary: primary),
              const SizedBox(height: 12),
              _Section(
                title: 'Job Description',
                child: Text(
                  job.description,
                  style: GoogleFonts.lato(fontSize: 16, height: 1.55, color: Colors.grey[800]),
                ),
              ),
              if (job.mediaUrls.isNotEmpty) ...[
                const SizedBox(height: 8),
                _Section(
                  title: 'Media',
                  child: SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(job.mediaUrls[i], width: 160, height: 140, fit: BoxFit.cover),
                      ),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: job.mediaUrls.length,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              _Section(
                title: 'Posted by',
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PosterProfileScreen(poster: job.poster)),
                    );
                  },
                  child: _PosterPreview(job: job, primary: primary),
                ),
              ),
            ],
          ),

          // Sticky bottom actions; shows "Chat & Negotiate" only when there is no active job yet
          AnimatedBuilder(
            animation: _jobs,
            builder: (context, _) => _BottomActions(
              showChat: !_jobs.hasActive, // pre-accept only
              onChat: () => _openInAppChat(context),
              onAccept: () => _confirmAccept(context),
              acceptEnabled: !_jobs.hasActive, // blocked if another job is active
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Actions ----------

  void _openInAppChat(BuildContext context) {
    // Build a stable poster identity from what we *do* have.
    final posterKey = (job.poster.phoneNumber?.isNotEmpty == true)
        ? 'poster:phone:${job.poster.phoneNumber}'
        : 'poster:name:${job.poster.name.toLowerCase().replaceAll(RegExp(r"\\s+"), "_")}';

    // If we don't have an auth-backed worker id exposed yet, pass empty string for now.
    const workerId = ''; // TODO: wire to FirebaseAuth or your service later

    final sessionId = 'job:${job.id}::poster:$posterKey::worker:$workerId';

    Navigator.of(context).pushNamed(
      ChatThreadScreen.routeName,
      arguments: {
        'sessionId': sessionId,
        'jobId': job.id,
        'posterId': posterKey,
        'workerId': workerId,
        'isWorker': true,
        'suggestedPrice': (job.pay ?? 0).toDouble(),
        'suggestedEta': 15,
      },
    );
  }

  Future<void> _confirmAccept(BuildContext context) async {
    if (_jobs.hasActive) {
      _toast(context, 'You already have an active job. Complete or cancel it first.');
      return;
    }

    final ok = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AcceptSheet(job: job),
    );

    if (ok != true) return;

    final created = _jobs.startActiveFromDiscovery(job);
    if (created == null) return;

    // Jump to Home (Action Map). Replace stack so back doesn’t return here.
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WorkerDashboardScreen(initialIndex: 0)),
      (route) => false,
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ================== UI PARTS ==================

class _Header extends StatelessWidget {
  const _Header({required this.job, required this.primary, required this.primaryDark});

  final Job job;
  final Color primary;
  final Color primaryDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary, primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Title + Pay
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    )),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.currency_rupee, color: Colors.white, size: 18),
                          Text('${job.pay}',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.place_outlined, color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          Text('${job.distance?.toStringAsFixed(1) ?? 'N/A'} km',
                              style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Poster avatar
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(job.poster.imageUrl),
          ),
        ],
      ),
    );
  }
}

class _GlassInfoCard extends StatelessWidget {
  const _GlassInfoCard({required this.job, required this.primary});

  final Job job;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final chips = <_FactChip>[
      _FactChip(icon: Icons.category_outlined, label: job.category, color: primary),
      _FactChip(icon: Icons.flag_outlined, label: job.urgency, color: Colors.orange),
      _FactChip(
        icon: Icons.verified_outlined,
        label: job.poster.isVerified ? 'Verified Poster' : 'Unverified Poster',
        color: job.poster.isVerified ? Colors.blue : Colors.grey,
      ),
      _FactChip(
        icon: Icons.star_rounded,
        label: job.poster.rating.toStringAsFixed(1),
        color: Colors.amber.shade700,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: chips.map((c) => c).toList(),
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(label, style: GoogleFonts.lato(fontWeight: FontWeight.w700, color: color)),
      backgroundColor: color.withOpacity(0.12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey[900])),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _PosterPreview extends StatelessWidget {
  const _PosterPreview({required this.job, required this.primary});

  final Job job;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 28, backgroundImage: NetworkImage(job.poster.imageUrl)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.poster.name, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('12 jobs posted', style: GoogleFonts.lato(color: Colors.grey[600])), // replace with real metric
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (job.poster.isVerified)
                Chip(
                  label: const Text('Verified'),
                  backgroundColor: primary.withOpacity(0.12),
                  labelStyle: GoogleFonts.lato(color: primary, fontWeight: FontWeight.w700),
                  padding: EdgeInsets.zero,
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(job.poster.rating.toStringAsFixed(1),
                      style: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.showChat,
    required this.onChat,
    required this.onAccept,
    required this.acceptEnabled,
  });

  final bool showChat;
  final VoidCallback onChat;
  final VoidCallback onAccept;
  final bool acceptEnabled;

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2ECC71);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            if (showChat) // pre-accept only
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onChat,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat & Negotiate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            if (showChat) const SizedBox(width: 12),
            Expanded(
              flex: showChat ? 2 : 1,
              child: ElevatedButton.icon(
                onPressed: acceptEnabled ? onAccept : null,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(acceptEnabled ? 'Accept Job' : 'Active Job in Progress'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AcceptSheet extends StatelessWidget {
  const _AcceptSheet({required this.job});
  final Job job;

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2ECC71);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(backgroundImage: NetworkImage(job.poster.imageUrl)),
            title: Text(job.title, style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
            subtitle: Text('Offer: ₹${job.pay}', style: GoogleFonts.lato()),
            trailing: Chip(
              label: Text('${job.distance?.toStringAsFixed(1) ?? 'N/A'} km'),
              backgroundColor: Colors.grey.shade100,
              side: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: Colors.orange),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Accepting will set this as your only active job until you complete or cancel it.',
                  style: GoogleFonts.lato(color: Colors.grey[800]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Not now'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Accept & Start'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
