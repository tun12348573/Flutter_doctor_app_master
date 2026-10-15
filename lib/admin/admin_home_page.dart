import 'package:flutter/material.dart';
import '../auth/account_page.dart';
import '../l10n/app_strings.dart';
import '../ui/home_shell.dart';
import 'doctor_verification_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});
  @override
  Widget build(BuildContext context) => HomeShell(pages: const [
        DoctorVerificationPage(),
        RoleAccountPage(
            icon: Icons.admin_panel_settings_outlined,
            role: 'Administrator account'),
      ], destinations: [
        NavigationDestination(
            icon: const Icon(Icons.verified_user_outlined),
            label: context.tr('Doctors')),
        NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: context.tr('My account')),
      ]);
}
