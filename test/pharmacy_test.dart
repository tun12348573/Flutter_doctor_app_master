import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:practice/ai/ai_chat_session.dart';
import 'package:practice/l10n/app_strings.dart';
import 'package:practice/pharmacy/drug_details_page.dart';
import 'package:practice/pharmacy/model/drug.dart';
import 'package:practice/pharmacy/model/drug_order.dart';
import 'localization_test.dart' show localized;

const otc = Drug(id: 'para', name: 'Paracetamol 500mg', ingredient: 'Paracetamol', category: 'Pain & fever', price: 25000, stock: 3);
const rx = Drug(id: 'amox', name: 'Amoxicillin 500mg', ingredient: 'Amoxicillin', category: 'Antibiotics', price: 80000, stock: 50, prescription: true);
const empty = Drug(id: 'gone', name: 'Lozenge', ingredient: 'x', category: 'Cough & cold', price: 1000, stock: 0);

void main() {
  setUp(() => appLocale.value = const Locale('en'));
  tearDown(() => appLocale.value = null);

  test('Catalog entries parse defensively and match name or ingredient', () {
    final drug = Drug.fromMap({'name': 'Vitamin C', 'ingredient': 'Acid ascorbic', 'price': 5e4, 'stock': 2}, 'vit');
    expect(drug.price, 50000);
    expect(drug.isLow, isTrue);
    expect(drug.prescription, isFalse);
    expect(drug.matches('ascorbic'), isTrue);
    expect(drug.matches('para'), isFalse);
    expect(formatVnd(1250000), '1.250.000 ₫');
  });

  test('Checkout blocks prescription, missing and over-stock items and uses catalog prices', () {
    final drugs = {for (final d in [otc, rx, empty]) d.id: d};
    expect(cartProblem({}, drugs), 'Your cart is empty.');
    expect(cartProblem({'amox': 1}, drugs), isNotNull);
    expect(cartProblem({'gone': 1}, drugs), isNotNull);
    expect(cartProblem({'deleted': 1}, drugs), isNotNull);
    expect(cartProblem({'para': 4}, drugs), isNotNull);
    expect(cartProblem({'para': 3}, drugs), isNull);
    final items = orderItems({'para': 2}, drugs);
    expect(items['para']!.price, 25000);
    final order = DrugOrder(id: 'o1', uid: 'u', name: 'An', phone: '0900', address: 'HN', items: items, status: 'shipping');
    expect(order.total, 50000);
    expect(order.statusLabel, 'Shipping');
  });

  test('Orders read from the database tolerate missing fields', () {
    final order = DrugOrder.fromMap({'items': {'para': {'name': 'P', 'price': 10, 'qty': 3}}}, 'abc');
    expect(order.status, 'pending');
    expect(order.total, 30);
    expect(order.stockDeducted, isFalse);
  });

  testWidgets('Buyable medicine can be added to cart and discussed with AI', (tester) async {
    var added = 0, asked = 0;
    await tester.pumpWidget(localized(DrugDetailsPage(drug: otc, onAddToCart: () => added++, onAskAi: () => asked++)));
    await tester.tap(find.text('Add to cart'));
    await tester.tap(find.text('Ask AI about this medicine'));
    expect((added, asked), (1, 1));
    expect(find.text('25.000 ₫'), findsOneWidget);
    expect(find.textContaining('Demo data'), findsOneWidget);
  });

  testWidgets('Prescription medicine cannot be bought and points to a doctor visit', (tester) async {
    var booked = 0;
    await tester.pumpWidget(localized(DrugDetailsPage(drug: rx, onAddToCart: () => fail('must not add'), onBookVisit: () => booked++)));
    expect(find.text('Add to cart'), findsNothing);
    expect(find.text('Prescription required'), findsOneWidget);
    await tester.tap(find.text('Book an appointment'));
    expect(booked, 1);
  });

  testWidgets('Out-of-stock medicine shows a disabled button in Vietnamese', (tester) async {
    appLocale.value = const Locale('vi');
    await tester.pumpWidget(localized(DrugDetailsPage(drug: empty, onAddToCart: () => fail('must not add'))));
    final button = tester.widget<ButtonStyleButton>(find.ancestor(of: find.text('Hết hàng').last, matching: find.byWidgetPredicate((w) => w is ButtonStyleButton)));
    expect(button.onPressed, isNull);
    expect(find.text('Ho, cảm'), findsOneWidget);
  });

  test('AI session sends the selected medicine until the user drops it', () async {
    final bodies = <Map>[];
    final session = AiChatSession(
        endpoint: 'https://example.com/chat',
        tokenProvider: () async => 'test',
        client: MockClient((request) async {
          bodies.add(jsonDecode(request.body) as Map);
          return http.Response(jsonEncode({'reply': 'ok'}), 200);
        }));
    session.askAbout('para', 'Paracetamol', 'What should I know?');
    expect(session.draft, 'What should I know?');
    await session.send(session.draft, 'en');
    await session.send('And for children?', 'en');
    session.forgetDrug();
    await session.send('Thanks', 'en');
    expect(bodies.map((b) => b['drugId']).toList(), ['para', 'para', null]);
    session.askAbout('para', 'Paracetamol', 'Again');
    session.clear();
    expect(session.drug, isNull);
    session.dispose();
  });
}
