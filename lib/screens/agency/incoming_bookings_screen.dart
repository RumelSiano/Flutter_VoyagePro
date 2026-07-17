import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/booking.dart';
import '../../models/payment.dart';
import '../../services/crud_service.dart';
import '../../widgets/status_badge.dart';

/// Tabbed like MyBookingsScreen on the customer side — To Verify shows
/// pending bookings needing a payment decision, Confirmed and Completed
/// are read-only history.
class IncomingBookingsScreen extends StatefulWidget {
  final AppUser agencyUser;

  const IncomingBookingsScreen({super.key, required this.agencyUser});

  @override
  State<IncomingBookingsScreen> createState() => _IncomingBookingsScreenState();
}

class _IncomingBookingsScreenState extends State<IncomingBookingsScreen> {
  final _crud = CrudService();
  String _activeTab = Booking.statusPending;

  @override
  Widget build(BuildContext context) {
    final companyId = widget.agencyUser.companyId!;

    return Scaffold(
      appBar: AppBar(title: const Text('Incoming bookings'), automaticallyImplyLeading: false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _tabButton('To verify', Booking.statusPending),
                _tabButton('Confirmed', Booking.statusConfirmed),
                _tabButton('Completed', Booking.statusCompleted),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _crud.companyBookingsStream(companyId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final bookings = snapshot.data!.docs
                    .map((doc) => Booking.fromMap(doc.id, doc.data()))
                    .where((b) => b.status == _activeTab)
                    .toList();

                if (bookings.isEmpty) {
                  return Center(
                    child: Text(_activeTab == Booking.statusPending
                        ? 'No bookings waiting on you.'
                        : 'No bookings here yet.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return _activeTab == Booking.statusPending
                        ? _BookingReviewCard(booking: booking)
                        : _BookingHistoryCard(booking: booking);
                  },
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

/// The "To Verify" tab — shows a submitted receipt (if any) with
/// Confirm/Decline actions.
class _BookingReviewCard extends StatelessWidget {
  final Booking booking;

  const _BookingReviewCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final crud = CrudService();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: crud.paymentsForBookingStream(booking.id!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            if (snapshot.data!.docs.isEmpty) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${booking.slots} slot(s) · ₱${booking.totalPrice.toStringAsFixed(0)}'),
                subtitle: const Text('Awaiting receipt', style: TextStyle(color: Colors.grey)),
              );
            }

            final payment = Payment.fromMap(
              snapshot.data!.docs.first.id,
              snapshot.data!.docs.first.data(),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${booking.slots} slot(s) · ₱${booking.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (payment.receiptImageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(payment.receiptImageUrl, height: 120, fit: BoxFit.cover, width: double.infinity),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => crud.reviewPayment(
                          paymentId: payment.id!,
                          bookingId: booking.id!,
                          verified: true,
                          verifiedBy: 'agency', // replace with actual agency user name/uid
                        ),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Confirm'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => crud.reviewPayment(
                          paymentId: payment.id!,
                          bookingId: booking.id!,
                          verified: false,
                          verifiedBy: 'agency',
                        ),
                        icon: const Icon(Icons.close, size: 16, color: Colors.red),
                        label: const Text('Decline', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The "Confirmed" and "Completed" tabs — read-only history, plus a
/// "Mark as completed" action on confirmed bookings once the trip is done.
/// Without this, a booking would stay "confirmed" forever, and customers
/// would never be able to leave a review (LeaveReviewScreen only makes
/// sense once a booking is completed).
class _BookingHistoryCard extends StatelessWidget {
  final Booking booking;

  const _BookingHistoryCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final crud = CrudService();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${booking.slots} slot(s) · ${booking.travelDate.month}/${booking.travelDate.day}/${booking.travelDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                StatusBadge(status: booking.status),
              ],
            ),
            Text('₱${booking.totalPrice.toStringAsFixed(0)} total',
                style: const TextStyle(color: Color(0xFF0F6E56), fontWeight: FontWeight.w600)),
            if (booking.status == Booking.statusConfirmed) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => crud.updateBookingStatus(booking.id!, Booking.statusCompleted),
                  icon: const Icon(Icons.flag_outlined, size: 16),
                  label: const Text('Mark as completed'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
