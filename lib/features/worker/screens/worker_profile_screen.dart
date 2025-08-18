import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../profile/screens/edit_worker_profile_screen.dart';
import '../../payments/screens/payment_methods_screen.dart';
import '../../services/worker_account_service.dart';

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  final _svc = WorkerAccountService.instance;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF2ECC71);
    final me = _svc.currentWorker; // mock data for now

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7FAF7),
        foregroundColor: Colors.black,
        title: Text('Profile', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 34,
                backgroundImage: NetworkImage(me.photoUrl),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(me.name,
                        style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      'Worker · ${me.skills.join(', ')}',
                      style: GoogleFonts.lato(color: Colors.grey[700], fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status Card
          _glassCard(
            children: [
              _iconRow(
                context,
                icon: Icons.verified_user_outlined,
                title: 'KYC Status',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(me.kycVerified ? 'Verified' : 'Not verified',
                        style: GoogleFonts.lato(
                          color: me.kycVerified ? Colors.black87 : Colors.orange[800],
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(width: 8),
                    Icon(
                      me.kycVerified ? Icons.check_circle : Icons.error_outline,
                      color: me.kycVerified ? green : Colors.orange,
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),
              _iconRow(
                context,
                icon: Icons.star_border_rounded,
                title: 'Rating',
                trailing: Text(
                  '${me.rating.toStringAsFixed(1)} (${me.reviews} reviews)',
                  style: GoogleFonts.lato(fontWeight: FontWeight.w700),
                ),
              ),
              const Divider(height: 20),
              _iconRow(
                context,
                icon: Icons.account_balance_wallet_outlined,
                title: 'Wallet Balance',
                trailing: Text('₹${me.wallet.toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700, color: Colors.black)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Actions Card
          _glassCard(
            children: [
              _listTile(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditWorkerProfileScreen(initial: me),
                    ),
                  );
                  if (updated == true && mounted) {
                    setState(() {}); // refresh UI
                    _toast(context, 'Profile updated.');
                  }
                },
              ),
              const Divider(height: 0),
              _listTile(
                icon: Icons.credit_card_outlined,
                title: 'Payment Methods',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
                  );
                },
              ),
              const Divider(height: 0),
              _listTile(
                icon: Icons.logout, title: 'Logout', isDestructive: true,
                onTap: () async {
                  final ok = await _confirm(context, 'Logout from Brooski?');
                  if (ok && context.mounted) {
                    await _svc.signOut();
                    _toast(context, 'Logged out.');
                    // TODO: push to auth/choose role if needed
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- small UI helpers ----

  Widget _glassCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _iconRow(BuildContext context,
      {required IconData icon, required String title, required Widget trailing}) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title,
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600, color: Colors.black87)),
        ),
        trailing,
      ],
    );
  }

  Widget _listTile({
    required IconData icon,
    required String title,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      leading: Icon(icon, color: isDestructive ? Colors.red[700] : Colors.black87),
      title: Text(title,
          style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: isDestructive ? Colors.red[700] : Colors.black87)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<bool> _confirm(BuildContext context, String msg) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('OK')),
        ],
      ),
    );
    return res ?? false;
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
