import 'package:practice/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../doctor/doctor_list_page.dart';
import '../profile_page.dart';
import '../ui/home_shell.dart';
import 'chat_list_page.dart';

class PatientHomePage extends StatelessWidget {
  const PatientHomePage({super.key});
  @override
  Widget build(BuildContext context) => HomeShell(pages: const [
        DoctorListPage(),
        ChatListPage(),
        ProfilePage()
      ], destinations: [
        NavigationDestination(
            icon: const Icon(Icons.search), label: context.tr('Find care')),
        NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            label: context.tr('Messages')),
        NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: context.tr('My account')),
      ]);
}
