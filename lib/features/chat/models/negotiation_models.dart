import 'package:flutter/foundation.dart';

enum NegotiationStatus {
  idle, inquiry, offerMade, counterMade, accepted, enRoute, onSite, wip, completed, ended
}

enum OfferStatus { pending, accepted, declined, expired }
enum Party { poster, worker }

@immutable
class NegotiationSession {
  final String sessionId;
  final String jobId;
  final String posterId;
  final String workerId;
  final NegotiationStatus status;
  final int posterCountersUsed;
  final int workerCountersUsed;
  final int ttlSeconds;
  final String? activeOfferId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lockedUntil;

  const NegotiationSession({
    required this.sessionId,
    required this.jobId,
    required this.posterId,
    required this.workerId,
    required this.status,
    required this.posterCountersUsed,
    required this.workerCountersUsed,
    required this.ttlSeconds,
    required this.activeOfferId,
    required this.createdAt,
    required this.updatedAt,
    this.lockedUntil,
  });

  bool get isAccepted => status == NegotiationStatus.accepted || status == NegotiationStatus.enRoute || status == NegotiationStatus.onSite || status == NegotiationStatus.wip;
  bool get canCounterPoster => posterCountersUsed < 2;
  bool get canCounterWorker => workerCountersUsed < 2;

  NegotiationSession copyWith({
    NegotiationStatus? status,
    int? posterCountersUsed,
    int? workerCountersUsed,
    int? ttlSeconds,
    String? activeOfferId,
    DateTime? updatedAt,
    DateTime? lockedUntil,
  }) => NegotiationSession(
    sessionId: sessionId,
    jobId: jobId,
    posterId: posterId,
    workerId: workerId,
    status: status ?? this.status,
    posterCountersUsed: posterCountersUsed ?? this.posterCountersUsed,
    workerCountersUsed: workerCountersUsed ?? this.workerCountersUsed,
    ttlSeconds: ttlSeconds ?? this.ttlSeconds,
    activeOfferId: activeOfferId ?? this.activeOfferId,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lockedUntil: lockedUntil ?? this.lockedUntil,
  );
}

@immutable
class Offer {
  final String offerId;
  final Party maker;
  final double price;
  final int startEtaMinutes;
  final String? notes;
  final DateTime expiresAt;
  final OfferStatus status;

  const Offer({
    required this.offerId,
    required this.maker,
    required this.price,
    required this.startEtaMinutes,
    required this.expiresAt,
    required this.status,
    this.notes,
  });

  bool get isPending => status == OfferStatus.pending;
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Offer copyWith({OfferStatus? status}) => Offer(
    offerId: offerId,
    maker: maker,
    price: price,
    startEtaMinutes: startEtaMinutes,
    notes: notes,
    expiresAt: expiresAt,
    status: status ?? this.status,
  );
}
