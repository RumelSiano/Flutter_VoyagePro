import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_scaffold.dart';
import 'customer_home_screen.dart';
import 'my_bookings_screen.dart';
import 'customer_profile_screen.dart';

/// The Customer's 3-tab bottom nav: Home / Bookings / Profile.
class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const BottomNavScaffold(
      tabs: [
        NavTab(label: 'Home', icon: Icons.home_outlined, screen: CustomerHomeScreen()),
        NavTab(label: 'Bookings', icon: Icons.confirmation_number_outlined, screen: MyBookingsScreen()),
        NavTab(label: 'Profile', icon: Icons.person_outline, screen: CustomerProfileScreen()),
      ],
    );
  }
}
