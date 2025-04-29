import 'package:echolinkz/ui/widgets/echolinkz_appbar.dart';
import 'package:echolinkz/ui/widgets/echolinkz_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'register_viewmodel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RegisterViewModel>(context);

    return Scaffold(
      appBar: const EchoLinkZAppBar(title: "EchoLinkZ"),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.35,
                    vertical: MediaQuery.of(context).size.height * 0.05),
                child: Text(
                  'Créer un compte',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
               Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.35,
                    vertical: 10),
                child: TextFormField(
                  controller: viewModel.usernameController,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  decoration: _fieldDecoration(context, "Nom d'utilisateur"),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.35,
                    vertical: 10),
                child: TextFormField(
                  controller: viewModel.emailController,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  decoration: _fieldDecoration(context, "Adresse email"),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.35,
                    vertical: 10),
                child: TextFormField(
                  controller: viewModel.passwordController,
                  obscureText: true,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  decoration: _fieldDecoration(context, "Mot de passe"),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.35,
                    vertical: 10),
                child: TextFormField(
                  controller: viewModel.confirmController,
                  obscureText: true,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  decoration:
                      _fieldDecoration(context, "Confirmer le mot de passe"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: EchoLinkZButton(
                  title: "S'inscrire",
                  isLoading: viewModel.isLoading,
                  isEnable: viewModel.isEnableRegisterButton(),
                  onPressed: () async {
                    await viewModel.register(context);
                  },
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text("J'ai déjà un compte"),
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(BuildContext ctx, String label) {
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
