// lib/ui/home/home_page.dart

import 'package:echolinkz/ui/home/chatbot_dialog.dart';
import 'package:echolinkz/ui/home/chatbot_viewmodel.dart';
import 'package:echolinkz/ui/reports/create_report_page.dart';
import 'package:echolinkz/ui/reports/report_detail_page.dart';
import 'package:echolinkz/ui/reports/chat_spaces_page.dart';
import 'package:echolinkz/ui/widgets/EchoLinkZ_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/report_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> _reportsFuture;
  static const _categories = ['eau', 'secours', 'panne', 'abri', 'info'];
  String? _selectedCategory;
  int? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    setState(() {
      _reportsFuture = ReportService().getReports();
    });
  }

  Future<void> _refreshReports() async {
    _loadReports();
    await _reportsFuture;
  }

  void _openChatSpaces() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatSpacesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: EchoLinkZAppBar(
        title: 'EchoLinkZ',
        actions: [
          IconButton(
            icon: const Icon(Icons.forum),
            color: cs.onPrimary,
            onPressed: _openChatSpaces,
            tooltip: 'Espaces de discussion',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur lors du chargement'));
          }

          final reports = snapshot.data!;
          reports.sort((a, b) =>
              (b['priority'] as int).compareTo(a['priority'] as int));
          final catCounts = {
            for (var c in _categories)
              c: reports.where((r) => r['category'] == c).length
          };
          final prioCounts = {
            for (var p = 1; p <= 5; p++)
              p: reports.where((r) => (r['priority'] as int) == p).length
          };

          final filtered = reports.where((r) {
            if (_selectedCategory != null &&
                _selectedCategory!.isNotEmpty &&
                r['category'] != _selectedCategory) return false;
            if (_selectedPriority != null && r['priority'] != _selectedPriority)
              return false;
            return true;
          }).toList();

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text('Toutes (${reports.length})',
                          style: TextStyle(color: cs.onSecondary)),
                      selected: _selectedCategory == null,
                      selectedColor: cs.primary,
                      backgroundColor: cs.secondary,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = null),
                    ),
                    ..._categories.map((c) => ChoiceChip(
                          label: Text('${c.toUpperCase()} (${catCounts[c]})',
                              style: TextStyle(
                                  color: _selectedCategory == c
                                      ? cs.onPrimary
                                      : cs.onSecondary)),
                          selected: _selectedCategory == c,
                          selectedColor: cs.primary,
                          backgroundColor: cs.secondary,
                          onSelected: (sel) =>
                              setState(() => _selectedCategory = sel ? c : null),
                        )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text('Toutes',
                          style: TextStyle(color: cs.onSecondary)),
                      selected: _selectedPriority == null,
                      selectedColor: cs.primary,
                      backgroundColor: cs.secondary,
                      onSelected: (_) =>
                          setState(() => _selectedPriority = null),
                    ),
                    ...List.generate(5, (i) => i + 1).map((p) => ChoiceChip(
                          label: Text('$p (${prioCounts[p]})',
                              style: TextStyle(
                                  color: _selectedPriority == p
                                      ? cs.onPrimary
                                      : cs.onSecondary)),
                          selected: _selectedPriority == p,
                          selectedColor: cs.primary,
                          backgroundColor: cs.secondary,
                          onSelected: (sel) => setState(
                              () => _selectedPriority = sel ? p : null),
                        )),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text('Aucun signalement pour ces filtres',
                            style: theme.textTheme.bodyMedium))
                    : RefreshIndicator(
                        onRefresh: _refreshReports,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final r = filtered[i];
                            final catColor = _catColor(r['category'], cs);

                            return Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 600),
                                child: Card(
                                  elevation: 3,
                                  color: cs.surfaceVariant,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: cs.outline),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              ReportDetailPage(report: r)),
                                    ),
                                    leading: Container(
                                      width: 6,
                                      decoration: BoxDecoration(
                                        color: catColor,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Icon(_catIcon(r['category']),
                                            color: catColor),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            r['title'] ?? 'Sans titre',
                                            style: theme
                                                .textTheme.titleMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if ((r['description'] as String?)
                                                ?.isNotEmpty ??
                                            false)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 6),
                                            child: Text(r['description']!,
                                                maxLines: 3,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Chip(
                                              avatar: Icon(
                                                  _catIcon(
                                                      r['category']),
                                                  color: catColor),
                                              label: Text(
                                                r['category']
                                                    .toString()
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              backgroundColor:
                                                  catColor.withOpacity(.15),
                                            ),
                                            const SizedBox(width: 8),
                                            Chip(
                                              avatar: const Icon(
                                                  Icons.flash_on,
                                                  size: 18),
                                              label: Text(
                                                  '${r['priority']}'),
                                              backgroundColor:
                                                  cs.surface,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fab_help',
            backgroundColor: cs.tertiary,
            foregroundColor: cs.onTertiary,
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ChangeNotifierProvider.value(
                  value: context.read<ChatbotViewModel>(),
                  child: const ChatbotDialog(),
                ),
              );
            },
            label: const Text('Besoin d’aide ?'),
            icon: const Icon(Icons.help_outline),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'fab_report',
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateReportPage(),
                ),
              );
              _refreshReports();
            },
            child: const Icon(Icons.report, size: 28),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Color _catColor(String cat, ColorScheme cs) {
    switch (cat) {
      case 'eau': return cs.primary;
      case 'secours': return cs.error;
      case 'panne': return cs.tertiary;
      case 'abri': return cs.secondary;
      default: return cs.outline;
    }
  }

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'eau': return Icons.water_drop;
      case 'secours': return Icons.local_hospital;
      case 'panne': return Icons.car_repair;
      case 'abri': return Icons.home;
      default: return Icons.info;
    }
  }
}
