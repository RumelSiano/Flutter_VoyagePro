import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/package.dart';
import '../../services/crud_service.dart';
import '../../widgets/status_badge.dart';
import 'post_package_screen.dart';

class AgencyPackagesScreen extends StatelessWidget {
  final AppUser agencyUser;

  const AgencyPackagesScreen({super.key, required this.agencyUser});

  @override
  Widget build(BuildContext context) {
    final crud = CrudService();
    final companyId = agencyUser.companyId!;

    return Scaffold(
      appBar: AppBar(title: const Text('My packages'), automaticallyImplyLeading: false),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: crud.companyPackagesStream(companyId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final packages =
              snapshot.data!.docs.map((doc) => Package.fromMap(doc.id, doc.data())).toList();

          if (packages.isEmpty) {
            return const Center(child: Text('No packages posted yet. Tap + to add one.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final package = packages[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostPackageScreen(
                          companyId: companyId,
                          existingPackage: package,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F5F4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.photo, color: Colors.grey),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(package.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                StatusBadge(status: package.status),
                              ],
                            ),
                            Text(
                              '₱${package.pricePerPerson.toStringAsFixed(0)} · ${package.slotsLeft} slots left',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PostPackageScreen(companyId: companyId)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
