import 'package:brooski_app/features/jobs/models/job_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PosterProfileScreen extends StatelessWidget {
  final Poster poster;

  const PosterProfileScreen({Key? key, required this.poster}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(poster.name, style: GoogleFonts.montserrat()),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(poster.imageUrl),
              ),
              const SizedBox(height: 20),
              Text(
                'Profile for ${poster.name}',
                style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'This screen is a placeholder for the poster\'s full profile. More details will be available in a future update.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
