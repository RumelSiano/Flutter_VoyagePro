import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/crud_service.dart';
import 'admin/admin_approvals_screen.dart';
import 'agency/agency_shell.dart';
import 'customer/customer_shell.dart';

/// After login, reads `users/{uid}.role` and routes to the matching shell.
/// This is the one screen that doesn't belong to any single role.
class RoleRouterScreen extends StatelessWidget {
  final User firebaseUser;

  const RoleRouterScreen({super.key, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    final crud = CrudService();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: crud.userStream(firebaseUser.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = AppUser.fromMap(firebaseUser.uid, snapshot.data!.data()!);

        switch (user.role) {
          case AppUser.roleAdmin:
            return const AdminApprovalsScreen();
          case AppUser.roleAgency:
            return AgencyShell(agencyUser: user);
          case AppUser.roleCustomer:
          default:
            return const CustomerShell();
        }
      },
    );
  }
}
