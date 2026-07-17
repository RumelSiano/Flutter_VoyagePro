import 'package:flutter/material.dart';
import '../../models/package.dart';
import '../../services/crud_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/package_card.dart';
import 'package_detail_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final _crud = CrudService();
  final _searchController = TextEditingController();

  String _appliedQuery = '';
  String _selectedCategory = 'All categories';

  static const _categories = [
    'All categories',
    'City tour',
    'Beach and island',
    'Adventure',
  ];

  void _runSearch() {
    setState(() => _appliedQuery = _searchController.text.trim().toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Explore more packages', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 2),
                  const Text(
                    'Find your next adventure',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),

                  // Overrides the shared theme's 8px radius with a fully
                  // rounded (pill) border, distinct from the dropdown/button
                  // below it, to match the design.
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search packages...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => _runSearch(),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(),
                          items: _categories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedCategory = value ?? _selectedCategory);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _runSearch,
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text('Search'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: _crud.packagesByStatusStream(Package.statusApproved),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong.'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Client-side filtering — Firestore doesn't do full-text
                  // search, and this catalog is small enough that filtering
                  // the already-loaded stream is simpler than a search service.
                  final packages = snapshot.data!.docs
                      .map((doc) => Package.fromMap(doc.id, doc.data()))
                      .where((p) => p.title.toLowerCase().contains(_appliedQuery))
                      .where((p) =>
                          _selectedCategory == 'All categories' || p.category == _selectedCategory)
                      .toList();

                  if (packages.isEmpty) {
                    return const Center(child: Text('No packages found.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: packages.length,
                    itemBuilder: (context, index) {
                      final package = packages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: PackageCard(
                          package: package,
                          onView: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PackageDetailScreen(packageId: package.id!),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}