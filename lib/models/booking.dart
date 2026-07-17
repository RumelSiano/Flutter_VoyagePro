import 'package:cloud_firestore/cloud_firestore.dart';

/// A row from the `bookings` collection — one customer's slot reservation
/// on one package.
class Booking {
  static const statusPending = 'pending';
  static const statusConfirmed = 'confirmed';
  static const statusCompleted = 'completed';

  final String? id;
  final String packageId;
  final String companyId;
  final String customerUid;
  final DateTime travelDate;
  final int slots;
  final String specialRequests;
  final String status;
  final double totalPrice;
  final DateTime? createdAt;

  Booking({
    this.id,
    required this.packageId,
    required this.companyId,
    required this.customerUid,
    required this.travelDate,
    required this.slots,
    this.specialRequests = '',
    this.status = statusPending,
    required this.totalPrice,
    this.createdAt,
  });

  factory Booking.fromMap(String id, Map<String, dynamic> map) {
    return Booking(
      id: id,
      packageId: map['packageId'] ?? '',
      companyId: map['companyId'] ?? '',
      customerUid: map['customerUid'] ?? '',
      travelDate: (map['travelDate'] as Timestamp).toDate(),
      slots: (map['slots'] as num?)?.toInt() ?? 1,
      specialRequests: map['specialRequests'] ?? '',
      status: map['status'] ?? statusPending,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'packageId': packageId,
      'companyId': companyId,
      'customerUid': customerUid,
      'travelDate': Timestamp.fromDate(travelDate),
      'slots': slots,
      'specialRequests': specialRequests,
      'status': status,
      'totalPrice': totalPrice,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
