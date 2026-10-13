import 'package:practice/l10n/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../chat_screen.dart';
import '../ui/app_widgets.dart';
import 'model/doctor.dart';
import 'widget/doctor_card.dart';

class DoctorDetailPage extends StatefulWidget {
  final Doctor doctor;
  const DoctorDetailPage({super.key, required this.doctor});
  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  final _description = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final value = await showDatePicker(
        context: context,
        initialDate: _date ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (value != null && mounted) setState(() => _date = value);
  }

  Future<void> _selectTime() async {
    final value = await showTimePicker(
        context: context, initialTime: _time ?? TimeOfDay.now());
    if (value != null && mounted) setState(() => _time = value);
  }

  Future<void> _open(Uri uri) async {
    try {
      if (!await launchUrl(uri)) throw StateError('Unavailable');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(context.tr('Unable to open this link on your device.'))));
      }
    }
  }

  Future<void> _book() async {
    if (_saving) return;
    final valid = _formKey.currentState!.validate();
    if (_date == null || _time == null) {
      setState(() => _error = 'Choose both a date and a time.');
      return;
    }
    if (!valid) return;
    final date = DateFormat('MM/dd/yyyy').format(_date!);
    final time = _time!.format(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final request = FirebaseDatabase.instance.ref('Requests').push();
      await request.set({
        'date': date,
        'time': time,
        'description': _description.text.trim(),
        'id': request.key,
        'receiver': widget.doctor.uid,
        'sender': uid,
        'status': 'pending',
      });
      if (!mounted) return;
      setState(() {
        _date = null;
        _time = null;
        _description.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context
              .tr('Appointment requested. Check My account for updates.'))));
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Unable to request this appointment. Your details are kept; try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    final hasLocation = doctor.latitude != 0 || doctor.longitude != 0;
    return Scaffold(
      appBar: AppBar(
          title: Text(context.tr('Doctor profile')),
          actions: const [LanguageButton()]),
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ContentWidth(
            maxWidth: 880,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DoctorCard(doctor: doctor),
                  Card(
                      child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(context.tr('About your doctor'),
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 12),
                                Text(context.tr('Qualification: {value}',
                                    {'value': doctor.qualification})),
                                const SizedBox(height: 8),
                                Text(context.tr('Phone: {value}',
                                    {'value': doctor.phoneNumber})),
                                const SizedBox(height: 20),
                                Wrap(spacing: 12, runSpacing: 12, children: [
                                  OutlinedButton.icon(
                                      onPressed: () => Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (_) => ChatScreen(
                                                  doctorId: doctor.uid,
                                                  doctorName:
                                                      '${doctor.firstName} ${doctor.lastName}',
                                                  patientId: FirebaseAuth
                                                      .instance
                                                      .currentUser!
                                                      .uid))),
                                      icon:
                                          const Icon(Icons.chat_bubble_outline),
                                      label: Text(context.tr('Message'))),
                                  OutlinedButton.icon(
                                      onPressed: doctor.phoneNumber.isEmpty
                                          ? null
                                          : () => _open(Uri(
                                              scheme: 'tel',
                                              path: doctor.phoneNumber)),
                                      icon: const Icon(Icons.call_outlined),
                                      label: Text(context.tr('Call'))),
                                  OutlinedButton.icon(
                                      onPressed: hasLocation
                                          ? () => _open(Uri.https(
                                                  'www.google.com',
                                                  '/maps/search/', {
                                                'api': '1',
                                                'query':
                                                    '${doctor.latitude},${doctor.longitude}'
                                              }))
                                          : null,
                                      icon: const Icon(
                                          Icons.location_on_outlined),
                                      label: Text(context.tr('Directions'))),
                                ]),
                                if (!hasLocation)
                                  Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(context.tr(
                                          'This doctor has not shared a location.'))),
                              ]))),
                  const SizedBox(height: 16),
                  Card(
                      child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(context.tr('Request an appointment'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge),
                                    const SizedBox(height: 8),
                                    Text(context.tr(
                                        'Choose a preferred time. Your doctor will confirm the request.')),
                                    const SizedBox(height: 24),
                                    Wrap(
                                        spacing: 12,
                                        runSpacing: 12,
                                        children: [
                                          OutlinedButton.icon(
                                              onPressed:
                                                  _saving ? null : _selectDate,
                                              icon: const Icon(Icons
                                                  .calendar_today_outlined),
                                              label: Text(_date == null
                                                  ? context.tr('Choose date')
                                                  : DateFormat.yMMMd(
                                                          Localizations
                                                                  .localeOf(
                                                                      context)
                                                              .languageCode)
                                                      .format(_date!))),
                                          OutlinedButton.icon(
                                              onPressed:
                                                  _saving ? null : _selectTime,
                                              icon: const Icon(Icons.schedule),
                                              label: Text(_time == null
                                                  ? context.tr('Choose time')
                                                  : _time!.format(context))),
                                        ]),
                                    const SizedBox(height: 20),
                                    TextFormField(
                                        controller: _description,
                                        enabled: !_saving,
                                        minLines: 3,
                                        maxLines: 6,
                                        decoration: InputDecoration(
                                            labelText: context
                                                .tr('Reason for your visit'),
                                            alignLabelWithHint: true),
                                        validator: (value) => value == null ||
                                                value.trim().isEmpty
                                            ? context.tr(
                                                'Tell the doctor how they can help.')
                                            : null),
                                    if (_error != null)
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16),
                                          child: Semantics(
                                              liveRegion: true,
                                              child: Text(context.tr(_error!),
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error)))),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                        onPressed: _saving ? null : _book,
                                        child: Text(_saving
                                            ? context.tr('Sending request...')
                                            : context
                                                .tr('Request appointment'))),
                                  ])))),
                ])),
      )),
    );
  }
}
