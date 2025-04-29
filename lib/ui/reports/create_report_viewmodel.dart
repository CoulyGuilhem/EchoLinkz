import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../services/report_service.dart';
import '../../utils/show_error_snackbar.dart';

class CreateReportViewModel extends ChangeNotifier {
  final titleController = TextEditingController();
  final descController  = TextEditingController();

  LatLng? _location;
  String? _category;
  double  _priority = 3;

  bool isLoading = false;

  LatLng? get location => _location;
  String? get category => _category;
  double  get priority => _priority;

  CreateReportViewModel() {
    titleController.addListener(_onChanged);
    descController.addListener(_onChanged);
  }

  void _onChanged() => notifyListeners();

  void setCategory(String? v) {
    _category = v;
    notifyListeners();
  }

  void setPriority(double v) {
    _priority = v;
    notifyListeners();
  }

  void setLocation(LatLng p) {
    _location = p;
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  bool isEnableCreateButton() =>
      titleController.text.trim().isNotEmpty &&
      _category?.isNotEmpty == true &&
      _location != null &&
      !isLoading;

  Future<void> createReport(BuildContext context) async {
    if (!isEnableCreateButton()) return;

    isLoading = true;
    notifyListeners();

    try {
      await ReportService().createReport(
        title: titleController.text.trim(),
        description: descController.text.trim(),
        category: _category!,
        priority: _priority.toInt(),
        lat: _location!.latitude,
        lng: _location!.longitude,
      );

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) showErrorSnackbar(context, e.toString());
    }

    isLoading = false;
    notifyListeners();
  }
}
