import 'dart:async';
import '../data/negotiation_repository.dart';
import '../models/negotiation_models.dart';

class NegotiationController {
  final repo = NegotiationRepository.instance;
  final String sessionId;

  Timer? _ttlTimer;

  NegotiationController(this.sessionId);

  Stream<NegotiationSession> watchSession() => repo.watchSession(sessionId);
  Stream<List<Offer>> watchOffers() => repo.watchOffers(sessionId);

  Future<void> init({
    required String jobId,
    required String posterId,
    required String workerId,
    int ttlSeconds = 480,
  }) => repo.initSession(
    sessionId: sessionId, jobId: jobId, posterId: posterId, workerId: workerId, ttlSeconds: ttlSeconds);

  Future<void> makeOffer({
    required bool isWorker,
    required double price,
    required int etaMinutes,
    String? notes,
  }) async {
    final expires = DateTime.now().add(const Duration(minutes: 8));
    final offer = Offer(
      offerId: 'offer_${DateTime.now().millisecondsSinceEpoch}',
      maker: isWorker ? Party.worker : Party.poster,
      price: price,
      startEtaMinutes: etaMinutes,
      notes: notes,
      expiresAt: expires,
      status: OfferStatus.pending,
    );
    await repo.makeOffer(sessionId, offer, isWorker: isWorker);
    _startTtlWatch(offer);
  }

  Future<void> accept(String offerId) => repo.acceptOffer(sessionId, offerId);
  Future<void> decline(String offerId) => repo.declineOffer(sessionId, offerId);

  void _startTtlWatch(Offer offer) {
    _ttlTimer?.cancel();
    final secs = offer.expiresAt.difference(DateTime.now()).inSeconds;
    _ttlTimer = Timer(Duration(seconds: secs > 0 ? secs : 1), () {
      repo.expireOffer(sessionId, offer.offerId);
    });
  }

  void dispose() {
    _ttlTimer?.cancel();
  }
}
