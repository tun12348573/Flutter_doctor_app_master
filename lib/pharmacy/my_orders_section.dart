import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../ui/app_widgets.dart';
import 'model/drug_order.dart';
import 'pharmacy_store.dart';
import 'pharmacy_widgets.dart';

/// Patient's medicine orders, shown in My account.
class MyOrdersSection extends StatefulWidget {
  const MyOrdersSection({super.key});
  @override
  State<MyOrdersSection> createState() => _MyOrdersSectionState();
}

class _MyOrdersSectionState extends State<MyOrdersSection> {
  final _store = PharmacyStore();
  List<DrugOrder> _orders = [];
  bool _isLoading = true;
  bool _failed = false;
  String? _cancelling;

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
      final orders =
          await _store.orders(uid: FirebaseAuth.instance.currentUser!.uid);
      if (mounted) setState(() => _orders = orders);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancel(DrugOrder order) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(context.tr('Cancel this order?')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(context.tr('Keep order'))),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(context.tr('Cancel order'))),
              ],
            ));
    if (confirmed != true || !mounted) return;
    setState(() => _cancelling = order.id);
    try {
      await _store.cancelPending(order);
      await _fetch();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.tr(
                'Unable to cancel. The pharmacy may have already confirmed it.'))));
        _fetch();
      }
    } finally {
      if (mounted) setState(() => _cancelling = null);
    }
  }

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
              child: Text(context.tr('Your medicine orders'),
                  style: Theme.of(context).textTheme.titleLarge)),
          IconButton(
              tooltip: context.tr('Refresh orders'),
              onPressed: _isLoading ? null : _fetch,
              icon: const Icon(Icons.refresh)),
        ]),
        if (_isLoading)
          const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()))
        else if (_failed)
          AppStatus(
              icon: Icons.wifi_off_outlined,
              title: context.tr('Unable to load orders'),
              message: context.tr('Check your connection and try again.'),
              onRetry: _fetch)
        else if (_orders.isEmpty)
          AppStatus(
              icon: Icons.local_pharmacy_outlined,
              title: context.tr('No orders yet'),
              message: context.tr('Find medicines in the Pharmacy tab.'))
        else
          for (final order in _orders)
            OrderCard(order: order, actions: [
              if (order.status == 'pending')
                OutlinedButton(
                    onPressed:
                        _cancelling == null ? () => _cancel(order) : null,
                    child: Text(context.tr(_cancelling == order.id
                        ? 'Cancelling...'
                        : 'Cancel order'))),
            ]),
      ]);
}
