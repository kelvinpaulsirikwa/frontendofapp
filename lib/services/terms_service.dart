import 'package:bnbfrontendflutter/services/api_client.dart';

class TermsService {
  static Future<Map<String, dynamic>> getActiveTerms({
    BuildContext? context,
  }) async {
    final response = await ApiClient.get(
      '/terms-of-service',
      context: context,
    );
    return response;
  }
}
