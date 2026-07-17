import 'package:cloud_firestore/cloud_firestore.dart';

/// A row from the `payments` collection — a customer's submitted proof of
/// payment for one booking.
class Payment {
  static const statusSubmitted = 'submitted';
  static const statusVerified = 'verified';
  static const statusDeclined = 'declined';

  final String? id;
  final String bookingId;
  final String receiptImageUrl;
  final double amount;
  final String? verifiedBy;
  final String status;

  Payment({
    this.id,
    required this.bookingId,
    required this.receiptImageUrl,
    required this.amount,
    this.verifiedBy,
    this.status = statusSubmitted,
  });

  factory Payment.fromMap(String id, Map<String, dynamic> map) {
    return Payment(
      id: id,
      bookingId: map['bookingId'] ?? '',
      receiptImageUrl: map['receiptImageUrl'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      verifiedBy: map['verifiedBy'],
      status: map['status'] ?? statusSubmitted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'receiptImageUrl': receiptImageUrl,
      'amount': amount,
      'verifiedBy': verifiedBy,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
