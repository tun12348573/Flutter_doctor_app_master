import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_strings.dart';
import 'model/drug.dart';
import 'model/drug_order.dart';

class DemoDataNotice extends StatelessWidget {
  const DemoDataNotice({super.key});
  @override
  Widget build(BuildContext context) => Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 12),
            Expanded(
                child: Text(context.tr(
                    'Demo data. Read the package leaflet and ask a pharmacist before use.'))),
          ])));
}

class DrugTag extends StatelessWidget {
  const DrugTag(this.label, {super.key, this.warning = false});
  final String label;
  final bool warning;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
            color: warning ? scheme.errorContainer : scheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(8)),
        child: Text(context.tr(label),
            style: Theme.of(context).textTheme.labelMedium));
  }
}

List<Widget> drugTags(Drug drug, {bool forPharmacist = false}) => [
      if (drug.prescription) const DrugTag('Prescription'),
      if (!drug.inStock)
        const DrugTag('Out of stock', warning: true)
      else if (forPharmacist && drug.isLow)
        const DrugTag('Low stock', warning: true),
    ];

class DrugTile extends StatelessWidget {
  const DrugTile(
      {super.key, required this.drug, this.onTap, this.trailing, this.subtitle});
  final Drug drug;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? subtitle;
  @override
  Widget build(BuildContext context) => Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(child: Icon(drugIcon(drug.category))),
          title: Text(drug.name),
          subtitle: subtitle ??
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text([drug.ingredient, drug.pack]
                    .where((s) => s.isNotEmpty)
                    .join(' · ')),
                const SizedBox(height: 4),
                Wrap(spacing: 8, runSpacing: 4, children: [
                  Text(formatVnd(drug.price),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600)),
                  ...drugTags(drug),
                ]),
              ]),
          trailing: trailing));
}

class OrderCard extends StatelessWidget {
  const OrderCard(
      {super.key,
      required this.order,
      this.showCustomer = false,
      this.actions = const []});
  final DrugOrder order;
  final bool showCustomer;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final created = order.createdAt == 0
        ? ''
        : DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
            .add_Hm()
            .format(DateTime.fromMillisecondsSinceEpoch(order.createdAt));
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(spacing: 16, runSpacing: 8, children: [
                    Text(
                        context.tr('Order #{id}', {
                          'id': order.id.substring(order.id.length - 6).toUpperCase()
                        }),
                        style: theme.textTheme.titleMedium),
                    Text(context.tr(order.statusLabel),
                        style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600)),
                    if (created.isNotEmpty) Text(created),
                  ]),
                  const SizedBox(height: 12),
                  for (final item in order.items.values)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(children: [
                          Expanded(child: Text('${item.qty} × ${item.name}')),
                          Text(formatVnd(item.subtotal)),
                        ])),
                  const Divider(),
                  Row(children: [
                    Expanded(
                        child: Text(context.tr('Total (cash on delivery)'),
                            style: theme.textTheme.titleSmall)),
                    Text(formatVnd(order.total),
                        style: theme.textTheme.titleSmall),
                  ]),
                  if (showCustomer) ...[
                    const SizedBox(height: 12),
                    Text('${order.name} · ${order.phone}'),
                    Text(order.address),
                    if (order.note.isNotEmpty)
                      Text(context.tr('Note: {value}', {'value': order.note})),
                  ],
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: actions),
                  ],
                ])));
  }
}
