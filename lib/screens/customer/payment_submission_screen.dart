import 'package:flutter/material.dart';
import '../../models/payment.dart';
import '../../services/crud_service.dart';
import '../../widgets/image_upload_field.dart';

class PaymentSubmissionScreen extends StatefulWidget {
  final String bookingId;
  final double amount;

  const PaymentSubmissionScreen({super.key, required this.bookingId, required this.amount});

  @override
  State<PaymentSubmissionScreen> createState() => _PaymentSubmissionScreenState();
}

class _PaymentSubmissionScreenState extends State<PaymentSubmissionScreen> {
  final _crud = CrudService();
  String? _receiptUrl;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_receiptUrl == null) return;
    setState(() => _isSubmitting = true);
    try {
      await _crud.submitPayment(
        Payment(
          bookingId: widget.bookingId,
          receiptImageUrl: _receiptUrl!,
          amount: widget.amount,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Payment submitted for review.')));
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount due: ₱${widget.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            const Text('Upload a photo of your bank transfer or deposit receipt.',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            ImageUploadField(
              folder: 'receipts',
              onUploaded: (url) => setState(() => _receiptUrl = url),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_receiptUrl == null || _isSubmitting) ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit for review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
