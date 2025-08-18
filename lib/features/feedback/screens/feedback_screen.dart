import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../feedback/data/feedback_service.dart';
import '../../feedback/models/poster_feedback.dart';

class FeedbackScreen extends StatefulWidget {
  final String assignmentId;
  final String jobId;
  final String posterName;
  final String posterImageUrl;

  const FeedbackScreen({
    super.key,
    required this.assignmentId,
    required this.jobId,
    required this.posterName,
    required this.posterImageUrl,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  final Set<String> _tags = {};
  final TextEditingController _comment = TextEditingController();
  bool _submitting = false;

  static const _positiveTags = [
    'On time', 'Clear instructions', 'Polite', 'Easy access', 'Quick approval'
  ];
  static const _negativeTags = [
    'Late payment', 'Rude', 'Wrong address', 'Unclear scope', 'Wait time'
  ];

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating')),
      );
      return;
    }
    setState(() => _submitting = true);
    final fb = PosterFeedback(
      assignmentId: widget.assignmentId,
      jobId: widget.jobId,
      posterName: widget.posterName,
      posterImageUrl: widget.posterImageUrl,
      rating: _rating,
      tags: _tags.toList(),
      comment: _comment.text.trim(),
      createdAt: DateTime.now(),
    );
    await FeedbackService.instance.submit(fb);
    if (!mounted) return;
    setState(() => _submitting = false);

    // Success → pop to dashboard or show success page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks for your feedback!')),
    );
    Navigator.of(context).pop(); // pop feedback
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF2ECC71);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate the Poster'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(widget.posterImageUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.posterName,
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text('How was your experience?', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                final idx = i + 1;
                final filled = idx <= _rating;
                return IconButton(
                  onPressed: () => setState(() => _rating = idx),
                  icon: Icon(
                    filled ? Icons.star : Icons.star_border,
                    size: 32,
                    color: filled ? Colors.amber : Colors.grey.shade400,
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),
            Text('What went well?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _positiveTags.map((t) => FilterChip(
                label: Text(t),
                selected: _tags.contains(t),
                onSelected: (sel) => setState(() { sel ? _tags.add(t) : _tags.remove(t); }),
                selectedColor: primary.withValues(alpha: 0.15),
                checkmarkColor: primary,
              )).toList(),
            ),

            const SizedBox(height: 16),
            Text('What could be improved?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _negativeTags.map((t) => FilterChip(
                label: Text(t),
                selected: _tags.contains(t),
                onSelected: (sel) => setState(() { sel ? _tags.add(t) : _tags.remove(t); }),
                selectedColor: Colors.red.withValues(alpha: 0.12),
                checkmarkColor: Colors.red,
              )).toList(),
            ),

            const SizedBox(height: 16),
            Text('Additional comments', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _comment,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Share any details that would help future workers',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _submitting ? const SizedBox(
                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ) : const Icon(Icons.send),
                label: Text(_submitting ? 'Submitting...' : 'Submit Feedback'),
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
