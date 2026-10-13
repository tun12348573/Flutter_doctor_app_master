import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../ai/ai_chat_page.dart';
import '../ai/ai_chat_session.dart';
import '../doctor/doctor_list_page.dart';
import '../l10n/app_strings.dart';
import '../ui/app_widgets.dart';
import 'cart_page.dart';
import 'drug_details_page.dart';
import 'model/drug.dart';
import 'pharmacy_store.dart';
import 'pharmacy_widgets.dart';

class PharmacyPage extends StatefulWidget {
  const PharmacyPage({super.key, required this.ai});
  final AiChatSession ai;
  @override
  State<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends State<PharmacyPage> {
  final _store = PharmacyStore();
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  late final Stream<Map<String, int>> _cart = _store.cart(_uid).asBroadcastStream();
  Map<String, Drug> _drugs = {};
  bool _isLoading = true;
  bool _failed = false;
  String _category = 'All';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _fetchDrugs();
  }

  Future<void> _fetchDrugs() async {
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

  void _openCart() => Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CartPage(store: _store, uid: _uid)));

  Future<void> _addToCart(BuildContext pageContext, Drug drug) async {
    final messenger = ScaffoldMessenger.of(pageContext);
    try {
      final qty = await _store.addToCart(_uid, drug);
      if (!pageContext.mounted) return;
      messenger.showSnackBar(SnackBar(
          content: Text(pageContext.tr('In your cart: {qty}', {'qty': '$qty'})),
          action: SnackBarAction(
              label: pageContext.tr('View cart'), onPressed: _openCart)));
    } catch (_) {
      if (pageContext.mounted) {
        messenger.showSnackBar(SnackBar(
            content: Text(pageContext.tr('Unable to update your cart. Please try again.'))));
      }
    }
  }

  void _openDrug(Drug drug) => Navigator.of(context).push(MaterialPageRoute(
      builder: (pageContext) => DrugDetailsPage(
            drug: drug,
            onAddToCart: () => _addToCart(pageContext, drug),
            onAskAi: () {
              widget.ai.askAbout(drug.id, drug.name,
                  pageContext.tr('What should I know about {name}?', {'name': drug.name}));
              Navigator.of(pageContext).push(MaterialPageRoute(
                  builder: (_) => AiChatPage(session: widget.ai)));
            },
            onBookVisit: () => Navigator.of(pageContext).push(
                MaterialPageRoute(builder: (_) => const DoctorListPage())),
          )));

  @override
  Widget build(BuildContext context) {
    final drugs = _drugs.values
        .where((d) =>
            (_category == 'All' || d.category == _category) && d.matches(_query))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Pharmacy')), actions: [
        const LanguageButton(),
        StreamBuilder<Map<String, int>>(
            stream: _cart,
            builder: (context, snapshot) {
              final count =
                  (snapshot.data ?? const {}).values.fold(0, (a, b) => a + b);
              return IconButton(
                  tooltip: context.tr('Cart'),
                  onPressed: _openCart,
                  icon: Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      child: const Icon(Icons.shopping_cart_outlined)));
            }),
        IconButton(
            tooltip: context.tr('Refresh medicines'),
            onPressed: _isLoading ? null : _fetchDrugs,
            icon: const Icon(Icons.refresh)),
      ]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _failed
              ? AppStatus(
                  icon: Icons.wifi_off_outlined,
                  title: context.tr('Unable to load medicines'),
                  message: context.tr('Check your connection and try again.'),
                  onRetry: _fetchDrugs)
              : ListView(padding: const EdgeInsets.all(24), children: [
                  TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          labelText: context.tr('Search by name or ingredient'))),
                  const SizedBox(height: 16),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final category in ['All', ...drugCategories.keys])
                      ChoiceChip(
                          label: Text(context.tr(category)),
                          selected: _category == category,
                          onSelected: (_) => setState(() => _category = category)),
                  ]),
                  const SizedBox(height: 16),
                  const DemoDataNotice(),
                  const SizedBox(height: 8),
                  if (drugs.isEmpty)
                    AppStatus(
                        icon: Icons.medication_outlined,
                        title: context.tr('No medicines found'),
                        message: context.tr('Try another name or category.'))
                  else
                    for (final drug in drugs)
                      DrugTile(drug: drug, onTap: () => _openDrug(drug)),
                ]),
    );
  }
}
