import 'package:practice/l10n/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth/login_page.dart';
import 'auth/role_home.dart';
import 'ui/app_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _failed = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    setState(() => _failed = false);
    try {
      final user = await FirebaseAuth.instance.authStateChanges().first;
      final page = (user == null ? null : await homeForUser(user.uid)) ??
          const LoginPage();
      if (mounted) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => page));
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(actions: const [LanguageButton()]),
      body: SafeArea(
        child: _failed
            ? AppStatus(
                icon: Icons.wifi_off_outlined,
                title: context.tr('Unable to connect'),
                message: context
                    .tr('Check your connection to continue to DoctorApp.'),
                onRetry: _checkAuthStatus)
            : Center(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.health_and_safety_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 24),
                      Text('DoctorApp',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(context.tr('Care that fits your life.')),
                      const SizedBox(height: 32),
                      CircularProgressIndicator(
                          semanticsLabel: context.tr('Loading your account')),
                    ]))),
      ));
}
