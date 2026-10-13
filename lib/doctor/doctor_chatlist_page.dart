import 'package:practice/l10n/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../chat_screen.dart';
import '../ui/app_widgets.dart';
import 'model/patient.dart';

class DoctorChatlistPage extends StatefulWidget {
  const DoctorChatlistPage({super.key});
  @override
  State<DoctorChatlistPage> createState() => _DoctorChatlistPageState();
}

class _DoctorChatlistPageState extends State<DoctorChatlistPage> {
  List<Patient> _partners = [];
  bool _loading = true;
  bool _failed = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw StateError('Not signed in');
      final database = FirebaseDatabase.instance;
      final chats = await database.ref('ChatList').child(uid).get();
      final partners = <Patient>[];
      for (final chat in chats.children) {
        final profile = await database.ref('Patients').child(chat.key!).get();
        if (profile.value is Map) {
          partners.add(
              Patient.fromMap(Map<String, dynamic>.from(profile.value as Map)));
        }
      }
      if (mounted) setState(() => _partners = partners);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.tr('Messages')), actions: [
          const LanguageButton(),
          IconButton(
              tooltip: context.tr('Refresh conversations'),
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh)),
        ]),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _failed
                ? AppStatus(
                    icon: Icons.wifi_off_outlined,
                    title: context.tr('Unable to load messages'),
                    message: context.tr('Check your connection and try again.'),
                    onRetry: _load)
                : _partners.isEmpty
                    ? AppStatus(
                        icon: Icons.chat_bubble_outline,
                        title: context.tr('No conversations yet'),
                        message: context.tr(
                            'Messages from your patients will appear here.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: _partners.length,
                        itemBuilder: (context, i) {
                          final partner = _partners[i];
                          return Card(
                              child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            leading: const CircleAvatar(
                                child: Icon(Icons.person_outline)),
                            title: Text(
                                '${partner.firstName} ${partner.lastName}'),
                            subtitle: Text(context.tr('Open conversation')),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                          doctorId: FirebaseAuth
                                              .instance.currentUser!.uid,
                                          patientId: partner.uid,
                                          patientName:
                                              '${partner.firstName} ${partner.lastName}',
                                        ))),
                          ));
                        }),
      );
}
