import 'package:flutter/material.dart';
import 'package:echolinkz/ui/reports/chat_room_page.dart';
import 'package:echolinkz/ui/widgets/echolinkz_appbar.dart';

class ChatSpacesPage extends StatelessWidget {
  const ChatSpacesPage({super.key});

  static const _incidents = ['Eau', 'Secours', 'Panne', 'Abri', 'Info'];
  static const _areas = [
    'Grenoble centre',
    'Échirolles',
    'Saint‑Martin‑d’Hères',
    'Fontaine',
    'Seyssinet‑Pariset',
    'Seyssins',
    'Saint‑Égrève',
    'Meylan',
    'La Tronche',
    'Le Pont‑de‑Claix',
    'Sassenage',
    'Gières',
    'Domène',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const EchoLinkZAppBar(
        title: 'Choisissez un salon pour échanger',
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: ListView(
          children: [
            _CategoryCard(
              title: 'Types d’incident',
              icon: Icons.warning_amber,
              chips: _incidents,
              cs: cs,
            ),
            const SizedBox(height: 24),
            _CategoryCard(
              title: 'Zones géographiques',
              icon: Icons.location_on_outlined,
              chips: _areas,
              cs: cs,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.chips,
    required this.cs,
  });

  final String title;
  final IconData icon;
  final List<String> chips;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 26, color: cs.primary),
                const SizedBox(width: 10),
                Text(title,
                    style: th.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (_, cts) {
                final colCount = (cts.maxWidth / 160).floor().clamp(1, 4);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: colCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3.4,
                  ),
                  itemCount: chips.length,
                  itemBuilder: (_, i) {
                    final l = chips[i];
                    return _ChipButton(
                      label: l,
                      cs: cs,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChatRoomPage(room: l)),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.cs,
    required this.onTap,
  });

  final String label;
  final ColorScheme cs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cs.surface, // fond neutre
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: cs.primary, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
