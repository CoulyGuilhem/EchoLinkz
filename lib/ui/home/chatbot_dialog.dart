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
  @override
  void initState() {
    _input = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ChatbotViewModel>(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 350,
        height: 500,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: const Text('Chatbot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: vm.messages.length,
                itemBuilder: (_, i) {
                  final m = vm.messages[i];
                  return Align(
                    alignment: m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: m.fromUser
                            ? Theme.of(context).colorScheme.primary.withOpacity(.1)
                            : Theme.of(context).colorScheme.tertiary.withOpacity(.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(m.text),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      onSubmitted: (_) {
                        vm.send(_input.text);
                        _input.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: vm.sending ? const CircularProgressIndicator() : const Icon(Icons.send),
                    onPressed: vm.sending
                        ? null
                        : () {
                            vm.send(_input.text);
                            _input.clear();
                          },
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
