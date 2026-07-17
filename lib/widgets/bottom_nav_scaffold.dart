import 'package:flutter/material.dart';

/// One shared bottom-nav wrapper reused by both the Customer shell and the
/// Travel Agency shell — each just passes in a different list of tabs.
class NavTab {
  final String label;
  final IconData icon;
  final Widget screen;

  const NavTab({required this.label, required this.icon, required this.screen});
}

class BottomNavScaffold extends StatefulWidget {
  final List<NavTab> tabs;

  const BottomNavScaffold({super.key, required this.tabs});

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps each tab's scroll position/state alive when
      // switching tabs, instead of rebuilding the screen from scratch.
      body: IndexedStack(
        index: _index,
        children: widget.tabs.map((t) => t.screen).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: widget.tabs
            .map((t) => BottomNavigationBarItem(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }
}
