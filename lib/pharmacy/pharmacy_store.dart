import 'package:firebase_database/firebase_database.dart';
import 'model/drug.dart';
import 'model/drug_order.dart';

class OutOfStock implements Exception {
  const OutOfStock(this.drugName);
  final String drugName;
}

/// Realtime Database access for the pharmacy. Rules in database.rules.json
/// decide who may do what; this class only shapes the writes.
class PharmacyStore {
  PharmacyStore([FirebaseDatabase? database])
      : _db = database ?? FirebaseDatabase.instance;
  final FirebaseDatabase _db;

  Future<Map<String, Drug>> loadDrugs() async {
    final snapshot = await _db.ref('Drugs').get();
    return {
      for (final child in snapshot.children)
        child.key!: Drug.fromMap(child.value as Map, child.key!)
    };
  }

  Stream<Map<String, int>> cart(String uid) =>
      _db.ref('Carts/$uid').onValue.map((event) => {
            for (final child in event.snapshot.children)
              child.key!: (child.value as num).toInt()
          });

  Future<void> setCartQty(String uid, String drugId, int qty) {
    final ref = _db.ref('Carts/$uid/$drugId');
    return qty <= 0 ? ref.remove() : ref.set(qty);
  }

  Future<int> addToCart(String uid, Drug drug) async {
    final result = await _db.ref('Carts/$uid/${drug.id}').runTransaction((value) {
      final current = (value as num?)?.toInt() ?? 0;
      return Transaction.success(
          current + 1 > drug.maxQty ? drug.maxQty : current + 1);
    });
    return (result.snapshot.value as num?)?.toInt() ?? 0;
  }

  /// Writes the order and empties the cart in one atomic update.
  Future<void> placeOrder({
    required String uid,
    required Map<String, OrderItem> items,
    required String name,
    required String phone,
    required String address,
    required String note,
  }) {
    final id = _db.ref('Orders').push().key!;
    return _db.ref().update({
      'Orders/$id': {
        'id': id,
        'uid': uid,
        'name': name,
        'phone': phone,
        'address': address,
        if (note.isNotEmpty) 'note': note,
        'items': {for (final e in items.entries) e.key: e.value.toMap()},
        'status': 'pending',
        'stockDeducted': false,
        'createdAt': ServerValue.timestamp,
      },
      'Carts/$uid': null,
    });
  }

  Future<List<DrugOrder>> orders({String? uid}) async {
    final ref = _db.ref('Orders');
    final snapshot = await (uid == null
        ? ref.get()
        : ref.orderByChild('uid').equalTo(uid).get());
    return snapshot.children
        .map((child) => DrugOrder.fromMap(child.value as Map, child.key!))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> cancelPending(DrugOrder order) =>
      _db.ref('Orders/${order.id}/status').set('cancelled');

  /// Pharmacist confirms: takes stock for every item, then marks shipping.
  /// Throws [OutOfStock] and returns any stock already taken.
  Future<void> confirm(DrugOrder order) async {
    final taken = <String, int>{};
    try {
      for (final entry in order.items.entries) {
        if (!await _changeStock(entry.key, -entry.value.qty)) {
          throw OutOfStock(entry.value.name);
        }
        taken[entry.key] = entry.value.qty;
      }
      await _db
          .ref('Orders/${order.id}')
          .update({'status': 'shipping', 'stockDeducted': true});
    } catch (_) {
      // ponytail: best-effort rollback without Cloud Functions; a crash here can leave stock low.
      for (final entry in taken.entries) {
        await _changeStock(entry.key, entry.value);
      }
      rethrow;
    }
  }

  Future<void> markDelivered(DrugOrder order) =>
      _db.ref('Orders/${order.id}/status').set('delivered');

  /// Pharmacist cancels; stock taken at confirmation goes back.
  Future<void> cancel(DrugOrder order) async {
    if (order.stockDeducted) {
      for (final entry in order.items.entries) {
        await _changeStock(entry.key, entry.value.qty);
      }
    }
    await _db
        .ref('Orders/${order.id}')
        .update({'status': 'cancelled', 'stockDeducted': false});
  }

  Future<bool> restock(String drugId, int amount) =>
      _changeStock(drugId, amount);

  Future<void> setStock(String drugId, int stock) =>
      _db.ref('Drugs/$drugId/stock').set(stock);

  Future<void> saveDrug(Drug drug) => _db.ref('Drugs/${drug.id}').set(drug.toMap());

  String newDrugId() => _db.ref('Drugs').push().key!;

  /// Adds [delta] to stock atomically; false when it would go below zero.
  Future<bool> _changeStock(String drugId, int delta) async {
    final result =
        await _db.ref('Drugs/$drugId/stock').runTransaction((value) {
      // The first attempt may see null before the server value arrives;
      // writing null makes the server reject it and retry with real data.
      if (value == null) return Transaction.success(null);
      final next = (value as num).toInt() + delta;
      return next < 0 ? Transaction.abort() : Transaction.success(next);
    });
    return result.committed && result.snapshot.value != null;
  }
}
