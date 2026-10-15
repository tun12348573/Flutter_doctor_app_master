import 'package:practice/l10n/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'ui/app_widgets.dart';

/// Conversation node under `Chat`: both uids in code-unit order, so either side gets the same id.
String chatId(String a, String b) => a.compareTo(b) < 0 ? '${a}_$b' : '${b}_$a';

class ChatScreen extends StatefulWidget {
  final String? doctorId;
  final String? doctorName;
  final String? patientId;
  final String? patientName;
  const ChatScreen(
      {super.key,
      this.doctorId,
      this.doctorName,
      this.patientId,
      this.patientName});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final String _uid;
  late final String _partnerId;
  late final DatabaseReference _chat;
  late Stream<DatabaseEvent> _messages;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _partnerId = _uid == widget.doctorId ? widget.patientId! : widget.doctorId!;
    _chat = FirebaseDatabase.instance.ref('Chat/${chatId(_uid, _partnerId)}');
    _messages = _chat.onValue;
  }

  Future<void> _send(String message) async {
    final root = FirebaseDatabase.instance.ref();
    final id = _chat.push().key!;
    await root.update({
      '${_chat.path}/$id': {
        'message': message,
        'receiver': _partnerId,
        'sender': _uid,
        'timestamp': DateTime.now().toIso8601String()
      },
      'ChatList/$_uid/$_partnerId': {'id': _partnerId},
      'ChatList/$_partnerId/$_uid': {'id': _uid},
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text((_uid == widget.doctorId
                    ? widget.patientName
                    : widget.doctorName) ??
                context.tr('Conversation')),
            actions: const [LanguageButton()]),
        body: SafeArea(
            child: ContentWidth(
                maxWidth: 880,
                child: Column(children: [
                  Expanded(
                      child: StreamBuilder<DatabaseEvent>(
                          stream: _messages,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return AppStatus(
                                  icon: Icons.wifi_off_outlined,
                                  title: context.tr('Unable to load messages'),
                                  message: context.tr(
                                      'Check your connection and try again.'),
                                  onRetry: () => setState(
                                      () => _messages = _chat.onValue));
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final messages = <Map>[];
                            for (final item
                                in snapshot.data?.snapshot.children ??
                                    <DataSnapshot>[]) {
                              final value = item.value;
                              if (value is Map) messages.add(value);
                            }
                            messages.sort((a, b) => b['timestamp']
                                .toString()
                                .compareTo(a['timestamp'].toString()));
                            if (messages.isEmpty) {
                              return AppStatus(
                                  icon: Icons.chat_bubble_outline,
                                  title: context.tr('Start a conversation'),
                                  message: context.tr(
                                      'Send a message to introduce yourself.'));
                            }
                            return ListView.builder(
                                reverse: true,
                                padding: const EdgeInsets.all(20),
                                itemCount: messages.length,
                                itemBuilder: (context, i) {
                                  final mine = messages[i]['sender'] == _uid;
                                  return Align(
                                      alignment: mine
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                          widthFactor: .85,
                                          child: Align(
                                            alignment: mine
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 12),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                              decoration: BoxDecoration(
                                                  color: mine
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .primaryContainer
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .surface,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16)),
                                              child: Text(
                                                  messages[i]['message']
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: mine
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .onPrimaryContainer
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .onSurface)),
                                            ),
                                          )));
                                });
                          })),
                  MessageComposer(onSend: _send),
                ]))),
      );
}

class MessageComposer extends StatefulWidget {
  const MessageComposer({super.key, required this.onSend});
  final Future<void> Function(String) onSend;
  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final _controller = TextEditingController();
  bool _sending = false;
  String? _error;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (_sending || text.isEmpty) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.onSend(text);
      if (mounted) _controller.clear();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Message not sent. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (_error != null)
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Semantics(
                    liveRegion: true,
                    child: Text(context.tr(_error!),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)))),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
                child: TextField(
                    controller: _controller,
                    enabled: !_sending,
                    minLines: 1,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        labelText: context.tr('Message'),
                        hintText: context.tr('Write your message...')))),
            const SizedBox(width: 8),
            IconButton.filled(
                tooltip: _sending
                    ? context.tr('Sending message')
                    : context.tr('Send message'),
                onPressed: _sending ? null : _send,
                icon:
                    Icon(_sending ? Icons.hourglass_top : Icons.send_outlined)),
          ]),
        ]),
      );
}
