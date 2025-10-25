import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _kLastRouteKey = 'last_route_name';

  static Future<void> setLastRoute(String routeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastRouteKey, routeName);
  }

  static Future<String?> getLastRoute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLastRouteKey);
  }

  static Future<void> clearLastRoute() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastRouteKey);
  }
}

