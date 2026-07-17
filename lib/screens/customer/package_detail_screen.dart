import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../models/package.dart';
import '../../models/review.dart';
import '../../services/crud_service.dart';
import '../../widgets/stat_card.dart';

/// Only [packageId] is passed in from the homepage card — this screen runs
/// its own StreamBuilder so it stays live-synced even if a Travel Agency
/// edits the price or slot count while the customer is looking at it.
class PackageDetailScreen extends StatelessWidget {
  final String packageId;

  const PackageDetailScreen({super.key, required this.packageId});

  @override
  Widget build(BuildContext context) {
    final crud = CrudService();

    return Scaffold(
      appBar: AppBar(title: const Text('Package Details')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: crud.packageStream(packageId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final package = Package.fromMap(snapshot.data!.id, snapshot.data!.data()!);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: package.imageUrl.isNotEmpty
                        ? Image.network(package.imageUrl, fit: BoxFit.cover)
                        : Container(color: const Color(0xFFF4F5F4), child: const Icon(Icons.photo)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(package.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                if (package.companyName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.storefront_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text('Offered by ${package.companyName}',
                          style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: crud.packageReviewsStream(packageId),
                  builder: (context, reviewSnapshot) {
                    final reviews = reviewSnapshot.data?.docs
                            .map((doc) => Review.fromMap(doc.id, doc.data()))
                            .toList() ??
                        [];
                    final avgRating = reviews.isEmpty
                        ? 0.0
                        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

                    return GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      // A fixed height per cell (mainAxisExtent) rather than an
                      // aspect ratio — aspect ratio derives height from width,
                      // and on some screen widths that math comes out a few
                      // pixels shorter than the label+value text actually needs.
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        mainAxisExtent: 80,
                      ),
                      children: [
                        StatCard(
                            label: 'Per person',
                            value: '₱${package.pricePerPerson.toStringAsFixed(0)}',
                            valueColor: const Color(0xFF0F6E56)),
                        StatCard(label: 'Duration', value: '${package.durationDays}D / ${package.durationNights}N'),
                        StatCard(label: 'Slots left', value: '${package.slotsLeft}'),
                        StatCard(label: 'Rating', value: '${avgRating.toStringAsFixed(1)} (${reviews.length})'),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(package.overview, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reviews', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: crud.packageReviewsStream(packageId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final reviews = snapshot.data!.docs
                              .map((doc) => Review.fromMap(doc.id, doc.data()))
                              .toList();

                          if (reviews.isEmpty) {
                            return const Text('No reviews yet.', style: TextStyle(color: Colors.grey));
                          }

                          return Column(
                            children: reviews.map((review) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                      stream: crud.userStream(review.customerUid),
                                      builder: (context, userSnapshot) {
                                        final name = (userSnapshot.data?.data()?['name'] as String?)
                                                ?.trim() ??
                                            '';
                                        return Text(
                                          name.isNotEmpty ? name : 'Anonymous traveler',
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Icon(
                                          i < review.rating.round() ? Icons.star : Icons.star_border,
                                          size: 16,
                                          color: Colors.orange,
                                        );
                                      }),
                                    ),
                                    if (review.comment.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(review.comment, style: const TextStyle(color: Colors.black87)),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _BookingForm(package: package),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Inline booking form — local `setState` only, since travel date / slots /
/// notes don't need to be shared with any other screen.
class _BookingForm extends StatefulWidget {
  final Package package;

  const _BookingForm({required this.package});

  @override
  State<_BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<_BookingForm> {
  final _crud = CrudService();
  final _requestsController = TextEditingController();
  DateTime? _travelDate;
  int _slots = 1;
  bool _isSubmitting = false;

  Future<void> _confirmBooking() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _travelDate == null) return;

    setState(() => _isSubmitting = true);
    try {
      await _crud.bookSlots(
        packageId: widget.package.id!,
        booking: Booking(
          packageId: widget.package.id!,
          companyId: widget.package.companyId,
          customerUid: uid,
          travelDate: _travelDate!,
          slots: _slots,
          specialRequests: _requestsController.text.trim(),
          totalPrice: widget.package.pricePerPerson * _slots,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking confirmed! Check My Bookings to submit payment.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB7DFCB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Book This Package',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F6E56))),
                Text('₱${widget.package.pricePerPerson.toStringAsFixed(0)} per person · ${widget.package.durationDays} days',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF0F6E56))),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Travel Date', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _travelDate = picked);
                  },
                  child: Text(_travelDate == null
                      ? 'Select a date'
                      : '${_travelDate!.month}/${_travelDate!.day}/${_travelDate!.year}'),
                ),
                const SizedBox(height: 14),
                Text('Slots (max ${widget.package.slotsLeft})', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    IconButton(
                      onPressed: _slots > 1 ? () => setState(() => _slots--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$_slots', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    IconButton(
                      onPressed: _slots < widget.package.slotsLeft ? () => setState(() => _slots++) : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Special Requests (optional)', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _requestsController,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: 'Dietary needs, accessibility requirements...'),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(color: Colors.grey)),
                    Text('₱${(widget.package.pricePerPerson * _slots).toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (_travelDate == null || _isSubmitting) ? null : _confirmBooking,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_outline),
                    label: const Text('Confirm Booking'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
