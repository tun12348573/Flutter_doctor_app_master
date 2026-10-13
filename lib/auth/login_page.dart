import 'package:practice/l10n/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../ui/app_widgets.dart';
import 'role_home.dart';
import 'signup_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _isLoading = false;
  bool _obscureText = true;
  String? _error;

  Future<void> _login() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      final home = await homeForUser(credential.user!.uid);
      if (!mounted) return;
      if (home == null) {
        setState(() => _error =
            'Your profile could not be found. Please contact the demo administrator.');
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => home), (_) => false);
    } on FirebaseAuthException {
      if (mounted) {
        setState(() => _error =
            'Unable to sign in. Check your email, password and connection.');
      }
    } catch (_) {
      if (mounted) {
        setState(
            () => _error = 'Unable to load your profile. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(actions: const [LanguageButton()]),
        body: AuthLayout(
            title: context.tr('Welcome back'),
            subtitle: context.tr('Your next step to better care starts here.'),
            child: AutofillGroup(
                child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(context.tr('Sign in to your account'),
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 24),
                          TextFormField(
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                  labelText: context.tr('Email'),
                                  prefixIcon: const Icon(Icons.mail_outline)),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              autocorrect: false,
                              onChanged: (value) => email = value,
                              validator: (value) => value == null ||
                                      !value.trim().contains('@')
                                  ? context.tr('Enter a valid email address.')
                                  : null),
                          const SizedBox(height: 20),
                          TextFormField(
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                  labelText: context.tr('Password'),
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
                              autofillHints: const [AutofillHints.password],
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _login(),
                              onChanged: (value) => password = value,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? context.tr('Enter your password.')
                                      : null),
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
                              onPressed: _isLoading ? null : _login,
                              child: Text(_isLoading
                                  ? context.tr('Signing in...')
                                  : context.tr('Sign in'))),
                          const SizedBox(height: 12),
                          TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const RegisterPage())),
                              child: Text(
                                  context.tr('New here? Create an account'))),
                        ])))),
      );
}
