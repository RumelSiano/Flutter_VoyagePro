import 'package:flutter/material.dart';

/// Small colored pill for any status string (package/booking/company/
/// payment status). One widget covers every status badge in the app.
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  ({Color bg, Color fg, String label}) _styleFor(String status) {
    switch (status) {
      case 'approved':
      case 'confirmed':
      case 'completed':
      case 'verified':
        return (bg: const Color(0xFFE8F5EE), fg: const Color(0xFF0F6E56), label: _capitalize(status));
      case 'pending':
      case 'submitted':
        return (bg: const Color(0xFFFCF2DD), fg: const Color(0xFF9A6B0A), label: _capitalize(status));
      case 'rejected':
      case 'declined':
      case 'suspended':
        return (bg: const Color(0xFFFBE9E9), fg: const Color(0xFFB3261E), label: _capitalize(status));
      default:
        return (bg: Colors.grey.shade200, fg: Colors.grey.shade700, label: _capitalize(status));
    }
  }

  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        style.label,
        style: TextStyle(color: style.fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
