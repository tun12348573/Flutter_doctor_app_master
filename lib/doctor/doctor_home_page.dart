import 'package:practice/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../ui/home_shell.dart';
import 'doctor_chatlist_page.dart';
import 'doctor_profile.dart';
import 'doctor_requests_page.dart';

class DoctorHomePage extends StatelessWidget {
  const DoctorHomePage({super.key});
  @override
  Widget build(BuildContext context) => HomeShell(pages: const [
        DoctorRequestsPage(),
        DoctorChatlistPage(),
        DoctorProfile()
      ], destinations: [
        NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            label: context.tr('Appointments')),
        NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            label: context.tr('Messages')),
        NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: context.tr('My account')),
      ]);
}
