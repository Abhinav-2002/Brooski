// lib/features/chat/screens/chat_thread_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Negotiation core
import '../controllers/negotiation_controller.dart';
import '../models/negotiation_models.dart';

// Optional: auto-jump to Action Map after acceptance
import 'package:brooski_app/features/worker/screens/worker_dashboard_screen.dart';

class ChatThreadScreen extends StatefulWidget {
  static const routeName = '/chat/thread';

  // Core negotiation wiring
  final String sessionId;
  final String jobId;
  final String posterId;
  final String workerId;
  final bool isWorker;
  final double suggestedPrice;
  final int suggestedEta;

  // UI niceties (optional)
  final String? peerName;
  final String? avatarUrl;

  const ChatThreadScreen({
    super.key,
    required this.sessionId,
    required this.jobId,
    required this.posterId,
    required this.workerId,
    required this.isWorker,
    required this.suggestedPrice,
    required this.suggestedEta,
    this.peerName,
    this.avatarUrl,
  });

  /// Safe factory if you prefer to build from a Map (your routes can also use this)
  factory ChatThreadScreen.fromArgs(Map<String, dynamic>? args) {
    final m = args ?? const <String, dynamic>{};
    return ChatThreadScreen(
      sessionId:      (m['sessionId'] ?? 'default-session') as String,
      jobId:          (m['jobId'] ?? '') as String,
      posterId:       (m['posterId'] ?? '') as String,
      workerId:       (m['workerId'] ?? '') as String,
      isWorker:       (m['isWorker'] as bool?) ?? true,
      suggestedPrice: (m['suggestedPrice'] as num?)?.toDouble() ?? 0,
      suggestedEta:   (m['suggestedEta'] as int?) ?? 15,
      peerName:       m['peerName'] as String?,
      avatarUrl:      m['peerAvatar'] as String?,
    );
  }

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  late final NegotiationController ctrl;
  final TextEditingController _composer = TextEditingController();
  final ScrollController _scroll = ScrollController();
  StreamSubscription<NegotiationSession>? _sessionSub;

