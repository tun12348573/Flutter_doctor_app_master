import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import '../doctor/doctor_home_page.dart';
import '../patient/patient_home_page.dart';
import '../pharmacist/pharmacist_home_page.dart';

/// Home screen for the signed-in user's role, or null when no profile exists.
Future<Widget?> homeForUser(String uid) async {
  final database = FirebaseDatabase.instance.ref();
  if ((await database.child('Doctors').child(uid).get()).exists) {
    return const DoctorHomePage();
  }
  if ((await database.child('Pharmacists').child(uid).get()).exists) {
    return const PharmacistHomePage();
  }
  if ((await database.child('Patients').child(uid).get()).exists) {
    return const PatientHomePage();
  }
  return null;
}
