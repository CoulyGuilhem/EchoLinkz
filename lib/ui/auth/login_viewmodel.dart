import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:echolinkz/services/auth_service.dart';
import 'package:echolinkz/utils/show_error_snackbar.dart';
import 'package:provider/provider.dart';

import '../../models/auth_model.dart';
import '../../utils/validators.dart';

class LoginViewModel extends ChangeNotifier {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginViewModel() {
    emailController.addListener(_onFieldChanged);
    passwordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.removeListener(_onFieldChanged);
    passwordController.removeListener(_onFieldChanged);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool isLoading = false;

  Future login(BuildContext context) async {
    if (!Validators.isValidEmail(emailController.text)) {
      showErrorSnackbar(context, "Adresse e-mail invalide");
      return;
    }
    if (!Validators.isValidPassword(passwordController.text)) {
      showErrorSnackbar(context,
          "Mot de passe faible : 8 caractères, majuscule, minuscule, chiffre, symbole");
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      Response response =
          await AuthService().login(emailController.text, passwordController.text);

      if (response.statusCode == 200) {
        if (context.mounted) {
          final authModel = Provider.of<AuthModel>(context, listen: false);
          authModel.isLoggedIn = true;
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackbar(context, e.toString());
      }
    }

    isLoading = false;
    notifyListeners();
  }

  bool isEnableLoginButton() {
    return Validators.isValidEmail(emailController.text) &&
           Validators.isValidPassword(passwordController.text) &&
           !isLoading;
  }
}
