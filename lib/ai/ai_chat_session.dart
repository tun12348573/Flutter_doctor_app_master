import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiMessage {
  const AiMessage(this.role, this.content);
  final String role;
  final String content;
  Map<String, String> toJson() => {'role': role, 'content': content};
}

/// Owned by the patient home: retains conversation across tabs, never saves it.
class AiChatSession extends ChangeNotifier {
  AiChatSession({
    this.endpoint = const String.fromEnvironment('AI_CHAT_URL'),
    http.Client? client,
    Future<String?> Function()? tokenProvider,
  })  : _client = client ?? http.Client(),
        _tokenProvider = tokenProvider ??
            (() async => FirebaseAuth.instance.currentUser?.getIdToken());

  final String endpoint;
  final http.Client _client;
  final Future<String?> Function() _tokenProvider;
  final _messages = <AiMessage>[];
  List<AiMessage> get messages => List.unmodifiable(_messages);
  bool sending = false;
  String draft = '';
  String? error;

  /// Catalog medicine the conversation is about; n8n loads its details by id.
  ({String id, String name})? drug;
  bool _disposed = false;

  bool get configured {
    final uri = Uri.tryParse(endpoint);
    return uri != null &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'https' ||
            (uri.scheme == 'http' &&
                ['localhost', '127.0.0.1'].contains(uri.host)));
  }

  Future<bool> send(String input, String language) async {
    if (sending || _disposed) return false;
    draft = input;
    final text = input.trim();
    if (!configured || text.isEmpty || text.length > 2000) {
      error = !configured
          ? 'AI assistant is not configured yet.'
          : 'Enter a question of up to 2,000 characters.';
      notifyListeners();
      return false;
    }
    sending = true;
    error = null;
    notifyListeners();
    try {
      final token = await _tokenProvider().timeout(const Duration(seconds: 15));
      if (_disposed) return false;
      if (token == null) {
        error = 'Please sign in again to use the AI assistant.';
        return false;
      }
      final response = await _client
          .post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: jsonEncode({
              'message': text,
              'language': language == 'vi' ? 'vi' : 'en',
          'history': _history(),
              if (drug != null) 'drugId': drug!.id,
            }),
          )
          .timeout(const Duration(seconds: 120));
      if (_disposed) return false;
      if (response.statusCode == 401 || response.statusCode == 403) {
        error = 'Please sign in again to use the AI assistant.';
        return false;
      }
      if (response.statusCode == 429) {
        error = 'Too many questions. Please try again later.';
        return false;
      }
      if (response.statusCode != 200) throw const FormatException();
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      final reply = body is Map ? body['reply'] : null;
      if (reply is! String || reply.trim().isEmpty) {
        throw const FormatException();
      }
      _messages.addAll(
          [AiMessage('user', text), AiMessage('assistant', reply.trim())]);
      draft = '';
      return true;
    } on TimeoutException {
      error = 'The AI took too long. Please try again.';
      return false;
    } catch (_) {
      if (!_disposed) {
        error = 'Unable to reach the AI assistant. Please try again.';
      }
      return false;
    } finally {
      sending = false;
      if (!_disposed) notifyListeners();
    }
  }

  void askAbout(String id, String name, String question) {
    if (sending) return;
    drug = (id: id, name: name);
    draft = question;
    error = null;
    notifyListeners();
  }

  void forgetDrug() {
    drug = null;
    notifyListeners();
  }

  void clear() {
    if (sending) return;
    _messages.clear();
    drug = null;
    draft = '';
    error = null;
    notifyListeners();
  }

  List<Map<String, String>> _history() {
    final history = <Map<String, String>>[];
    var characters = 0;
    // Keep complete recent exchanges within the webhook's context budget.
    for (var i = _messages.length - 2; i >= 0 && history.length < 10; i -= 2) {
      final pair = _messages.sublist(i, i + 2);
      final size = pair[0].content.length + pair[1].content.length;
      if (pair.any((m) => m.content.length > 8000) || characters + size > 24000) break;
      characters += size;
      history.insertAll(0, pair.map((m) => m.toJson()));
    }
    return history;
  }

  @override
  void dispose() {
    _disposed = true;
    _client.close();
    super.dispose();
  }
}
