import 'package:flutter/material.dart';
import 'app_widgets.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.pages, required this.destinations});
  final List<Widget> pages;
  final List<NavigationDestination> destinations;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selected = 0;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        return Scaffold(
          body: SafeArea(
              child: Row(children: [
            if (wide)
              NavigationRail(
                  selectedIndex: _selected,
                  onDestinationSelected: (i) => setState(() => _selected = i),
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Icon(Icons.health_and_safety_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 36)),
                  destinations: widget.destinations
                      .map((d) => NavigationRailDestination(
                          icon: d.icon,
                          selectedIcon: d.selectedIcon,
                          label: Text(d.label)))
                      .toList()),
            if (wide) const VerticalDivider(width: 1),
            Expanded(child: ContentWidth(child: widget.pages[_selected])),
          ])),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _selected,
                  onDestinationSelected: (i) => setState(() => _selected = i),
                  destinations: widget.destinations),
        );
      });
}
