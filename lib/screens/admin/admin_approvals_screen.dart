import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/company.dart';
import '../../models/package.dart';
import '../../services/auth_service.dart';
import '../../services/crud_service.dart';

/// Single Admin screen with two tabs — Pending Agencies and Pending
/// Packages — instead of separate screens, per the trimmed scope.
class AdminApprovalsScreen extends StatefulWidget {
  const AdminApprovalsScreen({super.key});

  @override
  State<AdminApprovalsScreen> createState() => _AdminApprovalsScreenState();
}

class _AdminApprovalsScreenState extends State<AdminApprovalsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);
  final _crud = CrudService();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approvals'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => _authService.logout()),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Agencies'), Tab(text: 'Packages')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_PendingAgenciesTab(crud: _crud), _PendingPackagesTab(crud: _crud)],
      ),
    );
  }
}

class _PendingAgenciesTab extends StatelessWidget {
  final CrudService crud;

  const _PendingAgenciesTab({required this.crud});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: crud.pendingCompaniesStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final companies =
            snapshot.data!.docs.map((doc) => Company.fromMap(doc.id, doc.data())).toList();

        if (companies.isEmpty) return const Center(child: Text('No agencies waiting on approval.'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: companies.length,
          itemBuilder: (context, index) {
            final company = companies[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(company.name),
                subtitle: const Text('Pending approval'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Color(0xFF0F6E56)),
                      onPressed: () => crud.updateCompanyStatus(company.id!, Company.statusApproved),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => crud.updateCompanyStatus(company.id!, Company.statusSuspended),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PendingPackagesTab extends StatelessWidget {
  final CrudService crud;

  const _PendingPackagesTab({required this.crud});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: crud.packagesByStatusStream(Package.statusPending),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final packages =
            snapshot.data!.docs.map((doc) => Package.fromMap(doc.id, doc.data())).toList();

        if (packages.isEmpty) return const Center(child: Text('No packages waiting on approval.'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final package = packages[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(package.title),
                subtitle: Text('₱${package.pricePerPerson.toStringAsFixed(0)} · ${package.slotsTotal} slots'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Color(0xFF0F6E56)),
                      onPressed: () => crud.updatePackageStatus(package.id!, Package.statusApproved),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => crud.updatePackageStatus(package.id!, Package.statusRejected),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
