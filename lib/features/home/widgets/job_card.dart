import 'package:brooski_app/features/jobs/models/job_model.dart';
import 'package:flutter/material.dart';
import 'package:brooski_app/features/jobs/screens/job_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class JobCard extends StatefulWidget {
  final Job job;
  final bool isSelected;
  final Function(Job) onAccept;

  const JobCard({Key? key, required this.job, required this.isSelected, required this.onAccept}) : super(key: key);

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _isExpanded = false;

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'electrical':
        return Icons.electrical_services_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'carpentry':
        return Icons.handyman;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.isSelected ? 1.0 : 0.9;
    final elevation = widget.isSelected ? 12.0 : 4.0;
    final cardHeight = _isExpanded ? MediaQuery.of(context).size.height * 0.8 : 140.0;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailsScreen(job: widget.job),
            ),
          );
        },
        child: Card(
          elevation: elevation,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            curve: Curves.fastOutSlowIn,
            height: cardHeight,
            child: Material(
              color: Colors.white,
              child: _isExpanded ? _buildFullDetailCard() : _buildPreviewCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    bool isUrgent = widget.job.urgency == 'Now';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Top Section: Title and Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.job.title,
                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '₹${widget.job.pay}',
                style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF388E3C)),
              ),
            ],
          ),

          // Second Row: Short Description
          Text(
            widget.job.description,
            style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Divider
          const Divider(height: 1, thickness: 1),

          // Bottom Row: Metadata and Action
          Row(
            children: [
              // Category
              Icon(_getCategoryIcon(widget.job.category), color: const Color(0xFF2E7D32), size: 20),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  widget.job.category,
                  style: GoogleFonts.lato(fontWeight: FontWeight.w600, color: const Color(0xFF2E7D32)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),

              // Urgency Badge
              if (isUrgent) ...[
                const SizedBox(width: 8),
                Icon(Icons.local_fire_department, color: Colors.red[700], size: 18),
                const SizedBox(width: 4),
                Text(
                  'Urgent',
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.red[700]),
                ),
              ],

              const Spacer(),

              // Distance
              Icon(Icons.pin_drop_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${widget.job.distance?.toStringAsFixed(1) ?? '...'} km',
                style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[700]),
              ),

              const SizedBox(width: 8),

              // Accept Button
              ElevatedButton(
                onPressed: () => widget.onAccept(widget.job),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                child: const Text('Accept'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFullDetailCard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildJobInfoSection(),
          const Divider(height: 32, thickness: 1),
          _buildSectionTitle('Description'),
          Text(widget.job.description, style: GoogleFonts.lato(fontSize: 15, height: 1.5)),
          if (widget.job.mediaUrls.isNotEmpty) ...[
            const Divider(height: 32, thickness: 1),
            _buildSectionTitle('Media'),
            _buildMediaSection(),
          ],
          const Divider(height: 32, thickness: 1),
          _buildSectionTitle('Posted By'),
          _buildPosterPreview(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.job.title,
            style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          '₹${widget.job.pay}',
          style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF388E3C)),
        ),
      ],
    );
  }

  Widget _buildJobInfoSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildInfoChip(Icons.handyman, widget.job.category),
        ),
        _buildInfoChip(Icons.location_pin, widget.job.address, flex: 2),
        _buildInfoChip(Icons.calendar_today_outlined, DateFormat('MMM d, h:mm a').format(widget.job.postedAt)),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lato(fontSize: 13, color: Colors.grey[800]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
    );
  }

  Widget _buildMediaSection() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.job.mediaUrls.length,
        itemBuilder: (context, index) {
          return Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Image.network(widget.job.mediaUrls[index], width: 80, height: 80, fit: BoxFit.cover),
          );
        },
      ),
    );
  }

  Widget _buildPosterPreview() {
    final poster = widget.job.poster;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(radius: 24, backgroundImage: NetworkImage(poster.imageUrl)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(poster.name, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
                    if (poster.isVerified)
                      const Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Icon(Icons.verified, color: Colors.blue, size: 16),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(poster.rating.toStringAsFixed(1), style: GoogleFonts.lato(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => print('Negotiate & Chat Tapped'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2ECC71),
              side: const BorderSide(color: Color(0xFF2ECC71), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Negotiate & Chat', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => widget.onAccept(widget.job),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Accept Job', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
