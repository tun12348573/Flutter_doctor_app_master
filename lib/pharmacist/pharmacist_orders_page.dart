import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../pharmacy/model/drug_order.dart';
import '../pharmacy/pharmacy_store.dart';
import '../pharmacy/pharmacy_widgets.dart';
import '../ui/app_widgets.dart';

class PharmacistOrdersPage extends StatefulWidget {
  const PharmacistOrdersPage({super.key});
  @override
  State<PharmacistOrdersPage> createState() => _PharmacistOrdersPageState();
}

class _PharmacistOrdersPageState extends State<PharmacistOrdersPage> {
  final _store = PharmacyStore();
  List<DrugOrder> _orders = [];
  bool _isLoading = true;
  bool _failed = false;
  String _status = 'pending';
  String? _busy;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _failed = false;
    });
    try {
      final orders = await _store.orders();
      if (mounted) setState(() => _orders = orders);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _run(DrugOrder order, Future<void> Function(DrugOrder) action) async {
    setState(() => _busy = order.id);
    try {
      await action(order);
    } on OutOfStock catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.tr(
                'Not enough stock for {name}. Restock or cancel the order.',
                {'name': e.drugName}))));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.tr('Unable to save. Please try again.'))));
      }
    } finally {
      if (mounted) setState(() => _busy = null);
      await _fetch();
    }
  }

  Future<void> _confirmCancel(DrugOrder order) async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(context.tr('Cancel this order?')),
              content: order.stockDeducted
                  ? Text(context.tr('Its stock will be returned to inventory.'))
                  : null,
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(context.tr('Keep order'))),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(context.tr('Cancel order'))),
              ],
            ));
    if (ok == true && mounted) await _run(order, _store.cancel);
  }

  @override
  Widget build(BuildContext context) {
    final orders = _orders.where((o) => o.status == _status).toList();
    final idle = _busy == null;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Orders')), actions: [
        const LanguageButton(),
        IconButton(
            tooltip: context.tr('Refresh orders'),
            onPressed: _isLoading ? null : _fetch,
            icon: const Icon(Icons.refresh)),
      ]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _failed
              ? AppStatus(
                  icon: Icons.wifi_off_outlined,
                  title: context.tr('Unable to load orders'),
                  message: context.tr('Check your connection and try again.'),
                  onRetry: _fetch)
              : ListView(padding: const EdgeInsets.all(24), children: [
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final entry in DrugOrder.statusLabels.entries)
                      ChoiceChip(
                          label: Text(
                              '${context.tr(entry.value)} (${_orders.where((o) => o.status == entry.key).length})'),
                          selected: _status == entry.key,
                          onSelected: (_) => setState(() => _status = entry.key)),
                  ]),
                  const SizedBox(height: 16),
                  if (orders.isEmpty)
                    AppStatus(
                        icon: Icons.receipt_long_outlined,
                        title: context.tr('No orders here'),
                        message: context.tr('New orders from patients will appear here.'))
                  else
                    for (final order in orders)
                      OrderCard(order: order, showCustomer: true, actions: [
                        if (order.status == 'pending')
                          FilledButton(
                              onPressed: idle ? () => _run(order, _store.confirm) : null,
                              child: Text(context.tr(_busy == order.id
                                  ? 'Saving...'
                                  : 'Confirm and ship'))),
                        if (order.status == 'shipping')
                          FilledButton(
                              onPressed: idle ? () => _run(order, _store.markDelivered) : null,
                              child: Text(context.tr(_busy == order.id
                                  ? 'Saving...'
                                  : 'Mark delivered'))),
                        if (order.status == 'pending' || order.status == 'shipping')
                          OutlinedButton(
                              onPressed: idle ? () => _confirmCancel(order) : null,
                              child: Text(context.tr('Cancel order'))),
                      ]),
                ]),
    );
  }
}
