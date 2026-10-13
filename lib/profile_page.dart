import 'package:practice/l10n/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'auth/login_page.dart';
import 'doctor/model/booking.dart';
import 'ui/app_widgets.dart';
import 'ui/booking_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Booking> _bookings = [];
  bool _isLoading = true;
  bool _failed = false;
  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _failed = false;
    });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw StateError('Not signed in');
      final snapshot = await FirebaseDatabase.instance
          .ref('Requests')
          .orderByChild('sender')
          .equalTo(uid)
          .get();
      final bookings = snapshot.children
          .map(
              (s) => Booking.fromMap(Map<String, dynamic>.from(s.value as Map)))
          .toList();
      if (mounted) setState(() => _bookings = bookings);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
        body: ListView(padding: const EdgeInsets.all(24), children: [
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                            radius: 28,
                            child: Icon(Icons.person_outline, size: 28)),
                        const SizedBox(height: 16),
                        Text(
                            FirebaseAuth.instance.currentUser?.email ??
                                context.tr('Patient account'),
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(context.tr('Patient account')),
                      ]))),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
                child: Text(context.tr('Your appointments'),
                    style: Theme.of(context).textTheme.titleLarge)),
            IconButton(
                tooltip: context.tr('Refresh appointments'),
                onPressed: _isLoading ? null : _fetchBookings,
                icon: const Icon(Icons.refresh)),
          ]),
          if (_isLoading)
            const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()))
          else if (_failed)
            AppStatus(
                icon: Icons.wifi_off_outlined,
                title: context.tr('Unable to load appointments'),
                message: context.tr('Check your connection and try again.'),
                onRetry: _fetchBookings)
          else if (_bookings.isEmpty)
            AppStatus(
                icon: Icons.calendar_today_outlined,
                title: context.tr('No appointments yet'),
                message: context
                    .tr('Find a doctor and request your first appointment.'))
          else
            ..._bookings.map((booking) => BookingCard(booking: booking)),
        ]),
      );
}
