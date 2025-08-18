class WorkerAccountService {
  WorkerAccountService._();
  static final instance = WorkerAccountService._();

  WorkerProfile currentWorker = WorkerProfile(
    uid: 'worker_demo',
    name: 'Raju',
    photoUrl:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=256&q=80',
    skills: const ['Electrician', 'Plumbing'],
    kycVerified: true,
    rating: 4.6,
    reviews: 128,
    wallet: 1250.50,
  );

  Future<void> updateProfile({required String name, required String skillsCsv}) async {
    currentWorker = currentWorker.copyWith(
      name: name,
      skills: skillsCsv
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  Future<void> signOut() async {
    // hook to FirebaseAuth.instance.signOut()
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

class WorkerProfile {
  final String uid;
  final String name;
  final String photoUrl;
  final List<String> skills;
  final bool kycVerified;
  final double rating;
  final int reviews;
  final double wallet;

  WorkerProfile({
    required this.uid,
    required this.name,
    required this.photoUrl,
    required this.skills,
    required this.kycVerified,
    required this.rating,
    required this.reviews,
    required this.wallet,
  });

  WorkerProfile copyWith({
    String? name,
    List<String>? skills,
  }) {
    return WorkerProfile(
      uid: uid,
      name: name ?? this.name,
      photoUrl: photoUrl,
      skills: skills ?? this.skills,
      kycVerified: kycVerified,
      rating: rating,
      reviews: reviews,
      wallet: wallet,
    );
  }
}
