/// A row from the `companies` collection — one per registered Travel Agency.
class Company {
  static const statusPending = 'pending';
  static const statusApproved = 'approved';
  static const statusSuspended = 'suspended';

  final String? id;
  final String ownerUid;
  final String name;
  final String status;

  Company({
    this.id,
    required this.ownerUid,
    required this.name,
    this.status = statusPending,
  });

  factory Company.fromMap(String id, Map<String, dynamic> map) {
    return Company(
      id: id,
      ownerUid: map['ownerUid'] ?? '',
      name: map['name'] ?? '',
      status: map['status'] ?? statusPending,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': ownerUid,
      'name': name,
      'status': status,
    };
  }
}
