import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../models/package.dart';
import '../../services/crud_service.dart';
import '../../widgets/status_badge.dart';
import 'payment_submission_screen.dart';
import '../../screens/customer/leave_review_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final _crud = CrudService();
  String _activeTab = Booking.statusPending;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('My bookings'), automaticallyImplyLeading: false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _tabButton('Pending', Booking.statusPending),
                _tabButton('Confirmed', Booking.statusConfirmed),
                _tabButton('Completed', Booking.statusCompleted),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _crud.customerBookingsStream(uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final bookings = snapshot.data!.docs
                    .map((doc) => Booking.fromMap(doc.id, doc.data()))
                    .where((b) => b.status == _activeTab)
                    .toList();

                if (bookings.isEmpty) {
                  return const Center(child: Text('No bookings here yet.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) => _BookingCard(booking: bookings[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String label, String status) {
    final selected = _activeTab == status;
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () => setState(() => _activeTab = status),
        child: Container(
          padding: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? const Color(0xFF0F6E56) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? const Color(0xFF0F6E56) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

/// Checks the linked `payments` doc directly (rather than a mirrored field
/// on the booking) to decide whether to show "Submit Payment" or "Under
/// review".
class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final crud = CrudService();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking docs only store packageId, not the photo itself, so
            // the thumbnail is loaded from the linked package doc.
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: crud.packageStream(booking.packageId),
              builder: (context, snapshot) {
                String imageUrl = '';
                if (snapshot.hasData && snapshot.data!.exists) {
                  imageUrl = Package.fromMap(snapshot.data!.id, snapshot.data!.data()!).imageUrl;
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: const Color(0xFFF4F5F4),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.photo, color: Colors.grey),
                          )
                        : const Icon(Icons.photo, color: Colors.grey),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${booking.slots} slot(s) · ${booking.travelDate.month}/${booking.travelDate.day}/${booking.travelDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('₱${booking.totalPrice.toStringAsFixed(0)} total',
                      style: const TextStyle(color: Color(0xFF0F6E56), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),

                  if (booking.status == Booking.statusPending)
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: crud.paymentsForBookingStream(booking.id!),
                      builder: (context, snapshot) {
                        final hasPayment = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

                        if (hasPayment) {
                          return const StatusBadge(status: 'submitted');
                        }

                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentSubmissionScreen(
                                    bookingId: booking.id!,
                                    amount: booking.totalPrice,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.upload, size: 16),
                            label: const Text('Submit payment'),
                          ),
                        );
                      },
                    )
                  else if (booking.status == Booking.statusCompleted)
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: crud.packageReviewsStream(booking.packageId),
                      builder: (context, snapshot) {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        final alreadyReviewed = snapshot.hasData &&
                            snapshot.data!.docs.any((doc) => doc.data()['customerUid'] == uid);

                        if (alreadyReviewed) {
                          return const StatusBadge(status: 'completed');
                        }

                        return SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LeaveReviewScreen(packageId: booking.packageId),
                                ),
                              );
                            },
                            icon: const Icon(Icons.star_outline, size: 16),
                            label: const Text('Leave a review'),
                          ),
                        );
                      },
                    )
                  else
                    StatusBadge(status: booking.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
