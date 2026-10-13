import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../ui/app_widgets.dart';
import 'ai_chat_session.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key, required this.session});
  final AiChatSession session;
  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final sent = await widget.session
        .send(_input.text, Localizations.localeOf(context).languageCode);
    if (sent && mounted) _input.clear();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: widget.session,
        builder: (context, _) {
          final session = widget.session;
          if (_input.text != session.draft) {
            _input.value = TextEditingValue(text: session.draft,
                selection: TextSelection.collapsed(offset: session.draft.length));
          }
          return Scaffold(
            appBar: AppBar(title: Text(context.tr('AI assistant')), actions: [
              IconButton(
                tooltip: context.tr('New conversation'),
                onPressed: session.sending || session.messages.isEmpty
                    ? null
                    : () async {
                        final clear = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text(
                                      context.tr('Clear this conversation?')),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(context.tr('Cancel'))),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(context.tr('Clear'))),
                                  ],
                                ));
                        if (clear == true && mounted) session.clear();
                      },
                icon: const Icon(Icons.add_comment_outlined),
              ),
              const LanguageButton(),
            ]),
            body: SafeArea(
                child: ContentWidth(
                    maxWidth: 880,
                    child: Column(children: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                          child: Text(context.tr(
                              'AI can make mistakes. For general information, not diagnosis or prescriptions. For emergencies, contact local emergency services.'))),
                      Expanded(
                          child: !session.configured
                              ? AppStatus(
                                  icon: Icons.settings_outlined,
                                  title: context.tr(
                                      'AI assistant is not configured yet.'),
                                  message: context.tr(
                                      'Please contact the app administrator.'))
                              : session.messages.isEmpty && !session.sending
                                  ? AppStatus(
                                      icon: Icons.auto_awesome_outlined,
                                      title: context.tr('How can I help?'),
                                      message: context.tr(
                                          'Ask about general health or preparing for a visit. Avoid sharing identifying information.'))
                                  : ListView.builder(
                                      reverse: true,
                                      padding: const EdgeInsets.all(20),
                                      itemCount: session.messages.length +
                                          (session.sending ? 1 : 0),
                                      itemBuilder: (context, index) {
                                        if (session.sending && index == 0) {
                                          return Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Semantics(
                                                  liveRegion: true,
                                                  child: Text(context.tr(
                                                      'AI is preparing a reply...'))));
                                        }
                                        final message = session.messages[
                                            session.messages.length -
                                                1 -
                                                index +
                                                (session.sending ? 1 : 0)];
                                        final mine = message.role == 'user';
                                        return Align(
                                            alignment: mine
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            child: Card(
                                              color: mine
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primaryContainer
                                                  : null,
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                          context.tr(mine
                                                              ? 'You'
                                                              : 'AI assistant'),
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .labelLarge),
                                                      const SizedBox(height: 8),
                                                      SelectableText(
                                                          message.content),
                                                    ],
                                                  )),
                                            ));
                                      },
                                    )),
                      if (session.error != null)
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            child: Semantics(
                                liveRegion: true,
                                child: Text(context.tr(session.error!),
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error)))),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: TextField(
                                  controller: _input,
                              onChanged: (value) => session.draft = value,
                                  enabled:
                                      session.configured && !session.sending,
                                  minLines: 1,
                                  maxLines: 4,
                                  maxLength: 2000,
                                  decoration: InputDecoration(
                                      labelText: context.tr('Your question')),
                                )),
                                const SizedBox(width: 8),
                                IconButton.filled(
                                    tooltip: context.tr('Send message'),
                                    onPressed:
                                        !session.configured || session.sending
                                            ? null
                                            : _send,
                                    icon: Icon(session.sending
                                        ? Icons.hourglass_top
                                        : Icons.send_outlined)),
                              ])),
                    ]))),
          );
        },
      );
}