  @override
  void initState() {
    super.initState();
    ctrl = NegotiationController(widget.sessionId);
    ctrl.init(jobId: widget.jobId, posterId: widget.posterId, workerId: widget.workerId);

    // Auto-jump to Action Map when accepted
    _sessionSub = ctrl.watchSession().listen((s) {
      if (s.isAccepted && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WorkerDashboardScreen(initialIndex: 0)),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    _composer.dispose();
    _scroll.dispose();
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2ECC71);
    final safeName = widget.peerName?.trim().isNotEmpty == true ? widget.peerName!.trim() : 'Poster';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _AppBar(
        title: safeName,
        avatarUrl: widget.avatarUrl,
        // Live status chip from session
        statusBuilder: (ctx) => StreamBuilder<NegotiationSession>(
          stream: ctrl.watchSession(),
          builder: (_, snap) {
            final s = snap.data;
            if (s == null) return const SizedBox.shrink();
            final text = s.isAccepted ? 'Accepted' : 'Negotiating';
            final color = s.isAccepted ? primary : Colors.orange;
            return _StatusPill(text: text, color: color);
          },
        ),
      ),
      body: Column(
        children: [
          // ---------- Messages ----------
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: _MessageList(
                scrollController: _scroll,
                // TODO: hook your freeform messages stream here.
                // For now we display a friendly empty state.
              ),
            ),
          ),

          // ---------- Negotiation bar ----------
          StreamBuilder<NegotiationSession>(
            stream: ctrl.watchSession(),
            builder: (_, sSnap) {
              final session = sSnap.data;

              return StreamBuilder<List<Offer>>(
                stream: ctrl.watchOffers(),
                builder: (_, oSnap) {
                  final offers = oSnap.data ?? const <Offer>[];
                  final Offer? pending = offers
                      .where((o) => o.status == OfferStatus.pending)
                      .toList()
                      .reversed
                      .cast<Offer?>()
                      .firstWhere((_) => true, orElse: () => null);

                  return _NegotiationBar(
                    isWorker: widget.isWorker,
                    session: session,
                    pending: pending,
                    suggestedPrice: widget.suggestedPrice,
                    suggestedEta: widget.suggestedEta,
                    onMakeOffer: (price, eta, notes) => ctrl.makeOffer(
                      isWorker: widget.isWorker,
                      price: price,
                      etaMinutes: eta,
                      notes: notes,
                    ),
                    onAccept: (offerId) => ctrl.accept(offerId),
                    onDecline: (offerId) => ctrl.decline(offerId),
                  );
                },
              );
            },
          ),

          // ---------- Composer (pure chat) ----------
          _Composer(
            controller: _composer,
            onSend: () async {
              final text = _composer.text.trim();
              if (text.isEmpty) return;
              // TODO: hook to your chat messages send here (e.g., ctrl.sendText(text))
              // await ctrl.sendText(text);  // if implemented
              _composer.clear();
              if (_scroll.hasClients) {
                await Future.delayed(const Duration(milliseconds: 80));
                _scroll.animateTo(
                  _scroll.position.maxScrollExtent + 80,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message sending not hooked. Wire it to your chat backend.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ========================= AppBar =========================

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({
    required this.title,
    required this.avatarUrl,
    required this.statusBuilder,
  });

  final String title;
  final String? avatarUrl;
  final WidgetBuilder statusBuilder;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                ? NetworkImage(avatarUrl!)
                : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? const Icon(Icons.person, size: 18)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 2),
                statusBuilder(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: GoogleFonts.lato(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ========================= Messages =========================

class _MessageList extends StatelessWidget {
  const _MessageList({required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    // Replace with your StreamBuilder of chat messages
    // Example shape:
    // StreamBuilder<List<ChatMessage>>(
    //   stream: ctrl.watchMessages(),
    //   builder: (_, snap) { ... }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      children: const [
        _DateChip('Today'),
        _Bubble(isMe: true,  text: 'Hi! I’m nearby, can reach in 15 mins.'),
        _Bubble(isMe: false, text: 'Great. Can you do it for ₹450?'),
        _Bubble(isMe: true,  text: 'Let’s lock ₹500 with 10 mins ETA.'),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[700])),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.isMe,
    required this.text,
    this.statusIcon,
  });

  final bool isMe;
  final String text;
  final IconData? statusIcon;

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? const Color(0xFF2ECC71) : Colors.grey.shade200;
    final fg = isMe ? Colors.white : Colors.black87;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(16))
        : const BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomRight: Radius.circular(16));

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: EdgeInsets.only(
            left: isMe ? 80 : 8,
            right: isMe ? 8 : 80,
            top: 4,
            bottom: 4,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: bg, borderRadius: radius),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  text,
                  style: GoogleFonts.lato(color: fg, fontSize: 15, height: 1.35),
                ),
              ),
              if (statusIcon != null) ...[
                const SizedBox(width: 6),
                Icon(statusIcon, size: 14, color: fg.withOpacity(0.9)),
              ]
            ],
          ),
        ),
      ],
    );
  }
}

