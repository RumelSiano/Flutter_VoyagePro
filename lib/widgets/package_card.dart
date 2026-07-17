import 'package:flutter/material.dart';
import '../models/package.dart';

/// The homepage catalog card — image, category, title, rating, duration,
/// slots left, price, and a View button. Matches the existing VoyagePro
/// web app's package card layout.
class PackageCard extends StatelessWidget {
  final Package package;
  final VoidCallback onView;

  const PackageCard({super.key, required this.package, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: package.imageUrl.isNotEmpty
                ? Image.network(package.imageUrl, fit: BoxFit.cover)
                : Container(
                    color: const Color(0xFFF4F5F4),
                    child: const Icon(Icons.photo, color: Colors.grey),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(
                  label: Text(package.category, style: const TextStyle(fontSize: 11)),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(height: 6),
                Text(package.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                if (package.companyName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.storefront_outlined, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(package.companyName,
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    Text(' ${package.rating.toStringAsFixed(1)} (${package.reviewCount})',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 13, color: Colors.grey),
                    Text(' ${package.durationDays}D / ${package.durationNights}N   ',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey)
                          ),
                    const Icon(Icons.people, size: 13, color: Colors.grey),
                    Text(' ${package.slotsLeft} slots left',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₱${package.pricePerPerson.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F6E56))),
                        const Text('per person', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: onView,
                      icon: const Icon(Icons.arrow_forward, size: 15),
                      label: const Text('View'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}