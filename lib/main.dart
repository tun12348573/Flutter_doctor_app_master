import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:practice/splash_screen.dart';

import 'firebase_options.dart';
import 'ui/app_theme.dart';
import 'l10n/app_strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
        valueListenable: appLocale,
        builder: (context, locale, _) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'DoctorApp',
              theme: buildAppTheme(),
              locale: locale,
              supportedLocales: const [Locale('en'), Locale('vi')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              home: const SplashScreen(),
            ));
  }
}
