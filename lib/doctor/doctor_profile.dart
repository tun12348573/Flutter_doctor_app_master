import 'package:practice/l10n/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import '../ui/app_widgets.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});
  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  late Future<DataSnapshot> _profile;
  @override
  void initState() {
    super.initState();
    _profile = _load();
  }

  Future<DataSnapshot> _load() => FirebaseDatabase.instance
      .ref('Doctors')
      .child(FirebaseAuth.instance.currentUser!.uid)
      .get();

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
    } catch (_) {
      if (mounted) {
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
              onPressed: _logout,
              icon: const Icon(Icons.logout)),
        ]),
        body: FutureBuilder<DataSnapshot>(
            future: _profile,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return AppStatus(
                    icon: Icons.wifi_off_outlined,
                    title: context.tr('Unable to load profile'),
                    message: context.tr('Please check your connection.'),
                    onRetry: () => setState(() => _profile = _load()));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final profile = snapshot.data!.value as Map? ?? {};
              return ListView(padding: const EdgeInsets.all(24), children: [
                Card(
                    child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CircleAvatar(
                                  radius: 36,
                                  child: Icon(Icons.person_outline, size: 36)),
                              const SizedBox(height: 20),
                              Text(
                                  '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium),
                              const SizedBox(height: 8),
                              Text(
                                  context.tr(profile['category']?.toString() ??
                                      'Doctor'),
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 12),
                              profile['verified'] == true
                                  ? StatusPill(
                                      label: context.tr('Verified'),
                                      tone: StatusTone.done)
                                  : StatusPill(
                                      label: context.tr(
                                          'Awaiting verification: patients cannot find you yet'),
                                      tone: StatusTone.pending),
                              const Divider(height: 32),
                              Text(context.tr('Email: {value}', {
                                'value': profile['email']?.toString() ?? ''
                              })),
                              const SizedBox(height: 16),
                              Text(context.tr('Phone: {value}', {
                                'value':
                                    profile['phoneNumber']?.toString() ?? ''
                              })),
                              const SizedBox(height: 16),
                              Text(context.tr('City: {value}', {
                                'value': profile['city']?.toString() ?? ''
                              })),
                              const SizedBox(height: 16),
                              Text(context.tr('Qualification: {value}', {
                                'value':
                                    profile['qualification']?.toString() ?? ''
                              })),
                              const SizedBox(height: 16),
                              Text(context.tr('Experience: {years} years', {
                                'years':
                                    profile['yearsOfExperience']?.toString() ??
                                        '0'
                              })),
                            ]))),
              ]);
            }),
      );
}
