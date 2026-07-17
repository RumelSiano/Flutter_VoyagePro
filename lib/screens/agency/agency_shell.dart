import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../widgets/bottom_nav_scaffold.dart';
import 'agency_packages_screen.dart';
import 'incoming_bookings_screen.dart';
import 'agency_profile_screen.dart';

/// The Travel Agency's 3-tab bottom nav: Packages / Bookings / Profile.
class AgencyShell extends StatelessWidget {
  final AppUser agencyUser;

  const AgencyShell({super.key, required this.agencyUser});

  @override
  Widget build(BuildContext context) {
    return BottomNavScaffold(
      tabs: [
        NavTab(
          label: 'Packages',
          icon: Icons.card_travel_outlined,
          screen: AgencyPackagesScreen(agencyUser: agencyUser),
        ),
        NavTab(
          label: 'Bookings',
          icon: Icons.confirmation_number_outlined,
          screen: IncomingBookingsScreen(agencyUser: agencyUser),
        ),
        NavTab(
          label: 'Profile',
          icon: Icons.person_outline,
          screen: AgencyProfileScreen(agencyUser: agencyUser),
        ),
      ],
    );
  }
}
