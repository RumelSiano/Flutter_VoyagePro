import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/company.dart';
import '../../services/auth_service.dart';
import '../../services/crud_service.dart';

class AgencyProfileScreen extends StatelessWidget {
  final AppUser agencyUser;

  const AgencyProfileScreen({super.key, required this.agencyUser});

  @override
  Widget build(BuildContext context) {
    final crud = CrudService();
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), automaticallyImplyLeading: false),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: crud.companyStream(agencyUser.companyId!),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final company = Company.fromMap(snapshot.data!.id, snapshot.data!.data()!);
          final initials = company.name.isNotEmpty
              ? company.name.trim().split(' ').map((s) => s[0]).take(2).join().toUpperCase()
              : '?';

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFFE3F0EC),
                      child: Text(initials,
                          style: const TextStyle(fontSize: 20, color: Color(0xFF0F6E56), fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 10),
                    Text(company.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                    Text(agencyUser.email, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: company.status == Company.statusApproved
                            ? const Color(0xFFE8F5EE)
                            : const Color(0xFFFCF2DD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        company.status == Company.statusApproved ? 'Verified agency' : 'Pending approval',
                        style: TextStyle(
                          fontSize: 11,
                          color: company.status == Company.statusApproved
                              ? const Color(0xFF0F6E56)
                              : const Color(0xFF9A6B0A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: const Text('Edit company profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: form calling crud.updateCompanyStatus / a future
                  // updateCompany(id, data) method.
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log out', style: TextStyle(color: Colors.red)),
                onTap: () => authService.logout(),
              ),
            ],
          );
        },
      ),
    );
  }
}
