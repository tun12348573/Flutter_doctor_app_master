import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice/auth/login_page.dart';
import 'package:practice/auth/signup_screen.dart';
import 'package:practice/l10n/app_strings.dart';
import 'package:practice/ui/app_theme.dart';
import 'package:practice/doctor/doctor_details_page.dart';
import 'package:practice/doctor/model/doctor.dart';

Widget localized(Widget home) => ValueListenableBuilder<Locale?>(
      valueListenable: appLocale,
      builder: (_, locale, __) => MaterialApp(
        theme: buildAppTheme(),
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('vi')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: home,
      ),
    );

Future<void> chooseLanguage(WidgetTester tester, String name) async {
  await tester.tap(find.byType(LanguageButton));
  await tester.pumpAndSettle();
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => appLocale.value = const Locale('en'));
  tearDown(() => appLocale.value = null);

  testWidgets(
      'Booking date and time honor the selected language and preserve unknown legacy values',
      (tester) async {
    await tester.pumpWidget(localized(Builder(
        builder: (context) => Scaffold(
                body: Column(children: [
              Text(context.appointmentDate('12/31/2026')),
              Text(context.appointmentTime('3:30 PM')),
              Text(context.appointmentTime('legacy time')),
            ])))));
    await tester.pumpAndSettle();
    expect(find.text('Dec 31, 2026'), findsOneWidget);
    expect(find.text('3:30 PM'), findsOneWidget);
    appLocale.value = const Locale('vi');
    await tester.pumpAndSettle();
    expect(find.text('Dec 31, 2026'), findsNothing);
    expect(find.text('15:30'), findsOneWidget);
    expect(find.text('legacy time'), findsOneWidget);
  });

  testWidgets(
      'Appointment date picker uses Vietnamese and retains the visit reason',
      (tester) async {
    final doctor = Doctor.fromMap({
      'category': 'Cardiology',
      'city': 'Hà Nội',
      'email': 'demo@example.com',
      'firstName': 'Demo',
      'lastName': 'Doctor',
      'profileImageUrl': '',
      'qualification': 'MD',
      'phoneNumber': '0900000000',
      'yearsOfExperience': '10',
      'numberOfReviews': 0,
      'totalReviews': 0,
    }, 'demo');
    await tester.pumpWidget(localized(DoctorDetailPage(doctor: doctor)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextFormField));
    await tester.enterText(find.byType(TextFormField), 'My visit reason');
    await chooseLanguage(tester, 'Tiếng Việt');
    expect(find.text('My visit reason'), findsOneWidget);
    await tester.ensureVisible(find.text('Chọn ngày'));
    await tester.tap(find.text('Chọn ngày'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(
        Localizations.localeOf(tester.element(find.byType(DatePickerDialog)))
            .languageCode,
        'vi');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Switching languages translates validation and preserves the sign-in form',
      (tester) async {
    await tester.pumpWidget(localized(const LoginPage()));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byType(TextFormField).first, 'unfinished-email');
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();
    await chooseLanguage(tester, 'Tiếng Việt');
    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(find.text('Vui lòng nhập địa chỉ email hợp lệ.'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu.'), findsOneWidget);
    expect(find.text('unfinished-email'), findsOneWidget);
    await chooseLanguage(tester, 'English');
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('unfinished-email'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Vietnamese specialty labels retain the English Firebase value',
      (tester) async {
    await tester.pumpWidget(localized(const RegisterPage()));
    await tester.pumpAndSettle();
    await chooseLanguage(tester, 'Tiếng Việt');
    await tester.ensureVisible(find.text('Bác sĩ'));
    await tester.tap(find.text('Bác sĩ'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Nha khoa'));
    await tester.tap(find.text('Nha khoa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tim mạch').last);
    await tester.pumpAndSettle();
    final specialty = tester
        .widgetList<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>))
        .last;
    expect(specialty.initialValue, 'Cardiology');
    await chooseLanguage(tester, 'English');
    expect(find.text('Cardiology'), findsOneWidget);
    expect(find.text('Professional information'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Vietnamese forms fit a small screen with large text',
      (tester) async {
    appLocale.value = const Locale('vi');
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(localized(const MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(2)),
      child: RegisterPage(),
    )));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Bác sĩ'));
    await tester.tap(find.text('Bác sĩ'));
    await tester.pumpAndSettle();
    final submit = find.widgetWithText(ElevatedButton, 'Tạo tài khoản');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập số năm hợp lệ.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
