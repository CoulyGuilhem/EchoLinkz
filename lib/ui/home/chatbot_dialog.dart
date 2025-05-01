import 'package:echolinkz/ui/home/chatbot_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatbotDialog extends StatefulWidget {
  const ChatbotDialog({super.key});
  @override
  State<ChatbotDialog> createState() => _ChatbotDialogState();
}

class _ChatbotDialogState extends State<ChatbotDialog> {
  late final TextEditingController _input;
  final _scroll = ScrollController();

  @override
  void initState() {
    _input = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _input.dispose();
    super.dispose();
  }

  void _submit(ChatbotViewModel vm) {
    if (_input.text.trim().isEmpty) return;
    vm.send(_input.text.trim());
    _input.clear();
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final vm = Provider.of<ChatbotViewModel>(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: cs.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 380,
        height: 520,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: Text('Echo-Bot',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: Container(
                color: cs.surface,
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.messages.length,
                  itemBuilder: (_, i) {
                    final m = vm.messages[i];
                    final bubbleColor =
                        m.fromUser ? cs.primary : cs.secondary;
                    final textColor =
                        m.fromUser ? cs.onPrimary : cs.onSecondary;
                    final align =
                        m.fromUser ? Alignment.centerRight : Alignment.centerLeft;
                    return Align(
                      alignment: align,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(m.text, style: TextStyle(color: textColor)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
              decoration: BoxDecoration(
                color: cs.surfaceVariant,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Votre message…',
                        filled: true,
                        fillColor: cs.surface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: cs.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (_) => _submit(vm),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: vm.sending
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(Icons.send, color: cs.primary),
                    onPressed: vm.sending ? null : () => _submit(vm),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
