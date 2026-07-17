/// A row from the `packages` collection — one tour package posted by a
/// Travel Agency.
class Package {
  static const statusPending = 'pending';
  static const statusApproved = 'approved';
  static const statusRejected = 'rejected';

  final String? id;
  final String companyId;
  // Denormalized from companies/{companyId}.name at posting time, so
  // package cards/lists can show "posted by X" without a nested query
  // per item. If an agency renames itself, existing packages keep the
  // old name until re-posted — acceptable for this scope.
  final String companyName;
  final String title;
  final String category;
  final String overview;
  final String imageUrl;
  final double pricePerPerson;
  final int durationDays;
  final int durationNights;
  final int slotsTotal;
  final int slotsLeft;
  final String status;
  final double rating;
  final int reviewCount;

  Package({
    this.id,
    required this.companyId,
    required this.companyName,
    required this.title,
    required this.category,
    required this.overview,
    required this.imageUrl,
    required this.pricePerPerson,
    required this.durationDays,
    required this.durationNights,
    required this.slotsTotal,
    required this.slotsLeft,
    this.status = statusPending,
    this.rating = 0,
    this.reviewCount = 0,
  });

  factory Package.fromMap(String id, Map<String, dynamic> map) {
    return Package(
      id: id,
      companyId: map['companyId'] ?? '',
      companyName: map['companyName'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      overview: map['overview'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      pricePerPerson: (map['pricePerPerson'] as num?)?.toDouble() ?? 0,
      durationDays: (map['durationDays'] as num?)?.toInt() ?? 0,
      durationNights: (map['durationNights'] as num?)?.toInt() ?? 0,
      slotsTotal: (map['slotsTotal'] as num?)?.toInt() ?? 0,
      slotsLeft: (map['slotsLeft'] as num?)?.toInt() ?? 0,
      status: map['status'] ?? statusPending,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'companyName': companyName,
      'title': title,
      'category': category,
      'overview': overview,
      'imageUrl': imageUrl,
      'pricePerPerson': pricePerPerson,
      'durationDays': durationDays,
      'durationNights': durationNights,
      'slotsTotal': slotsTotal,
      'slotsLeft': slotsLeft,
      'status': status,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}