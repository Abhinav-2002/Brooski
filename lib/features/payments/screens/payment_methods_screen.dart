import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<String> _methods = ['Visa •••• 4242', 'UPI • raju@upi'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Payment Methods', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMethod,
        icon: const Icon(Icons.add),
        label: const Text('Add Method'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemBuilder: (_, i) => ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(_methods[i], style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(() => _methods.removeAt(i)),
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: _methods.length,
      ),
    );
  }

  Future<void> _addMethod() async {
    // Replace with your real flow (UPI intent / card entry)
    setState(() => _methods.add('New Method •••• 0000'));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Method added (demo).')));
    }
  }
}
