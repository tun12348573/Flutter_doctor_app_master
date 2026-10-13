import 'package:practice/l10n/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../doctor/doctor_home_page.dart';
import '../patient/patient_home_page.dart';
import '../ui/app_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String userType = 'Patient';
  String email = '';
  String password = '';
  String phoneNumber = '';
  String firstName = '';
  String lastName = '';
  String city = 'TP. Hồ Chí Minh';
  String category = 'Dentist';
  String qualification = '';
  String yearsOfExperience = '';
  double latitude = 0;
  double longitude = 0;
  bool _hasLocation = false;
  bool _locating = false;
  bool _isLoading = false;
  bool _obscureText = true;
  String? _error;
  String? _locationError;
  User? _createdUser;

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? context.tr('This field is required.')
      : null;

  Future<void> _getLocation() async {
    if (_locating) return;
    setState(() {
      _locating = true;
      _locationError = null;
    });
    try {
      final data = await Location().getLocation();
      if (data.latitude == null || data.longitude == null) {
        throw StateError('Location unavailable');
      }
      if (!mounted) return;
      setState(() {
        latitude = data.latitude!;
        longitude = data.longitude!;
        _hasLocation = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _locationError =
            'Location unavailable. Allow location access or continue without it.');
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _register() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Keep the account after a profile-write failure so Retry does not create it twice.
      _createdUser ??= (await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: email.trim(), password: password))
          .user;
      final user = _createdUser;
      if (user == null) throw StateError('Account unavailable');
      final data = <String, dynamic>{
        'uid': user.uid,
        'email': email.trim(),
        'phoneNumber': phoneNumber.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'city': city,
        'profileImageUrl': '',
        'latitude': latitude,
        'longitude': longitude,
        if (userType == 'Doctor') ...{
          'qualification': qualification.trim(),
          'category': category,
          'yearsOfExperience': yearsOfExperience.trim(),
          'totalReviews': 0,
          'averageRating': 0.0,
          'numberOfReviews': 0,
        },
      };
      await FirebaseDatabase.instance
          .ref(userType == 'Doctor' ? 'Doctors' : 'Patients')
          .child(user.uid)
          .set(data);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (_) => userType == 'Doctor'
                  ? const DoctorHomePage()
                  : const PatientHomePage()),
          (_) => false);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _error = e.code == 'email-already-in-use'
            ? 'This email already has an account. Please sign in.'
            : 'Unable to create your account. Check your details and connection.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Unable to save your profile. Your entries are kept; please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(context.tr('Create account')),
            actions: const [LanguageButton()]),
        body: AuthLayout(
            title: context.tr('Better care, together'),
            subtitle: context.tr(
                'Join as a patient or doctor. It only takes a few details.'),
            child: AutofillGroup(
                child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(context.tr('I am a'),
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          Wrap(spacing: 12, runSpacing: 8, children: [
                            for (final type in ['Patient', 'Doctor'])
                              ChoiceChip(
                                  label: Text(context.tr(type)),
                                  selected: userType == type,
                                  avatar: Icon(
                                      type == 'Doctor'
                                          ? Icons.medical_services_outlined
                                          : Icons.person_outline,
                                      size: 20),
                                  onSelected: _isLoading
                                      ? null
                                      : (_) => setState(() => userType = type)),
                          ]),
                          const SizedBox(height: 24),
                          Text(context.tr('Account details'),
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 20),
                          TextFormField(
                              enabled: !_isLoading && _createdUser == null,
                              decoration: InputDecoration(
                                  labelText: context.tr('Email'),
                                  prefixIcon: const Icon(Icons.mail_outline)),
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              onChanged: (v) => email = v,
                              validator: (v) => v == null ||
                                      !v.trim().contains('@')
                                  ? context.tr('Enter a valid email address.')
                                  : null),
                          const SizedBox(height: 20),
                          TextFormField(
                              enabled: !_isLoading && _createdUser == null,
                              decoration: InputDecoration(
                                  labelText: context.tr('Password'),
                                  helperText:
                                      context.tr('Use at least 6 characters.'),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                      tooltip: _obscureText
                                          ? context.tr('Show password')
                                          : context.tr('Hide password'),
                                      onPressed: () => setState(
                                          () => _obscureText = !_obscureText),
                                      icon: Icon(_obscureText
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined))),
                              obscureText: _obscureText,
                              enableSuggestions: false,
                              autocorrect: false,
                              autofillHints: const [AutofillHints.newPassword],
                              textInputAction: TextInputAction.next,
                              onChanged: (v) => password = v,
                              validator: (v) => (v?.length ?? 0) < 6
                                  ? context.tr('Use at least 6 characters.')
                                  : null),
                          const SizedBox(height: 24),
                          Text(context.tr('Personal information'),
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 20),
                          TextFormField(
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                  labelText: context.tr('First name')),
                              autofillHints: const [AutofillHints.givenName],
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              onChanged: (v) => firstName = v,
                              validator: _required),
                          const SizedBox(height: 20),
                          TextFormField(
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                  labelText: context.tr('Last name')),
                              autofillHints: const [AutofillHints.familyName],
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              onChanged: (v) => lastName = v,
                              validator: _required),
                          const SizedBox(height: 20),
                          TextFormField(
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                  labelText: context.tr('Phone number')),
                              keyboardType: TextInputType.phone,
                              autofillHints: const [
                                AutofillHints.telephoneNumber
                              ],
                              textInputAction: TextInputAction.next,
                              onChanged: (v) => phoneNumber = v,
                              validator: _required),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                              initialValue: city,
                              isExpanded: true,
                              decoration: InputDecoration(
                                  labelText: context.tr('City')),
                              items: [
                                'TP. Hồ Chí Minh',
                                'Hà Nội',
                                'Đà Nẵng',
                                'Hải Phòng',
                                'Cần Thơ',
                                'Huế'
                              ]
                                  .map((v) => DropdownMenuItem(
                                      value: v, child: Text(context.tr(v))))
                                  .toList(),
                              onChanged: _isLoading
                                  ? null
                                  : (v) => setState(() => city = v!)),
                          if (userType == 'Doctor') ...[
                            const SizedBox(height: 24),
                            Text(context.tr('Professional information'),
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 20),
                            TextFormField(
                                initialValue: qualification,
                                enabled: !_isLoading,
                                decoration: InputDecoration(
                                    labelText: context.tr('Qualification')),
                                textInputAction: TextInputAction.next,
                                onChanged: (v) => qualification = v,
                                validator: _required),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                                initialValue: category,
                                isExpanded: true,
                                decoration: InputDecoration(
                                    labelText: context.tr('Specialty')),
                                items: [
                                  'Dentist',
                                  'Cardiology',
                                  'Oncology',
                                  'Surgeon'
                                ]
                                    .map((v) => DropdownMenuItem(
                                        value: v, child: Text(context.tr(v))))
                                    .toList(),
                                onChanged: _isLoading
                                    ? null
                                    : (v) => setState(() => category = v!)),
                            const SizedBox(height: 20),
                            TextFormField(
                                initialValue: yearsOfExperience,
                                enabled: !_isLoading,
                                decoration: InputDecoration(
                                    labelText:
                                        context.tr('Years of experience')),
                                keyboardType: TextInputType.number,
                                onChanged: (v) => yearsOfExperience = v,
                                validator: (v) => int.tryParse(v ?? '') ==
                                            null ||
                                        int.parse(v!) < 0
                                    ? context
                                        .tr('Enter a valid number of years.')
                                    : null),
                          ],
                          const SizedBox(height: 24),
                          Text(context.tr('Location (optional)'),
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(context.tr(
                              'Share your current location to help with directions.')),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                              onPressed:
                                  _isLoading || _locating ? null : _getLocation,
                              icon: Icon(_hasLocation
                                  ? Icons.check_circle_outline
                                  : Icons.my_location),
                              label: Text(_locating
                                  ? context.tr('Getting location...')
                                  : _hasLocation
                                      ? context.tr('Location added')
                                      : context.tr('Use current location'))),
                          if (_locationError != null)
                            Semantics(
                                liveRegion: true,
                                child: Text(context.tr(_locationError!))),
                          if (_error != null)
                            Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Semantics(
                                    liveRegion: true,
                                    child: Text(context.tr(_error!),
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error)))),
                          const SizedBox(height: 24),
                          ElevatedButton(
                              onPressed:
                                  _isLoading || _locating ? null : _register,
                              child: Text(_isLoading
                                  ? context.tr('Creating account...')
                                  : context.tr('Create account'))),
                          const SizedBox(height: 12),
                          TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: Text(context
                                  .tr('Already have an account? Sign in'))),
                        ])))),
      );
}