// ========================= Composer =========================

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Message',
                  hintStyle: GoogleFonts.lato(color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: radius),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 46,
              width: 46,
              child: Material(
                color: const Color(0xFF2ECC71),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: onSend,
                  borderRadius: BorderRadius.circular(14),
                  child: const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ========================= Negotiation Bar =========================

class _NegotiationBar extends StatefulWidget {
  const _NegotiationBar({
    required this.isWorker,
    required this.session,
    required this.pending,
    required this.suggestedPrice,
    required this.suggestedEta,
    required this.onMakeOffer,
    required this.onAccept,
    required this.onDecline,
  });

  final bool isWorker;
  final NegotiationSession? session;
  final Offer? pending;
  final double suggestedPrice;
  final int suggestedEta;
  final Future<void> Function(double, int, String?) onMakeOffer;
  final Future<void> Function(String) onAccept;
  final Future<void> Function(String) onDecline;

  @override
  State<_NegotiationBar> createState() => _NegotiationBarState();
}

class _NegotiationBarState extends State<_NegotiationBar> {
  late final TextEditingController _price =
      TextEditingController(text: widget.suggestedPrice.toStringAsFixed(0));
  late final TextEditingController _eta =
      TextEditingController(text: widget.suggestedEta.toString());

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2ECC71);
    final s = widget.session;
    final offer = widget.pending;

    // After accept → show minimal CTA (usually we auto-navigate; this is a fallback)
    if (s?.isAccepted == true) {
      return _CardShell(
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.navigation_rounded),
          label: const Text('Open Navigation'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
    }

    // Pending offer: accept / counter / decline
    if (offer != null && offer.isPending) {
      return _CardShell(
        child: _PendingOfferBar(
          offer: offer,
          onAccept: () => widget.onAccept(offer.offerId),
          onCounter: () => _showCounterSheet(context),
          onDecline: () => widget.onDecline(offer.offerId),
        ),
      );
    }

    // No pending: quick composer
    return _CardShell(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Price (₹)',
                  child: TextField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g., 500'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LabeledField(
                  label: 'ETA (min)',
                  child: TextField(
                    controller: _eta,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g., 12'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => widget.onMakeOffer(
                double.tryParse(_price.text) ?? widget.suggestedPrice,
                int.tryParse(_eta.text) ?? widget.suggestedEta,
                null,
              ),
              icon: const Icon(Icons.local_offer_outlined),
              label: const Text('Send Offer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCounterSheet(BuildContext context) async {
    const primary = Color(0xFF2ECC71);
    final price = TextEditingController(text: _price.text);
    final eta = TextEditingController(text: _eta.text);
    final notes = TextEditingController();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Counter Offer', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 12),
            TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (₹)')),
            const SizedBox(height: 8),
            TextField(controller: eta, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ETA (min)')),
            const SizedBox(height: 8),
            TextField(controller: notes, decoration: const InputDecoration(labelText: 'Notes (optional)')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel'))),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
                    child: const Text('Send Counter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      await widget.onMakeOffer(
        double.tryParse(price.text) ?? double.tryParse(_price.text) ?? 0,
        int.tryParse(eta.text) ?? int.tryParse(_eta.text) ?? 10,
        notes.text.trim().isEmpty ? null : notes.text.trim(),
      );
    }
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: child,
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.lato(
              color: Colors.grey[700],
              fontWeight: FontWeight.w700,
              fontSize: 12,
            )),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _PendingOfferBar extends StatelessWidget {
  const _PendingOfferBar({
    required this.offer,
    required this.onAccept,
    required this.onCounter,
    required this.onDecline,
  });

  final Offer offer;
  final VoidCallback onAccept;
  final VoidCallback onCounter;
  final VoidCallback onDecline;

  Stream<int> _countdown() {
    final end = offer.expiresAt;
    return Stream<int>.periodic(const Duration(seconds: 1), (_) {
      final left = end.difference(DateTime.now()).inSeconds;
      return left > 0 ? left : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2ECC71);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Offer: ₹${offer.price.toStringAsFixed(0)} • ETA: ${offer.startEtaMinutes}m',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
              ),
            ),
            StreamBuilder<int>(
              stream: _countdown(),
              initialData: offer.expiresAt.difference(DateTime.now()).inSeconds,
              builder: (_, snap) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${(snap.data ?? 0)}s',
                  style: GoogleFonts.lato(color: Colors.orange, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: onDecline, child: const Text('Decline'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: onCounter, child: const Text('Counter'))),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
                child: const Text('Accept'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
