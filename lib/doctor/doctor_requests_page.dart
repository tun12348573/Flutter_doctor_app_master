import 'package:practice/l10n/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../ui/app_widgets.dart';
import '../ui/booking_card.dart';
import 'model/booking.dart';

class DoctorRequestsPage extends StatefulWidget {
  const DoctorRequestsPage({super.key});
  @override
  State<DoctorRequestsPage> createState() => _DoctorRequestsPageState();
}

class _DoctorRequestsPageState extends State<DoctorRequestsPage> {
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
          .orderByChild('receiver')
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

  Future<void> _showStatusDialog(Booking booking) async {
    String selected = booking.status;
    bool saving = false;
    String? error;
    final updated = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
            builder: (context, update) => PopScope(
                canPop: !saving,
                child: AlertDialog(
                  title: Text(context.tr('Review appointment')),
                  content: SingleChildScrollView(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(booking.description),
                        const SizedBox(height: 16),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          for (final status in [
                            'Accepted',
                            'Rejected',
                            'Completed'
                          ])
                            ChoiceChip(
                                label: Text(context.tr(status)),
                                selected: selected == status,
                                onSelected: saving
                                    ? null
                                    : (_) => update(() => selected = status)),
                        ]),
                        if (error != null)
                          Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(context.tr(error!))),
                      ])),
                  actions: [
                    TextButton(
                        onPressed:
                            saving ? null : () => Navigator.pop(context, false),
                        child: Text(context.tr('Cancel'))),
                    ElevatedButton(
                        onPressed: saving || selected == booking.status
                            ? null
                            : () async {
                                update(() {
                                  saving = true;
                                  error = null;
                                });
                                try {
                                  await FirebaseDatabase.instance
                                      .ref('Requests')
                                      .child(booking.id)
                                      .update({'status': selected});
                                  if (context.mounted) {
                                    Navigator.pop(context, true);
                                  }
                                } catch (_) {
                                  if (context.mounted) {
                                    update(() {
                                      saving = false;
                                      error =
                                          'Unable to save. Please try again.';
                                    });
                                  }
                                }
                              },
                        child: Text(saving
                            ? context.tr('Saving...')
                            : context.tr('Save status'))),
                  ],
                ))));
    if (updated == true && mounted) _fetchBookings();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.tr('Appointments')), actions: [
          const LanguageButton(),
          IconButton(
              tooltip: context.tr('Refresh appointments'),
              onPressed: _isLoading ? null : _fetchBookings,
              icon: const Icon(Icons.refresh)),
        ]),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _failed
                ? AppStatus(
                    icon: Icons.wifi_off_outlined,
                    title: context.tr('Unable to load appointments'),
                    message: context.tr('Check your connection and try again.'),
                    onRetry: _fetchBookings)
                : _bookings.isEmpty
                    ? AppStatus(
                        icon: Icons.calendar_today_outlined,
                        title: context.tr('Your schedule is clear'),
                        message: context
                            .tr('New appointment requests will appear here.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: _bookings.length,
                        itemBuilder: (context, i) => BookingCard(
                            booking: _bookings[i],
                            onTap: () => _showStatusDialog(_bookings[i]))),
      );
}
