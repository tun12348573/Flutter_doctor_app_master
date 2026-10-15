import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import 'login_page.dart';

/// Account tab for roles without a profile (pharmacist, admin): email and sign out.
class RoleAccountPage extends StatelessWidget {
  const RoleAccountPage({super.key, required this.icon, required this.role});
  final IconData icon;

  /// English label passed through [AppTranslation.tr].
  final String role;

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
                        CircleAvatar(radius: 28, child: Icon(icon, size: 28)),
                        const SizedBox(height: 16),
                        Text(FirebaseAuth.instance.currentUser?.email ?? '',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(context.tr(role)),
                      ]))),
        ]),
      );
}
