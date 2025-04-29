import 'package:echolinkz/ui/widgets/echolinkz_appbar.dart';
import 'package:echolinkz/ui/widgets/echolinkz_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'create_report_viewmodel.dart';
import 'package:geolocator/geolocator.dart';

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  static const categories = ['eau', 'secours', 'panne', 'abri', 'info'];

  late final MapController _mapCtrl = MapController();
  LatLng _initialCenter = const LatLng(48.8566, 2.3522);

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();

      final userLatLng = LatLng(pos.latitude, pos.longitude);
      if (mounted) {
        _mapCtrl.move(userLatLng, 13);

        Provider.of<CreateReportViewModel>(context, listen: false)
            .setLocation(userLatLng);

        setState(() => _initialCenter = userLatLng);
      }
    } catch (_) {
      /* permissions refusées → aucun marqueur par défaut */
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CreateReportViewModel>(context);

    return Scaffold(
      appBar: const EchoLinkZAppBar(title: "Nouveau signalement"),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                        height: 250,
                        child: FlutterMap(
                          mapController: _mapCtrl,
                          options: MapOptions(
                            initialCenter: _initialCenter,
                            initialZoom: 13,
                            onTap: (tapPos, p) => vm.setLocation(p),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              tileProvider: CancellableNetworkTileProvider(),
                              userAgentPackageName: 'fr.echolinkz.app',
                            ),
                            if (vm.location != null)
                              MarkerLayer(markers: [
                                Marker(
                                  width: 40,
                                  height: 40,
                                  point: vm.location!,
                                  child: const Icon(Icons.place,
                                      size: 40, color: Colors.red),
                                )
                              ]),
                          ],
                        )),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    vm.location == null
                        ? "Tapez sur la carte pour placer un marqueur"
                        : "Sélection : "
                            "${vm.location!.latitude.toStringAsFixed(5)}, "
                            "${vm.location!.longitude.toStringAsFixed(5)}",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: vm.titleController,
                    decoration: _dec(context, "Titre *"),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: vm.descController,
                    maxLines: 4,
                    decoration: _dec(context, "Description"),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: vm.category,
                    decoration: _dec(context, "Catégorie *"),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: vm.setCategory,
                  ),
                  const SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Priorité : ${vm.priority.toInt()}",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary)),
                      Slider(
                        value: vm.priority,
                        label: vm.priority.toInt().toString(),
                        divisions: 4,
                        min: 1,
                        max: 5,
                        onChanged: vm.setPriority,
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  EchoLinkZButton(
                    title: "Publier",
                    isLoading: vm.isLoading,
                    isEnable: vm.isEnableCreateButton(),
                    onPressed: () async => vm.createReport(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(BuildContext ctx, String label) {
    final cs = Theme.of(ctx).colorScheme;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: cs.onPrimary),
      border: OutlineInputBorder(borderSide: BorderSide(color: cs.primary)),
      enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: cs.primary)),
      filled: true,
      fillColor: cs.secondary,
    );
  }
}
