import 'dart:async';
import 'package:flutter/material.dart';
import 'package:practice/chat_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice/auth/login_page.dart';
import 'package:practice/auth/signup_screen.dart';
import 'package:practice/ui/app_theme.dart';
import 'package:practice/ui/home_shell.dart';
import 'package:practice/doctor/model/doctor.dart';
import 'package:practice/doctor/widget/doctor_card.dart';

void main() {
  testWidgets(
      'Message composer retains failed messages and prevents duplicate sends',
      (tester) async {
    final pending = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: MessageComposer(onSend: (message) {
            calls++;
            expect(message, 'Hello doctor');
            return pending.future;
          }),
        )));
    await tester.enterText(find.byType(TextField), 'Hello doctor');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pump();
    expect(find.byTooltip('Sending message'), findsOneWidget);
    expect(
        tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
    expect(calls, 1);
    pending.completeError(StateError('offline'));
    await tester.pumpAndSettle();
    expect(find.text('Hello doctor'), findsOneWidget);
    expect(find.text('Message not sent. Please try again.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Message composer clears only after a successful send',
      (tester) async {
    final pending = Completer<void>();
    await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: MessageComposer(onSend: (_) => pending.future),
        )));
    await tester.enterText(find.byType(TextField), 'Keep until delivered');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pump();
    expect(find.text('Keep until delivered'), findsOneWidget);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('Keep until delivered'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Doctor card fits long names and cities on a small screen',
      (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final doctor = Doctor.fromMap({
      'category': 'Cardiology',
      'city': 'TP. Hồ Chí Minh',
      'email': 'demo@example.com',
      'firstName': 'Nguyễn Thị',
      'lastName': 'Minh Phương',
      'profileImageUrl': '',
      'qualification': 'MD',
      'phoneNumber': '0900000000',
      'yearsOfExperience': '12',
      'numberOfReviews': 0,
      'totalReviews': 0,
    }, 'demo');
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: Scaffold(body: DoctorCard(doctor: doctor)),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.textContaining('TP. Hồ Chí Minh'), findsOneWidget);
  });

  for (final size in [
    const Size(375, 812),
    const Size(812, 375),
    const Size(1440, 900)
  ]) {
    testWidgets('Sign in validates inline without losing input at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
          MaterialApp(theme: buildAppTheme(), home: const LoginPage()));
      await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
      await tester.ensureVisible(find.text('Sign in'));
      await tester.tap(find.text('Sign in'));
      await tester.pump();
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
      expect(find.text('not-an-email'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'Registration retains the selected role and validates extra doctor fields',
      (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const RegisterPage()));
    await tester.ensureVisible(find.text('Doctor'));
    await tester.tap(find.text('Doctor'));
    await tester.pump();
    await tester.tap(find.text('Doctor'));
    await tester.pump();
    expect(find.text('Professional information'), findsOneWidget);
    final submit = find.widgetWithText(ElevatedButton, 'Create account');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    expect(find.text('Enter a valid number of years.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Navigation preserves selected page when resizing from phone to desktop',
      (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(),
        home: const HomeShell(
          pages: [Text('Care content'), Text('Message content')],
          destinations: [
            NavigationDestination(icon: Icon(Icons.search), label: 'Care'),
            NavigationDestination(icon: Icon(Icons.chat), label: 'Messages')
          ],
        )));
    await tester.tap(find.text('Messages'));
    await tester.pumpAndSettle();
    expect(find.text('Message content'), findsOneWidget);
    tester.view.physicalSize = const Size(1440, 900);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Message content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
