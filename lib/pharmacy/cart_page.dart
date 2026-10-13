import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../ui/app_widgets.dart';
import 'model/drug.dart';
import 'model/drug_order.dart';
import 'pharmacy_store.dart';
import 'pharmacy_widgets.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key, required this.store, required this.uid});
  final PharmacyStore store;
  final String uid;
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _note = TextEditingController();
  late final Stream<Map<String, int>> _cart = widget.store.cart(widget.uid);
  Map<String, Drug> _drugs = {};
  bool _isLoading = true;
  bool _failed = false;
  bool _placing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _address, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _failed = false;
    });
    try {
      final drugs = await widget.store.loadDrugs();
      if (_name.text.isEmpty && _phone.text.isEmpty) {
        final profile =
            await FirebaseDatabase.instance.ref('Patients/${widget.uid}').get();
        final data = (profile.value as Map?) ?? const {};
        _name.text = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
        _phone.text = '${data['phoneNumber'] ?? ''}';
      }
      if (mounted) setState(() => _drugs = drugs);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setQty(String drugId, int qty) async {
    try {
      await widget.store.setCartQty(widget.uid, drugId, qty);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.tr('Unable to update your cart. Please try again.'))));
      }
    }
  }

  Future<void> _placeOrder(Map<String, int> cart) async {
    if (_placing || !_formKey.currentState!.validate()) return;
    setState(() {
      _placing = true;
      _error = null;
    });
    try {
      // Re-read the catalog so the order uses current prices and stock.
      final drugs = await widget.store.loadDrugs();
      final problem = cartProblem(cart, drugs);
      if (problem != null) {
        setState(() {
          _drugs = drugs;
          _error = problem;
        });
        return;
      }
      await widget.store.placeOrder(
          uid: widget.uid,
          items: orderItems(cart, drugs),
          name: _name.text.trim(),
          phone: _phone.text.trim(),
          address: _address.text.trim(),
          note: _note.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.tr('Order placed. Track it in My account.'))));
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to place your order. Please try again.');
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? context.tr('This field is required.') : null;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(context.tr('Cart')), actions: const [LanguageButton()]),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _failed
                ? AppStatus(
                    icon: Icons.wifi_off_outlined,
                    title: context.tr('Unable to load your cart'),
                    message: context.tr('Check your connection and try again.'),
                    onRetry: _load)
                : StreamBuilder<Map<String, int>>(
                    stream: _cart,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final cart = snapshot.data!;
                      if (cart.isEmpty) {
                        return AppStatus(
                            icon: Icons.shopping_cart_outlined,
                            title: context.tr('Your cart is empty.'),
                            message: context.tr('Find medicines in the Pharmacy tab.'));
                      }
                      final total = cart.entries.fold<int>(
                          0, (sum, e) => sum + (_drugs[e.key]?.price ?? 0) * e.value);
                      return ContentWidth(
                          maxWidth: 880,
                          child: ListView(padding: const EdgeInsets.all(24), children: [
                            for (final entry in cart.entries) _line(entry.key, entry.value),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                  child: Text(context.tr('Total (cash on delivery)'),
                                      style: Theme.of(context).textTheme.titleMedium)),
                              Text(formatVnd(total),
                                  style: Theme.of(context).textTheme.titleMedium),
                            ]),
                            const SizedBox(height: 24),
                            Text(context.tr('Delivery details'),
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 12),
                            Form(
                                key: _formKey,
                                child: Column(children: [
                                  TextFormField(
                                      controller: _name,
                                      maxLength: 100,
                                      decoration: InputDecoration(labelText: context.tr('Full name')),
                                      validator: _required),
                                  TextFormField(
                                      controller: _phone,
                                      maxLength: 20,
                                      keyboardType: TextInputType.phone,
                                      decoration:
                                          InputDecoration(labelText: context.tr('Phone number')),
                                      validator: (value) => RegExp(r'^\+?[0-9 ]{9,15}$')
                                              .hasMatch((value ?? '').trim())
                                          ? null
                                          : context.tr('Enter a valid phone number.')),
                                  TextFormField(
                                      controller: _address,
                                      maxLength: 300,
                                      minLines: 2,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                          labelText: context.tr('Delivery address')),
                                      validator: _required),
                                  TextFormField(
                                      controller: _note,
                                      maxLength: 300,
                                      decoration:
                                          InputDecoration(labelText: context.tr('Note (optional)'))),
                                ])),
                            if (_error != null)
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(context.tr(_error!),
                                      style: TextStyle(
                                          color: Theme.of(context).colorScheme.error))),
                            FilledButton.icon(
                                onPressed: _placing ? null : () => _placeOrder(cart),
                                icon: const Icon(Icons.local_shipping_outlined),
                                label: Text(context.tr(_placing
                                    ? 'Placing order...'
                                    : 'Place order (cash on delivery)'))),
                          ]));
                    }),
      );

  Widget _line(String drugId, int qty) {
    final drug = _drugs[drugId];
    if (drug == null || !drug.canBuy) {
      return Card(
          child: ListTile(
              leading: const Icon(Icons.error_outline),
              title: Text(drug?.name ?? context.tr('Unavailable medicine')),
              subtitle: Text(context.tr('No longer available. Remove it to continue.')),
              trailing: IconButton(
                  tooltip: context.tr('Remove'),
                  onPressed: () => _setQty(drugId, 0),
                  icon: const Icon(Icons.delete_outline))));
    }
    return DrugTile(
        drug: drug,
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(formatVnd(drug.price * qty)),
          if (qty > drug.maxQty)
            Text(context.tr('Only {count} left.', {'count': '${drug.maxQty}'}),
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              tooltip: context.tr('Decrease quantity'),
              onPressed: () => _setQty(drugId, qty - 1),
              icon: Icon(qty == 1 ? Icons.delete_outline : Icons.remove)),
          Text('$qty'),
          IconButton(
              tooltip: context.tr('Increase quantity'),
              onPressed: qty >= drug.maxQty ? null : () => _setQty(drugId, qty + 1),
              icon: const Icon(Icons.add)),
        ]));
  }
}
