import 'package:flutter_test/flutter_test.dart';
import 'package:practice/admin/doctor_verification_page.dart';

Map<String, Object?> doctor(String first, {bool? verified}) => {
      'category': 'Dentist',
      'city': 'Hanoi',
      'email': '$first@x.vn',
      'firstName': first,
      'lastName': 'Nguyen',
      'profileImageUrl': '',
      'qualification': 'MD',
      'phoneNumber': '090',
      'yearsOfExperience': '3',
      'numberOfReviews': 0,
      'totalReviews': 0,
      if (verified != null) 'verified': verified,
    };

void main() {
  test('Review list puts unverified doctors first and skips malformed profiles',
      () {
    final doctors = doctorsForReview({
      'a': doctor('Binh', verified: true),
      'b': doctor('Lan'),
      'c': doctor('An'),
      'junk': {'firstName': 'Eve'},
      'text': 'not a profile',
    });
    expect(doctors.map((d) => d.uid), ['c', 'b', 'a']);
    expect(doctors.map((d) => d.verified), [false, false, true]);
  });
}
