import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/crud_service.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final crud = CrudService();
    final authService = AuthService();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), automaticallyImplyLeading: false),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: crud.userStream(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = AppUser.fromMap(uid, snapshot.data!.data()!);
          final initials = user.name.isNotEmpty
              ? user.name.trim().split(' ').map((s) => s[0]).take(2).join().toUpperCase()
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
                    Text(user.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                    Text(user.email, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: navigate to an edit-profile form calling
                  // crud.updateUserProfile(uid, {...}).
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
