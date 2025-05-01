import 'package:echolinkz/ui/auth/register_page.dart';
import 'package:echolinkz/ui/auth/register_viewmodel.dart';
import 'package:echolinkz/ui/home/chatbot_viewmodel.dart';
import 'package:echolinkz/ui/reports/create_report_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:echolinkz/models/auth_model.dart';
import 'package:echolinkz/ui/auth/login_page.dart';
import 'package:echolinkz/ui/auth/login_viewmodel.dart';
import 'package:echolinkz/ui/home/home_page.dart';
import 'package:echolinkz/utils/auth_observer.dart';
import 'package:provider/provider.dart';

void main() {
 runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => LoginViewModel()),
      ChangeNotifierProvider(create: (_) => RegisterViewModel()),
      ChangeNotifierProvider(create: (_) => CreateReportViewModel()),
      ChangeNotifierProvider(create: (_) => ChatbotViewModel()),
      ChangeNotifierProvider(create: (context) => AuthModel()),
    ],
    child: const EchoLinkZ(),
  ));
}

class EchoLinkZ extends StatelessWidget {
  const EchoLinkZ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EchoLinkZ',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
      navigatorObservers: [AuthObserver()],
      theme: ThemeData(
        colorScheme: const ColorScheme(
          //TODO: Improve the color scheme
          brightness: Brightness.light,
          primary: Color(0xFF1E88E5),
          onPrimary: Color(0xFFFFFFFF),
          secondary: Color(0xFF37474F),
          onSecondary: Color(0xFFBABABA),
          tertiary: Color(0xFF8BC34A),
          onTertiary: Color(0xFFFFFFFF),
          error: Colors.red,
          onError: Color.fromARGB(255, 1, 1, 1),
          surface: Color(0xFF292929),
          onSurface: Color(0xFF1E88E5),
        ),
      ),
      initialRoute: '/login',
      debugShowCheckedModeBanner: false,
    );
  }
}