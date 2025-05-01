import 'package:echolinkz/ui/home/chatbot_dialog.dart';
import 'package:echolinkz/ui/home/chatbot_viewmodel.dart';
import 'package:echolinkz/ui/reports/create_report_page.dart';
import 'package:echolinkz/ui/reports/report_detail_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EchoLinkZAppBar(title: 'EchoLinkZ'),
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
          reports.sort(
              (a, b) => (b['priority'] as int).compareTo(a['priority'] as int));

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
                r['category'] != _selectedCategory) {
              return false;
            }
            if (_selectedPriority != null &&
                r['priority'] != _selectedPriority) {
              return false;
            }
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
                      label: Text('Toutes (${reports.length})'),
                      selected: _selectedCategory == null,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = null),
                    ),
                    ..._categories.map((c) => ChoiceChip(
                          label: Text('${c.toUpperCase()} (${catCounts[c]})'),
                          selected: _selectedCategory == c,
                          onSelected: (sel) => setState(
                              () => _selectedCategory = sel ? c : null),
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
                      label: Text('Toutes'),
                      selected: _selectedPriority == null,
                      onSelected: (_) =>
                          setState(() => _selectedPriority = null),
                    ),
                    ...List.generate(5, (i) => i + 1).map((p) => ChoiceChip(
                          label: Text('$p (${prioCounts[p]})'),
                          selected: _selectedPriority == p,
                          onSelected: (sel) => setState(
                              () => _selectedPriority = sel ? p : null),
                        )),
                  ],
                ),
              ),

              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun signalement pour ces filtres',
                          style:
                              Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshReports,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final r = filtered[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ReportDetailPage(report: r),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r['title'] ?? 'Sans titre',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      if ((r['description'] as String?)
                                              ?.isNotEmpty ??
                                          false)
                                        Text(
                                          r['description']!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Chip(
                                            label: Text(
                                              r['category']
                                                      ?.toString()
                                                      .toUpperCase() ??
                                                  '',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                          const SizedBox(width: 8),
                                          Chip(
                                            avatar: const Icon(
                                                Icons.priority_high,
                                                size: 18),
                                            label:
                                                Text('${r['priority'] ?? '-'}'),
                                          ),
                                        ],
                                      ),
                                    ],
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
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateReportPage()),
              );
              _refreshReports();
            },
            tooltip: 'Nouveau signalement',
            child: const Icon(Icons.report, size: 28),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
