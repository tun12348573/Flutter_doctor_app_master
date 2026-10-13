import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:practice/ai/ai_chat_page.dart';
import 'package:practice/ai/ai_chat_session.dart';
import 'package:practice/l10n/app_strings.dart';
import 'localization_test.dart' show localized, chooseLanguage;

void main() {
  tearDown(() => appLocale.value = null);
  test('Long conversations retain recent complete exchanges within server limits', () async {
    var calls = 0;
    final session = AiChatSession(endpoint: 'https://example.com/chat',
      tokenProvider: () async => 'test', client: MockClient((request) async {
        calls++;
        final history = jsonDecode(request.body)['history'] as List;
        expect(history.length, lessThanOrEqualTo(10));
        expect(history.length.isEven, isTrue);
        expect(history.fold<int>(0, (n, m) => n + (m['content'] as String).length), lessThanOrEqualTo(24000));
        return http.Response(jsonEncode({'reply': 'x' * 6000}), 200);
      }));
    for (var i = 0; i < 8; i++) {
      expect(await session.send('q' * 2000, 'vi'), isTrue);
    }
    expect(calls, 8);
    expect(session.messages.length, 16);
    session.dispose();
  });

  testWidgets('Draft survives leaving the AI page while a failed request is pending', (tester) async {
    final pending = Completer<http.Response>();
    final session = AiChatSession(endpoint: 'https://example.com/chat',
      tokenProvider: () async => 'test', client: MockClient((_) => pending.future));
    addTearDown(session.dispose);
    await tester.pumpWidget(localized(AiChatPage(session: session)));
    await tester.enterText(find.byType(TextField), 'Keep this question');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pump();
    await tester.pumpWidget(localized(const SizedBox()));
    pending.complete(http.Response('{}', 502));
    await tester.pumpAndSettle();
    await tester.pumpWidget(localized(AiChatPage(session: session)));
    expect(find.text('Keep this question'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Rate-limited request keeps the draft and explains why', () async {
    final session = AiChatSession(endpoint: 'https://example.com/chat',
      tokenProvider: () async => 'test',
      client: MockClient((_) async => http.Response('{"error":"rate_limited"}', 429)));
    expect(await session.send('Hello', 'en'), isFalse);
    expect(session.error, 'Too many questions. Please try again later.');
    expect(session.draft, 'Hello');
    expect(session.messages, isEmpty);
    session.dispose();
  });

  test('AI requires a safe endpoint and authentication before sending',
      () async {
    var requests = 0;
    final client = MockClient((_) async {
      requests++;
      return http.Response('{}', 200);
    });
    final absent =
        AiChatSession(endpoint: 'http://remote.example/chat', client: client);
    expect(absent.configured, isFalse);
    expect(await absent.send('Hello', 'en'), isFalse);
    absent.dispose();
    final session = AiChatSession(
        endpoint: 'http://localhost:5678/webhook/doctorapp-ai',
        client: client,
        tokenProvider: () async => null);
    expect(await session.send('Hello', 'en'), isFalse);
    expect(requests, 0);
    session.dispose();
  });

  test(
      'AI sends token and history, rejects duplicate requests and allows retry',
      () async {
    final pending = Completer<http.Response>();
    var calls = 0;
    final session = AiChatSession(
        endpoint: 'https://example.com/chat',
        tokenProvider: () async => 'test-token',
        client: MockClient((request) async {
          calls++;
          expect(request.headers['Authorization'], 'Bearer test-token');
          final body = jsonDecode(request.body);
          expect(body['language'], 'vi');
          if (calls == 1) return pending.future;
          if (calls == 2) return http.Response('unavailable', 503);
          expect(body['history'].length, 2);
          return http.Response(jsonEncode({'reply': 'Second reply'}), 200);
        }));
    final first = session.send('First question', 'vi');
    expect(await session.send('Duplicate', 'vi'), isFalse);
    pending.complete(http.Response(jsonEncode({'reply': 'First reply'}), 200));
    expect(await first, isTrue);
    expect(await session.send('Second question', 'vi'), isFalse);
    expect(session.messages.length, 2);
    expect(await session.send('Second question', 'vi'), isTrue);
    expect(session.messages.length, 4);
    session.clear();
    expect(session.messages, isEmpty);
    session.dispose();
  });

  testWidgets('AI keeps failed question, supports Vietnamese and narrow layout',
      (tester) async {
    appLocale.value = const Locale('en');
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final session = AiChatSession(
        endpoint: 'http://localhost:5678/webhook/doctorapp-ai',
        tokenProvider: () async => 'test',
        client: MockClient((_) async => http.Response('{}', 502)));
    addTearDown(session.dispose);
    await tester.pumpWidget(localized(AiChatPage(session: session)));
    await tester.enterText(find.byType(TextField), 'My question');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(find.text('My question'), findsOneWidget);
    expect(find.text('Unable to reach the AI assistant. Please try again.'),
        findsOneWidget);
    await chooseLanguage(tester, 'Tiếng Việt');
    expect(find.text('Trợ lý AI'), findsOneWidget);
    expect(find.text('My question'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
