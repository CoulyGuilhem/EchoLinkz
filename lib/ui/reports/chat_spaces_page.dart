// lib/ui/reports/chat_spaces_page.dart

import 'package:flutter/material.dart';
import 'package:echolinkz/ui/reports/chat_room_page.dart';
import 'package:echolinkz/ui/widgets/EchoLinkZ_appbar.dart';

class ChatSpacesPage extends StatelessWidget {
  const ChatSpacesPage({Key? key}) : super(key: key);

  static const List<String> spaces = [
    'Eau',
    'Secours',
    'Panne',
    'Abri',
    'Info',
    'Centre-ville',
    'Quartier Est',
    'Quartier Ouest',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoLinkZAppBar(title: 'Salons de discussion'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: spaces.map((space) {
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatRoomPage(room: space),
                  ),
                );
              },
              child: Text(space),
            );
          }).toList(),
        ),
      ),
    );
  }
}
