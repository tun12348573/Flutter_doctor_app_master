import 'package:flutter_test/flutter_test.dart';
import 'package:practice/doctor/model/doctor.dart';

void main() {
  final profile = <String, dynamic>{
    'category': 'Dentist',
    'city': 'TP. Hồ Chí Minh',
    'email': 'doctor@example.com',
    'firstName': 'Demo',
    'lastName': 'Doctor',
    'profileImageUrl': '',
    'qualification': 'DDS',
    'phoneNumber': '0900000000',
    'yearsOfExperience': '2',
    'numberOfReviews': 0,
    'totalReviews': 0,
  };

  test('Reads integer coordinates returned by Realtime Database', () {
    final doctor = Doctor.fromMap({
      ...profile,
      'latitude': 10,
      'longitude': 106,
    }, 'demo-doctor');

    expect(doctor.latitude, 10.0);
    expect(doctor.longitude, 106.0);
  });

  test('Preserves fractional coordinates', () {
    final doctor = Doctor.fromMap({
      ...profile,
      'latitude': 10.75,
      'longitude': 106.625,
    }, 'demo-doctor');

    expect(doctor.latitude, 10.75);
    expect(doctor.longitude, 106.625);
  });

  test('Defaults missing coordinates to zero', () {
    final doctor = Doctor.fromMap(profile, 'demo-doctor');

    expect(doctor.latitude, 0.0);
    expect(doctor.longitude, 0.0);
  });
}
