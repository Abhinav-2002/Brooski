import 'package:flutter/material.dart';

class WithdrawJobDialog extends StatefulWidget {
  final Function(String) onConfirm;
  final String jobId;

  const WithdrawJobDialog({super.key, required this.onConfirm, required this.jobId});

  @override
  State<WithdrawJobDialog> createState() => _WithdrawJobDialogState();
}

class _WithdrawJobDialogState extends State<WithdrawJobDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isConfirmEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isConfirmEnabled = _controller.text == 'WITHDRAW';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Are You Sure?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Withdrawing from an accepted job will negatively affect your profile, including your overall rating, progress towards badges, and eligibility for future rewards.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Please type WITHDRAW to confirm',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Nevermind, Keep Job'),
                ),
                ElevatedButton(
                  onPressed: _isConfirmEnabled
                      ? () {
                          widget.onConfirm(widget.jobId);
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: const Text('Confirm Withdrawal', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
