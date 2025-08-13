import 'package:google_maps_flutter/google_maps_flutter.dart';

class Poster {
  final String name;
  final String imageUrl;
  final bool isVerified;
  final double rating;
  final String phoneNumber;

  Poster({
    required this.name,
    required this.imageUrl,
    this.isVerified = false,
    this.rating = 0.0,
    required this.phoneNumber,
  });
}

class Job {
  final String id;
  final String title;
  final String category;
  final String description;
  final int pay;
  final String urgency;
  final LatLng location;
  final String address;
  final DateTime postedAt;
  final List<String> mediaUrls;
  final Poster poster;

  // Ephemeral data, calculated on the fly
  final double? distance;

  Job({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.pay,
    required this.urgency,
    required this.location,
    required this.address,
    required this.postedAt,
    required this.poster,
    this.mediaUrls = const [],
    this.distance,
  });
}
