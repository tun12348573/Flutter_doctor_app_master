import 'package:practice/l10n/app_strings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../ui/app_widgets.dart';
import 'doctor_details_page.dart';
import 'model/doctor.dart';
import 'widget/doctor_card.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});
  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  List<Doctor> _doctors = [];
  bool _isLoading = true;
  bool _failed = false;
  String _category = 'All';

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    setState(() {
      _isLoading = true;
      _failed = false;
    });
    try {
      final snapshot = await FirebaseDatabase.instance.ref('Doctors').get();
      final doctors = snapshot.children
          .where((s) => s.child('verified').value == true)
          .map((s) => Doctor.fromMap(s.value as Map, s.key!))
          .toList();
      if (mounted) setState(() => _doctors = doctors);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctors = _doctors
        .where((d) => _category == 'All' || d.category == _category)
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Find care')), actions: [
        const LanguageButton(),
        IconButton(
            tooltip: context.tr('Refresh doctors'),
            onPressed: _isLoading ? null : _fetchDoctors,
            icon: const Icon(Icons.refresh)),
      ]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _failed
              ? AppStatus(
                  icon: Icons.wifi_off_outlined,
                  title: context.tr('Unable to load doctors'),
                  message: context.tr('Check your connection and try again.'),
                  onRetry: _fetchDoctors)
              : CustomScrollView(slivers: [
                  SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(context.tr('Find the right care for you'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium),
                              const SizedBox(height: 8),
                              Text(context.tr(
                                  'Explore specialists and request an appointment that suits you.')),
                              const SizedBox(height: 24),
                              Wrap(spacing: 8, runSpacing: 8, children: [
                                for (final category in [
                                  'All',
                                  'Dentist',
                                  'Cardiology',
                                  'Oncology',
                                  'Surgeon'
                                ])
                                  ChoiceChip(
                                      label: Text(context.tr(category)),
                                      selected: _category == category,
                                      onSelected: (_) =>
                                          setState(() => _category = category)),
                              ]),
                              const SizedBox(height: 24),
                              Text(
                                  context.tr('{count} doctors available',
                                      {'count': doctors.length.toString()}),
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                            ]),
                      )),
                  if (doctors.isEmpty)
                    SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppStatus(
                            icon: Icons.medical_services_outlined,
                            title: context.tr('No doctors here yet'),
                            message: context.tr(
                                'Try another specialty or check back later.')))
                  else
                    SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        sliver: SliverList.builder(
                            itemCount: doctors.length,
                            itemBuilder: (context, i) => DoctorCard(
                                doctor: doctors[i],
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => DoctorDetailPage(
                                            doctor: doctors[i])))))),
                ]),
    );
  }
}
