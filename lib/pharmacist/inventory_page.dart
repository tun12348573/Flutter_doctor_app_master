import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_strings.dart';
import '../pharmacy/model/drug.dart';
import '../pharmacy/pharmacy_store.dart';
import '../pharmacy/pharmacy_widgets.dart';
import '../ui/app_widgets.dart';
import 'drug_form_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});
  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final _store = PharmacyStore();
  Map<String, Drug> _drugs = {};
  bool _isLoading = true;
  bool _failed = false;
  bool _lowOnly = false;
  String _query = '';

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
      final drugs = await _store.loadDrugs();
      if (mounted) setState(() => _drugs = drugs);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// [restock] adds to stock; otherwise sets the exact count.
  Future<void> _changeStock(Drug drug, {required bool restock}) async {
    final controller = TextEditingController(text: restock ? '' : '${drug.stock}');
    final amount = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(context.tr(restock ? 'Restock' : 'Set stock')),
              content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(drug.name),
                Text(context.tr('In stock: {count}', {'count': '${drug.stock}'})),
                const SizedBox(height: 12),
                TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                        labelText: context.tr(restock ? 'Quantity received' : 'Exact stock'))),
              ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.tr('Cancel'))),
                FilledButton(
                    onPressed: () => Navigator.pop(context, int.tryParse(controller.text)),
                    child: Text(context.tr('Save'))),
              ],
            ));
    controller.dispose();
    if (amount == null || (restock && amount == 0) || !mounted) return;
    try {
      if (restock) {
        if (!await _store.restock(drug.id, amount)) throw StateError('restock');
      } else {
        await _store.setStock(drug.id, amount);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.tr('Unable to save. Please try again.'))));
      }
    }
    await _fetch();
  }

  Future<void> _edit([Drug? drug]) async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => DrugFormPage(store: _store, drug: drug)));
    if (saved == true) await _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final drugs = _drugs.values
        .where((d) => d.matches(_query) && (!_lowOnly || d.isLow))
        .toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));
    final lowCount = _drugs.values.where((d) => d.isLow).length;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Inventory')), actions: [
        const LanguageButton(),
        IconButton(
            tooltip: context.tr('Refresh medicines'),
            onPressed: _isLoading ? null : _fetch,
            icon: const Icon(Icons.refresh)),
      ]),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: _isLoading ? null : () => _edit(),
          icon: const Icon(Icons.add),
          label: Text(context.tr('Add medicine'))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _failed
              ? AppStatus(
                  icon: Icons.wifi_off_outlined,
                  title: context.tr('Unable to load medicines'),
                  message: context.tr('Check your connection and try again.'),
                  onRetry: _fetch)
              : ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 96), children: [
                  TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          labelText: context.tr('Search by name or ingredient'))),
                  const SizedBox(height: 12),
                  FilterChip(
                      label: Text(context.tr('Low stock ({count})', {'count': '$lowCount'})),
                      selected: _lowOnly,
                      onSelected: (value) => setState(() => _lowOnly = value)),
                  const SizedBox(height: 12),
                  for (final drug in drugs)
                    DrugTile(
                        drug: drug,
                        onTap: () => _edit(drug),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${formatVnd(drug.price)} · ${context.tr(drug.category)}'),
                          const SizedBox(height: 4),
                          Wrap(spacing: 8, runSpacing: 4, children: [
                            Text(context.tr('In stock: {count}', {'count': '${drug.stock}'}),
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            ...drugTags(drug, forPharmacist: true),
                          ]),
                        ]),
                        trailing: PopupMenuButton<bool>(
                            tooltip: context.tr('Stock actions'),
                            onSelected: (restock) => _changeStock(drug, restock: restock),
                            itemBuilder: (context) => [
                                  PopupMenuItem(value: true, child: Text(context.tr('Restock'))),
                                  PopupMenuItem(value: false, child: Text(context.tr('Set stock'))),
                                ])),
                ]),
    );
  }
}
