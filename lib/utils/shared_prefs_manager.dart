import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {

  static Future<void> loginUser(String userId, String sessionToken) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("user", userId);
    await preferences.setString("session_token", sessionToken);
  }

  static Future<String?> getUser() async {
    if (await isUserLoggedIn() == false) return null;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString("user");
  }

  static Future<String?> getSessionToken() async {
    if (await isUserLoggedIn() == false) return null;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString("session_token");
  }

  static Future<void> logoutUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("user");
    await preferences.remove("session_token");
  }

  static Future<bool> isUserLoggedIn() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.containsKey("user") && preferences.containsKey("session_token");
  }
}