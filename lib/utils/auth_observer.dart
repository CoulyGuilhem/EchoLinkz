import 'package:flutter/material.dart';

import 'shared_prefs_manager.dart';

class AuthObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _checkAuthentication(route.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _checkAuthentication(newRoute?.settings.name);
  }

  Future<void> _checkAuthentication(String? routeName) async {
    if (routeName == null) return;
    bool isUserLogged = await SharedPreferencesManager.isUserLoggedIn();

    if (isUserLogged && routeName == '/login') {
      navigator!
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } else if (!isUserLogged && routeName != '/login') {
      navigator!
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }
}
