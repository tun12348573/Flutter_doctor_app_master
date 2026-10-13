import 'drug.dart';

class OrderItem {
  const OrderItem({required this.name, required this.price, required this.qty});
  final String name;
  final int price;
  final int qty;
  int get subtotal => price * qty;

  factory OrderItem.fromMap(Map data) => OrderItem(
        name: '${data['name'] ?? ''}',
        price: (data['price'] as num?)?.toInt() ?? 0,
        qty: (data['qty'] as num?)?.toInt() ?? 0,
      );

  Map<String, Object> toMap() => {'name': name, 'price': price, 'qty': qty};
}

class DrugOrder {
  const DrugOrder({
    required this.id,
    required this.uid,
    required this.name,
    required this.phone,
    required this.address,
    required this.items,
    required this.status,
    this.note = '',
    this.stockDeducted = false,
    this.createdAt = 0,
  });

  /// Stored status → English label (translated with context.tr()).
  static const statusLabels = {
    'pending': 'Awaiting confirmation',
    'shipping': 'Shipping',
    'delivered': 'Delivered',
    'cancelled': 'Cancelled',
  };

  final String id;
  final String uid;
  final String name;
  final String phone;
  final String address;
  final String note;
  final Map<String, OrderItem> items;
  final String status;
  final bool stockDeducted;
  final int createdAt;

  int get total => items.values.fold(0, (sum, item) => sum + item.subtotal);
  String get statusLabel => statusLabels[status] ?? status;

  factory DrugOrder.fromMap(Map data, String key) => DrugOrder(
        id: key,
        uid: '${data['uid'] ?? ''}',
        name: '${data['name'] ?? ''}',
        phone: '${data['phone'] ?? ''}',
        address: '${data['address'] ?? ''}',
        note: '${data['note'] ?? ''}',
        items: {
          for (final entry in ((data['items'] as Map?) ?? const {}).entries)
            '${entry.key}': OrderItem.fromMap(entry.value as Map)
        },
        status: '${data['status'] ?? 'pending'}',
        stockDeducted: data['stockDeducted'] == true,
        createdAt: (data['createdAt'] as num?)?.toInt() ?? 0,
      );
}

/// Why the cart cannot be checked out as-is, or null when it can.
/// Prices and names always come from the current catalog, never the cart.
String? cartProblem(Map<String, int> cart, Map<String, Drug> drugs) {
  if (cart.isEmpty) return 'Your cart is empty.';
  for (final entry in cart.entries) {
    final drug = drugs[entry.key];
    if (drug == null || !drug.canBuy || entry.value > drug.maxQty) {
      return 'Some items are unavailable. Update your cart and try again.';
    }
  }
  return null;
}

Map<String, OrderItem> orderItems(Map<String, int> cart, Map<String, Drug> drugs) => {
      for (final entry in cart.entries)
        entry.key: OrderItem(
            name: drugs[entry.key]!.name,
            price: drugs[entry.key]!.price,
            qty: entry.value)
    };
