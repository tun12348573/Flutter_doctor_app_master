import 'package:flutter/material.dart';
import '../auth/account_page.dart';
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
        RoleAccountPage(
            icon: Icons.local_pharmacy_outlined, role: 'Pharmacist account'),
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
