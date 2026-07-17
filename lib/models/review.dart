import 'package:cloud_firestore/cloud_firestore.dart';

/// A row from the `reviews` collection — a customer's rating/comment left
/// on a package after a completed trip.
class Review {
  final String? id;
  final String packageId;
  final String customerUid;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  Review({
    this.id,
    required this.packageId,
    required this.customerUid,
    required this.rating,
    this.comment = '',
    this.createdAt,
  });

  factory Review.fromMap(String id, Map<String, dynamic> map) {
    return Review(
      id: id,
      packageId: map['packageId'] ?? '',
      customerUid: map['customerUid'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'packageId': packageId,
      'customerUid': customerUid,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
