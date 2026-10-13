import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../ui/app_widgets.dart';
import 'model/drug.dart';
import 'pharmacy_widgets.dart';

class DrugDetailsPage extends StatelessWidget {
  const DrugDetailsPage(
      {super.key,
      required this.drug,
      this.onAddToCart,
      this.onAskAi,
      this.onBookVisit});
  final Drug drug;
  final VoidCallback? onAddToCart;
  final VoidCallback? onAskAi;
  final VoidCallback? onBookVisit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget section(String title, String body) => body.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(context.tr(title), style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              SelectableText(body),
            ]));
    return Scaffold(
      appBar: AppBar(
          title: Text(context.tr('Medicine details')),
          actions: const [LanguageButton()]),
      body: ContentWidth(
          maxWidth: 880,
          child: ListView(padding: const EdgeInsets.all(24), children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(radius: 32, child: Icon(drugIcon(drug.category), size: 32)),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(drug.name, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(context.tr(drug.category)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 4, children: drugTags(drug)),
              ])),
            ]),
            const SizedBox(height: 20),
            Text(formatVnd(drug.price),
                style: theme.textTheme.headlineSmall
                    ?.copyWith(color: theme.colorScheme.primary)),
            if (drug.pack.isNotEmpty) Text(drug.pack),
            const SizedBox(height: 20),
            if (drug.prescription)
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(context.tr('Prescription required'),
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(context.tr(
                            'This medicine is sold only with a doctor\'s prescription. Book a visit to get advice.')),
                        if (onBookVisit != null) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                              onPressed: onBookVisit,
                              icon: const Icon(Icons.calendar_month_outlined),
                              label: Text(context.tr('Book an appointment'))),
                        ],
                      ])))
            else
              FilledButton.icon(
                  onPressed: drug.canBuy ? onAddToCart : null,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(context.tr(drug.inStock ? 'Add to cart' : 'Out of stock'))),
            if (onAskAi != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                  onPressed: onAskAi,
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: Text(context.tr('Ask AI about this medicine'))),
            ],
            const SizedBox(height: 8),
            section('Active ingredient', [drug.ingredient, drug.strength]
                .where((s) => s.isNotEmpty)
                .join(' — ')),
            section('Dosage form', drug.form),
            section('Uses', drug.uses),
            section('How to use', drug.dosage),
            section('Contraindications', drug.contraindications),
            section('Side effects', drug.sideEffects),
            const SizedBox(height: 24),
            const DemoDataNotice(),
          ])),
    );
  }
}
