import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../doctor/model/doctor.dart';
import '../l10n/app_strings.dart';
import '../ui/app_widgets.dart';

/// Doctors from `Doctors`, unverified first, then by name. Malformed profiles are
/// skipped so one bad record cannot break the page.
List<Doctor> doctorsForReview(Map<Object?, Object?> raw) {
  final doctors = <Doctor>[];
  for (final entry in raw.entries) {
    try {
      doctors.add(Doctor.fromMap(entry.value as Map, entry.key as String));
    } catch (_) {}
  }
  String name(Doctor d) => '${d.firstName} ${d.lastName}'.toLowerCase();
  return doctors
    ..sort((a, b) => a.verified == b.verified
        ? name(a).compareTo(name(b))
        : (a.verified ? 1 : -1));
}

class DoctorVerificationPage extends StatefulWidget {
  const DoctorVerificationPage({super.key});
  @override
  State<DoctorVerificationPage> createState() => _DoctorVerificationPageState();
}

class _DoctorVerificationPageState extends State<DoctorVerificationPage> {
  List<Doctor> _doctors = [];
  bool _isLoading = true;
  bool _failed = false;
  String? _saving;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _failed = false;
    });
    try {
      final snapshot = await FirebaseDatabase.instance.ref('Doctors').get();
      final raw = snapshot.value;
      if (mounted) {
        setState(() => _doctors = raw is Map ? doctorsForReview(raw) : []);
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setVerified(Doctor doctor, bool verified) async {
    if (verified) {
      final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(context.tr('Verify {name}?',
                    {'name': '${doctor.firstName} ${doctor.lastName}'})),
                content: Text(context.tr(
                    'Patients will be able to find and book this doctor, and the doctor will be able to read patient profiles. Check their qualification first.')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(context.tr('Cancel'))),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(context.tr('Verify'))),
                ],
              ));
      if (ok != true || !mounted) return;
    }
    setState(() => _saving = doctor.uid);
    try {
      final ref =
          FirebaseDatabase.instance.ref('Doctors/${doctor.uid}/verified');
      await (verified ? ref.set(true) : ref.remove());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.tr('Unable to save. Please try again.'))));
      }
    }
    if (mounted) setState(() => _saving = null);
    await _fetch();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.tr('Verify doctors')), actions: [
          const LanguageButton(),
          IconButton(
              tooltip: context.tr('Refresh doctors'),
              onPressed: _isLoading ? null : _fetch,
              icon: const Icon(Icons.refresh)),
        ]),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _failed
                ? AppStatus(
                    icon: Icons.wifi_off_outlined,
                    title: context.tr('Unable to load doctors'),
                    message: context.tr('Check your connection and try again.'),
                    onRetry: _fetch)
                : _doctors.isEmpty
                    ? AppStatus(
                        icon: Icons.medical_services_outlined,
                        title: context.tr('No doctors yet'),
                        message: context.tr(
                            'Doctors who sign up will appear here for review.'))
                    : ListView(padding: const EdgeInsets.all(24), children: [
                        for (final doctor in _doctors)
                          Card(
                              child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '${doctor.firstName} ${doctor.lastName}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                        const SizedBox(height: 8),
                                        StatusPill(
                                            label: context.tr(doctor.verified
                                                ? 'Verified'
                                                : 'Awaiting verification'),
                                            tone: doctor.verified
                                                ? StatusTone.done
                                                : StatusTone.pending),
                                        const SizedBox(height: 12),
                                        Text(context.tr(doctor.category)),
                                        Text(context.tr('Email: {value}',
                                            {'value': doctor.email})),
                                        Text(context.tr(
                                            'Qualification: {value}',
                                            {'value': doctor.qualification})),
                                        Text(context.tr(
                                            'Experience: {years} years', {
                                          'years': doctor.yearsOfExperience
                                        })),
                                        const SizedBox(height: 12),
                                        Align(
                                            alignment: Alignment.centerRight,
                                            child: doctor.verified
                                                ? OutlinedButton(
                                                    onPressed: _saving != null
                                                        ? null
                                                        : () => _setVerified(
                                                            doctor, false),
                                                    child: Text(context.tr(
                                                        'Remove verification')))
                                                : FilledButton(
                                                    onPressed: _saving != null
                                                        ? null
                                                        : () => _setVerified(
                                                            doctor, true),
                                                    child: Text(
                                                        context.tr('Verify')))),
                                      ]))),
                      ]),
      );
}
