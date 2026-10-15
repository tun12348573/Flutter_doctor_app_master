import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice/firebase_options.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    test('${platform.name} uses the doctor-app-df8ca Firebase project', () {
      debugDefaultTargetPlatformOverride = platform;
      try {
        final options = DefaultFirebaseOptions.currentPlatform;
        expect(options.projectId, 'doctor-app-df8ca');
        expect(options.databaseURL, DefaultFirebaseOptions.web.databaseURL);
        expect(options.appId,
            contains(platform == TargetPlatform.iOS ? ':ios:' : ':android:'));
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }
}
