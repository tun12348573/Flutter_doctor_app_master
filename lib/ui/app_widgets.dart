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

/// App logo tile. Decorative: the app name is always shown next to it or in
/// the page title, so screen readers skip it.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40});
  final double size;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
        child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [scheme.primary, scheme.secondary]),
                borderRadius: BorderRadius.circular(size * 0.3)),
            child: Icon(Icons.health_and_safety_outlined,
                size: size * 0.6, color: scheme.onPrimary)));
  }
}

enum StatusTone { pending, active, done, stopped }

/// Status label with icon and colour, so status never relies on colour alone.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.tone});
  final String label;
  final StatusTone tone;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, icon) = switch (tone) {
      StatusTone.pending => (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
          Icons.schedule
        ),
      StatusTone.active => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          Icons.local_shipping_outlined
        ),
      StatusTone.done => (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
          Icons.check_circle_outline
        ),
      StatusTone.stopped => (
          scheme.errorContainer,
          scheme.onErrorContainer,
          Icons.cancel_outlined
        ),
    };
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          ExcludeSemantics(child: Icon(icon, size: 16, color: fg)),
          const SizedBox(width: 6),
          Flexible(
              child: Text(label,
                  style: TextStyle(
                      color: fg, fontSize: 14, fontWeight: FontWeight.w600))),
        ]));
  }
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
                      const BrandMark(),
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
