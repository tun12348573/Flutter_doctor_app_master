import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import '../l10n/app_strings.dart';
import '../ui/home_shell.dart';
import 'inventory_page.dart';
import 'pharmacist_orders_page.dart';

class PharmacistHomePage extends StatelessWidget {
  const PharmacistHomePage({super.key});
  @override
  Widget build(BuildContext context) => HomeShell(pages: const [
        PharmacistOrdersPage(),
        InventoryPage(),
        _PharmacistAccountPage(),
      ], destinations: [
        NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            label: context.tr('Orders')),
        NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            label: context.tr('Inventory')),
        NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: context.tr('My account')),
      ]);
}

class _PharmacistAccountPage extends StatelessWidget {
  const _PharmacistAccountPage();

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.tr('Unable to sign out. Try again.'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.tr('My account')), actions: [
          const LanguageButton(),
          IconButton(
              tooltip: context.tr('Sign out'),
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout)),
        ]),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                            radius: 28,
                            child: Icon(Icons.local_pharmacy_outlined, size: 28)),
                        const SizedBox(height: 16),
                        Text(FirebaseAuth.instance.currentUser?.email ?? '',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(context.tr('Pharmacist account')),
                      ]))),
        ]),
      );
}
