import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../../models/auth_model.dart';
import '../../services/auth_service.dart';
import '../../utils/show_error_snackbar.dart';

class RegisterViewModel extends ChangeNotifier {
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController  = TextEditingController();

  RegisterViewModel() {
    emailController.addListener(_onFieldChanged);
    passwordController.addListener(_onFieldChanged);
    confirmController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => notifyListeners();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  bool isLoading = false;

  Future<void> register(BuildContext context) async {
    if (passwordController.text != confirmController.text) {
      showErrorSnackbar(context, "Les mots de passe ne correspondent pas");
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      Response response = await AuthService()
          .register(emailController.text, passwordController.text);

      if (response.statusCode == 201) {
        if (context.mounted) {
          final authModel = Provider.of<AuthModel>(context, listen: false);
          authModel.isLoggedIn = true;
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (context.mounted) showErrorSnackbar(context, e.toString());
    }

    isLoading = false;
    notifyListeners();
  }

  bool isEnableRegisterButton() =>
      emailController.text.isNotEmpty &&
      passwordController.text.isNotEmpty &&
      confirmController.text.isNotEmpty &&
      !isLoading;
}
