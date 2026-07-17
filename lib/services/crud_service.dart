import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking.dart';
import '../models/company.dart';
import '../models/package.dart';
import '../models/payment.dart';
import '../models/review.dart';

/// Thin Firestore access layer: CRUD + streams for every collection.
///
/// Screens consume the `Stream<QuerySnapshot>` getters directly via
/// `StreamBuilder` (no state-management package involved).
class CrudService {
  CrudService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _companies =>
      _db.collection('companies');
  CollectionReference<Map<String, dynamic>> get _packages =>
      _db.collection('packages');
  CollectionReference<Map<String, dynamic>> get _bookings =>
      _db.collection('bookings');
  CollectionReference<Map<String, dynamic>> get _payments =>
      _db.collection('payments');
  CollectionReference<Map<String, dynamic>> get _reviews =>
      _db.collection('reviews');

  /// Shared by every "list docs where field == value" stream below, since
  /// that's the only query shape this app actually needs.
  Stream<QuerySnapshot<Map<String, dynamic>>> _whereEquals(
    CollectionReference<Map<String, dynamic>> collection,
    String field,
    dynamic value,
  ) {
    return collection.where(field, isEqualTo: value).snapshots();
  }

  // ---------------------------------------------------------------------
  // Users
  // ---------------------------------------------------------------------

  Future<void> createUserDoc(String uid, Map<String, dynamic> data) {
    return _users.doc(uid).set(data);
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) {
    return _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream(String uid) {
    return _users.doc(uid).snapshots();
  }

  // ---------------------------------------------------------------------
  // Companies (Travel Agencies)
  // ---------------------------------------------------------------------

  Future<DocumentReference<Map<String, dynamic>>> createCompany(
    Company company,
  ) {
    return _companies.add(company.toMap());
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> companyStream(
    String companyId,
  ) {
    return _companies.doc(companyId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> pendingCompaniesStream() {
    return _whereEquals(_companies, 'status', Company.statusPending);
  }

  Future<void> updateCompanyStatus(String companyId, String status) {
    return _companies.doc(companyId).update({'status': status});
  }

  // ---------------------------------------------------------------------
  // Packages
  // ---------------------------------------------------------------------

  Future<DocumentReference<Map<String, dynamic>>> createPackage(
    Package package,
  ) {
    return _packages.add(package.toMap());
  }

  /// Editing a package always sends it back to `pending` for re-approval.
  Future<void> updatePackage(String packageId, Map<String, dynamic> data) {
    return _packages.doc(packageId).update({
      ...data,
      'status': Package.statusPending,
    });
  }

  Future<void> updatePackageStatus(String packageId, String status) {
    return _packages.doc(packageId).update({'status': status});
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> packageStream(
    String packageId,
  ) {
    return _packages.doc(packageId).snapshots();
  }

  /// [status] is `Package.statusApproved` for the customer catalog,
  /// `Package.statusPending` for the admin approval queue.
  Stream<QuerySnapshot<Map<String, dynamic>>> packagesByStatusStream(
    String status,
  ) {
    return _whereEquals(_packages, 'status', status);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> companyPackagesStream(
    String companyId,
  ) {
    return _whereEquals(_packages, 'companyId', companyId);
  }

  /// Atomically checks slot availability and decrements `slotsLeft` when
  /// creating a booking, so two customers can never overbook the same
  /// package. Kept as the one transaction in this service, since slot
  /// integrity is the core promise of the booking feature.
  Future<String> bookSlots({
    required String packageId,
    required Booking booking,
  }) {
    final packageRef = _packages.doc(packageId);
    final bookingRef = _bookings.doc();

    return _db.runTransaction<String>((transaction) async {
      final snapshot = await transaction.get(packageRef);
      final slotsLeft = (snapshot.data()?['slotsLeft'] as num?)?.toInt() ?? 0;
      if (slotsLeft < booking.slots) {
        throw StateError('Not enough slots left for this package.');
      }
      transaction.update(packageRef, {'slotsLeft': slotsLeft - booking.slots});
      transaction.set(bookingRef, booking.toMap());
      return bookingRef.id;
    });
  }

  // ---------------------------------------------------------------------
  // Bookings
  // ---------------------------------------------------------------------

  Stream<QuerySnapshot<Map<String, dynamic>>> customerBookingsStream(
    String customerUid,
  ) {
    return _whereEquals(_bookings, 'customerUid', customerUid);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> companyBookingsStream(
    String companyId,
  ) {
    return _whereEquals(_bookings, 'companyId', companyId);
  }

  Future<void> updateBookingStatus(String bookingId, String status) {
    return _bookings.doc(bookingId).update({'status': status});
  }

  // ---------------------------------------------------------------------
  // Payments
  // ---------------------------------------------------------------------

  /// Whether a booking has a payment yet is answered by querying
  /// [paymentsForBookingStream], not by a mirrored field on the booking.
  Future<void> submitPayment(Payment payment) {
    return _payments.add(payment.toMap());
  }

  Future<void> reviewPayment({
    required String paymentId,
    required String bookingId,
    required bool verified,
    required String verifiedBy,
  }) async {
    await _payments.doc(paymentId).update({
      'status': verified ? Payment.statusVerified : Payment.statusDeclined,
      'verifiedBy': verifiedBy,
    });
    if (verified) {
      await _bookings.doc(bookingId).update({
        'status': Booking.statusConfirmed,
      });
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> paymentsForBookingStream(
    String bookingId,
  ) {
    return _whereEquals(_payments, 'bookingId', bookingId);
  }

  // ---------------------------------------------------------------------
  // Reviews
  // ---------------------------------------------------------------------

  /// Package rating/reviewCount aggregation is left as a later feature
  /// rather than computed here.
  Future<void> submitReview(Review review) {
    return _reviews.add(review.toMap());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> packageReviewsStream(
    String packageId,
  ) {
    return _whereEquals(_reviews, 'packageId', packageId);
  }
}
