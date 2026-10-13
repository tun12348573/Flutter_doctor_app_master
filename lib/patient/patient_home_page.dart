import 'package:practice/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../doctor/doctor_list_page.dart';
import '../profile_page.dart';
import '../ui/home_shell.dart';
import 'chat_list_page.dart';
import '../ai/ai_chat_page.dart';
import '../ai/ai_chat_session.dart';
import '../pharmacy/pharmacy_page.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});
  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  final _ai = AiChatSession();
  @override
  void dispose() {
    _ai.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HomeShell(pages: [
        const DoctorListPage(),
        PharmacyPage(ai: _ai),
        const ChatListPage(),
        AiChatPage(session: _ai),
        const ProfilePage()
      ], destinations: [
        NavigationDestination(
            icon: const Icon(Icons.search), label: context.tr('Find care')),
        NavigationDestination(
            icon: const Icon(Icons.local_pharmacy_outlined),
            label: context.tr('Pharmacy')),
        NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            label: context.tr('Messages')),
        NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            label: context.tr('AI assistant')),
        NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: context.tr('My account')),
      ]);
}
