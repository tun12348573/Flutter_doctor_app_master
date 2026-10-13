import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_strings.dart';
import '../pharmacy/model/drug.dart';
import '../pharmacy/pharmacy_store.dart';
import '../ui/app_widgets.dart';

/// Adds a medicine or edits its details. Stock is changed from the inventory list.
class DrugFormPage extends StatefulWidget {
  const DrugFormPage({super.key, required this.store, this.drug});
  final PharmacyStore store;
  final Drug? drug;
  @override
  State<DrugFormPage> createState() => _DrugFormPageState();
}

class _DrugFormPageState extends State<DrugFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _fields = {
    for (final entry in {
      'name': widget.drug?.name,
      'ingredient': widget.drug?.ingredient,
      'strength': widget.drug?.strength,
      'form': widget.drug?.form,
      'pack': widget.drug?.pack,
      'price': widget.drug?.price.toString(),
      'stock': widget.drug?.stock.toString(),
      'uses': widget.drug?.uses,
      'dosage': widget.drug?.dosage,
      'contraindications': widget.drug?.contraindications,
      'sideEffects': widget.drug?.sideEffects,
    }.entries)
      entry.key: TextEditingController(text: entry.value ?? '')
  };
  late String _category = widget.drug?.category ?? drugCategories.keys.first;
  late bool _prescription = widget.drug?.prescription ?? false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    String text(String key) => _fields[key]!.text.trim();
    try {
      await widget.store.saveDrug(Drug(
        id: widget.drug?.id ?? widget.store.newDrugId(),
        name: text('name'),
        ingredient: text('ingredient'),
        category: _category,
        price: int.parse(text('price')),
        // Editing keeps the live stock; only new medicines take it from the form.
        stock: widget.drug?.stock ?? int.parse(text('stock')),
        prescription: _prescription,
        strength: text('strength'),
        form: text('form'),
        pack: text('pack'),
        uses: text('uses'),
        dosage: text('dosage'),
        contraindications: text('contraindications'),
        sideEffects: text('sideEffects'),
      ));
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to save. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(String key, String label,
      {bool required = false, bool number = false, int lines = 1}) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
            controller: _fields[key],
            minLines: lines,
            maxLines: lines == 1 ? 1 : lines + 3,
            keyboardType: number ? TextInputType.number : null,
            inputFormatters: number ? [FilteringTextInputFormatter.digitsOnly] : null,
            decoration: InputDecoration(labelText: context.tr(label)),
            validator: (value) => required && (value ?? '').trim().isEmpty
                ? context.tr('This field is required.')
                : null));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(context.tr(widget.drug == null ? 'Add medicine' : 'Edit medicine')),
            actions: const [LanguageButton()]),
        body: ContentWidth(
            maxWidth: 720,
            child: Form(
                key: _formKey,
                child: ListView(padding: const EdgeInsets.all(24), children: [
                  _field('name', 'Medicine name', required: true),
                  _field('ingredient', 'Active ingredient', required: true),
                  _field('strength', 'Strength'),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: InputDecoration(labelText: context.tr('Category')),
                          items: [
                            for (final category in drugCategories.keys)
                              DropdownMenuItem(value: category, child: Text(context.tr(category)))
                          ],
                          onChanged: (value) => setState(() => _category = value!))),
                  _field('form', 'Dosage form'),
                  _field('pack', 'Pack size'),
                  _field('price', 'Price (VND)', required: true, number: true),
                  if (widget.drug == null)
                    _field('stock', 'Initial stock', required: true, number: true),
                  SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.tr('Prescription only')),
                      value: _prescription,
                      onChanged: (value) => setState(() => _prescription = value)),
                  _field('uses', 'Uses', lines: 2),
                  _field('dosage', 'How to use', lines: 2),
                  _field('contraindications', 'Contraindications', lines: 2),
                  _field('sideEffects', 'Side effects', lines: 2),
                  if (_error != null)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(context.tr(_error!),
                            style: TextStyle(color: Theme.of(context).colorScheme.error))),
                  FilledButton(
                      onPressed: _saving ? null : _save,
                      child: Text(context.tr(_saving ? 'Saving...' : 'Save'))),
                ]))),
      );
}
