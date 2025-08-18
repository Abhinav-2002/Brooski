import 'dart:async';
import '../models/negotiation_models.dart';

/// Replace this with Firestore implementation.
/// This mock keeps state in-memory for demo purposes.
class NegotiationRepository {
  static final NegotiationRepository instance = NegotiationRepository._();
  NegotiationRepository._();

  final Map<String, NegotiationSession> _sessions = {};
  final Map<String, List<Offer>> _offers = {};
  final Map<String, StreamController<NegotiationSession>> _sessionCtrls = {};
  final Map<String, StreamController<List<Offer>>> _offerCtrls = {};

  Stream<NegotiationSession> watchSession(String sessionId) {
    _sessionCtrls.putIfAbsent(sessionId, () => StreamController.broadcast());
    final ctrl = _sessionCtrls[sessionId]!;
    if (_sessions.containsKey(sessionId)) {
      Future.microtask(() => ctrl.add(_sessions[sessionId]!));
    }
    return ctrl.stream;
  }

  Stream<List<Offer>> watchOffers(String sessionId) {
    _offerCtrls.putIfAbsent(sessionId, () => StreamController.broadcast());
    final ctrl = _offerCtrls[sessionId]!;
    Future.microtask(() => ctrl.add(List.unmodifiable(_offers[sessionId] ?? [])));
    return ctrl.stream;
  }

  Future<NegotiationSession> initSession({
    required String sessionId,
    required String jobId,
    required String posterId,
    required String workerId,
    int ttlSeconds = 480,
  }) async {
    final now = DateTime.now();
    final s = NegotiationSession(
      sessionId: sessionId,
      jobId: jobId,
      posterId: posterId,
      workerId: workerId,
      status: NegotiationStatus.inquiry,
      posterCountersUsed: 0,
      workerCountersUsed: 0,
      ttlSeconds: ttlSeconds,
      activeOfferId: null,
      createdAt: now,
      updatedAt: now,
    );
    _sessions[sessionId] = s;
    _sessionCtrls.putIfAbsent(sessionId, () => StreamController.broadcast()).add(s);
    _offers[sessionId] = [];
    _offerCtrls.putIfAbsent(sessionId, () => StreamController.broadcast()).add(const []);
    return s;
  }

  Future<void> makeOffer(String sessionId, Offer offer, {required bool isWorker}) async {
    final s = _sessions[sessionId]!;
    final updated = s.copyWith(
      status: s.status == NegotiationStatus.inquiry
        ? NegotiationStatus.offerMade
        : NegotiationStatus.counterMade,
      activeOfferId: offer.offerId,
      updatedAt: DateTime.now(),
      posterCountersUsed: isWorker ? s.posterCountersUsed : (s.posterCountersUsed),
      workerCountersUsed: isWorker ? (s.workerCountersUsed + 1) : s.workerCountersUsed,
    );
    _sessions[sessionId] = updated;
    _offers[sessionId]!.add(offer);
    _sessionCtrls[sessionId]!.add(updated);
    _offerCtrls[sessionId]!.add(List.unmodifiable(_offers[sessionId]!));
  }

  Future<void> acceptOffer(String sessionId, String offerId) async {
    final s = _sessions[sessionId]!;
    final updated = s.copyWith(
      status: NegotiationStatus.accepted,
      updatedAt: DateTime.now(),
      activeOfferId: offerId,
      lockedUntil: DateTime.now().add(const Duration(minutes: 5)),
    );
    _sessions[sessionId] = updated;
    _sessionCtrls[sessionId]!.add(updated);

    final list = _offers[sessionId]!;
    final idx = list.indexWhere((o) => o.offerId == offerId);
    if (idx >= 0) {
      list[idx] = list[idx].copyWith(status: OfferStatus.accepted);
      _offerCtrls[sessionId]!.add(List.unmodifiable(list));
    }
  }

  Future<void> declineOffer(String sessionId, String offerId) async {
    final list = _offers[sessionId]!;
    final idx = list.indexWhere((o) => o.offerId == offerId);
    if (idx >= 0) {
      list[idx] = list[idx].copyWith(status: OfferStatus.declined);
      _offerCtrls[sessionId]!.add(List.unmodifiable(list));
    }
  }

  Future<void> expireOffer(String sessionId, String offerId) async {
    final list = _offers[sessionId]!;
    final idx = list.indexWhere((o) => o.offerId == offerId);
    if (idx >= 0) {
      list[idx] = list[idx].copyWith(status: OfferStatus.expired);
      _offerCtrls[sessionId]!.add(List.unmodifiable(list));
    }
  }

  Future<void> updateStatus(String sessionId, NegotiationStatus status) async {
    final s = _sessions[sessionId]!;
    final updated = s.copyWith(status: status, updatedAt: DateTime.now());
    _sessions[sessionId] = updated;
    _sessionCtrls[sessionId]!.add(updated);
  }
}
