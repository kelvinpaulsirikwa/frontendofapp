import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // Save all user data
  static Future<void> saveUserData({
    required String username,
    required String email,
    required String accountId,
    required String googleimageurl,
    required String apiToken,
    int? customerId,
  }) async {
    final prefs = await _prefs;
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('accountid', accountId);
    await prefs.setString('apiToken', apiToken);
    await prefs.setString('googleimageurl', googleimageurl);
    if (customerId != null) {
      await prefs.setInt('customerId', customerId);
    }
  }

  // Getters
  static Future<String?> getUsername() async =>
      (await _prefs).getString('username');

  static Future<String?> getEmail() async => (await _prefs).getString('email');

  static Future<String?> getApiToken() async =>
      (await _prefs).getString('apiToken');

  static Future<String?> getGoogleImage() async =>
      (await _prefs).getString('googleimageurl');

  static Future<String?> getAccountId() async =>
      (await _prefs).getString('accountid');

  static Future<int?> getCustomerId() async =>
      (await _prefs).getInt('customerId');

  // Clear all saved data
  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  /// Debug method - call ApiClient.log() with returned data when ApiClient.enableLogging is true.
  static Future<Map<String, String?>> debugPrintAllData() async {
    final prefs = await _prefs;
    return {
      'Username': prefs.getString('username'),
      'Email': prefs.getString('email'),
      'Account ID': prefs.getString('accountid'),
      'API Token': prefs.getString('apiToken'),
      'Google Image URL': prefs.getString('googleimageurl'),
    };
  }

  // Check if user is logged in (has valid data)
  static Future<bool> isUserLoggedIn() async {
    final username = await getUsername();
    final email = await getEmail();
    final token = await getApiToken();

    return username != null &&
        username.isNotEmpty &&
        email != null &&
        email.isNotEmpty &&
        token != null &&
        token.isNotEmpty;
  }
}
