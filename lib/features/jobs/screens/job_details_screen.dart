import 'package:brooski_app/features/jobs/models/job_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brooski_app/features/poster/screens/poster_profile_screen.dart';

class JobDetailsScreen extends StatelessWidget {
  final Job job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF2ECC71);
    final Color secondaryGreen = const Color(0xFF27AE60);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeader(primaryGreen, secondaryGreen),
                ),
                leading: const SizedBox.shrink(),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildJobInfoSection(primaryGreen),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Job Description'),
                      const SizedBox(height: 8),
                      Text(
                        job.description,
                        style: GoogleFonts.lato(fontSize: 16, height: 1.5, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 24),
                      if (job.mediaUrls.isNotEmpty) ...[
                        _buildSectionTitle('Media'),
                        const SizedBox(height: 12),
                        _buildMediaSection(),
                      ],
                      const SizedBox(height: 24),
                      _buildSectionTitle('Posted by'),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PosterProfileScreen(poster: job.poster),
                          ));
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: _buildPosterPreview(primaryGreen),
                      ),
                      const SizedBox(height: 120), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildFloatingBackButton(context),
          _buildBottomBar(context, primaryGreen),
        ],
      ),
    );
  }

  Widget _buildFloatingBackButton(BuildContext context) {
    return Positioned(
      top: 40,
      left: 16,
      child: CircleAvatar(
        backgroundColor: Colors.black.withOpacity(0.5),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildHeader(Color primary, Color secondary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
          ),
          const SizedBox(height: 16),
          Text(
            '₹${job.pay}',
            style: GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildJobInfoSection(Color primaryGreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoChip(Icons.category_outlined, job.category, primaryGreen),
        _buildInfoChip(Icons.flag_outlined, job.urgency, Colors.orange),
        _buildInfoChip(Icons.social_distance_outlined, '${job.distance?.toStringAsFixed(1) ?? 'N/A'} km', Colors.teal),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Chip(
      avatar: Icon(icon, color: color, size: 20),
      label: Text(text, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: color)),
      backgroundColor: color.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }

  Widget _buildMediaSection() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: job.mediaUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                job.mediaUrls[index],
                width: 140,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.grey[800]),
    );
  }

  Widget _buildPosterPreview(Color primaryGreen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(job.poster.imageUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.poster.name, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('12 jobs posted', style: GoogleFonts.lato(color: Colors.grey[600])), // Placeholder
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (job.poster.isVerified)
                Chip(
                  label: const Text('Verified'),
                  backgroundColor: primaryGreen.withOpacity(0.1),
                  labelStyle: GoogleFonts.lato(color: primaryGreen, fontWeight: FontWeight.bold),
                  padding: EdgeInsets.zero,
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text('${job.poster.rating}', style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Color primaryGreen) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'Chat & Negotiate',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: Text('Accept Job', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

