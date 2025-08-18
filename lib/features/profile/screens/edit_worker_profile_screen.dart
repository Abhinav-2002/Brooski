import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/worker_account_service.dart';

class EditWorkerProfileScreen extends StatefulWidget {
  final WorkerProfile initial;
  const EditWorkerProfileScreen({super.key, required this.initial});

  @override
  State<EditWorkerProfileScreen> createState() => _EditWorkerProfileScreenState();
}

class _EditWorkerProfileScreenState extends State<EditWorkerProfileScreen> {
  final _form = GlobalKey<FormState>();
  late String _name;
  late String _headline;

  @override
  void initState() {
    super.initState();
    _name = widget.initial.name;
    _headline = widget.initial.skills.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final svc = WorkerAccountService.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              onSaved: (v) => _name = v!.trim(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _headline,
              decoration: const InputDecoration(
                labelText: 'Skills (comma separated)',
                helperText: 'e.g., Electrician, Plumbing',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter skills' : null,
              onSaved: (v) => _headline = v!.trim(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                if (!(_form.currentState?.validate() ?? false)) return;
                _form.currentState!.save();

                await svc.updateProfile(
                  name: _name,
                  skillsCsv: _headline,
                );

                if (mounted) Navigator.pop(context, true);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
