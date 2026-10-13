import 'package:practice/l10n/app_strings.dart';
import 'package:flutter/material.dart';

class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = 1040});
  final Widget child;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth), child: child));
}

class AuthLayout extends StatelessWidget {
  const AuthLayout(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.child});
  final String title;
  final String subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => SafeArea(
      child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: ContentWidth(
              maxWidth: 560,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Icon(Icons.health_and_safety_outlined,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Flexible(
                          child: Text('DoctorApp',
                              style: Theme.of(context).textTheme.titleLarge))
                    ]),
                    const SizedBox(height: 32),
                    Text(context.tr(title),
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(context.tr(subtitle)),
                    const SizedBox(height: 24),
                    Card(
                        child: Padding(
                            padding: const EdgeInsets.all(24), child: child)),
                  ]))));
}

class AppStatus extends StatelessWidget {
  const AppStatus(
      {super.key,
      required this.icon,
      required this.title,
      required this.message,
      this.onRetry});
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Center(
      child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(context.tr(title),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(context.tr(message), textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.tr('Try again')))
            ],
          ])));
}
