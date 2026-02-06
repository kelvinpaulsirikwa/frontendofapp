import 'dart:convert';
import 'package:bnbfrontendflutter/auth/loginpage.dart';
import 'package:bnbfrontendflutter/bnb/dashboard.dart';
import 'package:bnbfrontendflutter/services/bnbconnection.dart';
import 'package:bnbfrontendflutter/utility/alert.dart';
import 'package:bnbfrontendflutter/utility/navigateutility.dart';
import 'package:bnbfrontendflutter/utility/sharedpreferences.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
// Replace this with your real backend URL

class GoogleSignInManager {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Step 1: Check current sign-in status
      final bool isCurrentlySignedIn = await _googleSignIn.isSignedIn();

      if (isCurrentlySignedIn) {
        await _googleSignIn.signOut();
      }

      // Step 2: Initiate Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        // Step 3: Extract and validate user data
        final userName = googleUser.displayName ?? '';
        final userEmail = googleUser.email;
        final userImageurl = googleUser.photoUrl ?? "";

        // Validate required data
        if (userEmail.isEmpty) {
          AlertReturn.showToast(
            'Authentication failed: No email received from Google',
          );
          return;
        }
        if (userName.isEmpty) {
          // Use email as fallback for display name
        }

        // Step 4: Prepare request data
        final requestData = {
          'username': userName,
          'email': userEmail,
          'userimage': userImageurl,
          'phone': '',
        };

        final String requestUrl = '$baseUrl/userlogin';

        final Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };

        final String requestBody = json.encode(requestData);

        // Step 6: Execute HTTP request

        final response = await http
            .post(Uri.parse(requestUrl), headers: headers, body: requestBody)
            .timeout(Duration(seconds: 30));

        // Step 7: Process response
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Parse response body
          Map<String, dynamic> data;
          try {
            data = json.decode(response.body);
          } catch (e) {
            AlertReturn.showToast(
              'Authentication failed: Invalid server response',
            );
            return;
          }

          // Step 7.1: Extract token and customer ID from response
          // Smart extraction: Handle response structure flexibly
          String token = '';
          int? customerId;

          // Try to extract from data.data structure (standard response format)
          if (data['data'] is Map<String, dynamic>) {
            final Map<String, dynamic> dataMap =
                data['data'] as Map<String, dynamic>;

            // Extract token
            if (dataMap['token'] != null) {
              token = dataMap['token'].toString();
            }

            // Extract customer ID from user object
            if (dataMap['user'] is Map<String, dynamic>) {
              final Map<String, dynamic> userMap =
                  dataMap['user'] as Map<String, dynamic>;
              if (userMap['id'] != null) {
                customerId = userMap['id'] is int
                    ? userMap['id'] as int
                    : int.tryParse(userMap['id'].toString());
              }
            }
          }

          // Fallback: Try root level (for backward compatibility)
          if (token.isEmpty && data['token'] != null) {
            token = data['token'].toString();
          }

          // Validate token
          if (token.isEmpty) {
            AlertReturn.showToast(
              'Authentication failed: No token received from server',
            );
            return;
          }

          // Step 8: Generate account ID and save user data
          final String accountId =
              "acct_${DateTime.now().millisecondsSinceEpoch}";

          try {
            await UserPreferences.saveUserData(
              username: userName,
              email: userEmail,
              accountId: accountId,
              googleimageurl: userImageurl,
              apiToken: token,
              customerId: customerId,
            );
          } catch (e) {
            AlertReturn.showToast(
              'Authentication failed: Could not save user data',
            );
            return;
          }

          // Step 9: Navigate to Dashboard
          if (!context.mounted) {
            AlertReturn.showToast(
              'Authentication successful but screen is no longer available',
            );
            return;
          }

          try {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                NavigationUtil.pushAndRemoveUntil(context, const Dashboard());
              }
            });
          } catch (e) {
            AlertReturn.showToast(
              'Authentication successful but navigation failed',
            );
          }
        } else {
          // Handle server error response
          String errorMessage = 'Failed to authenticate with server';

          try {
            final errorData =
                json.decode(response.body) as Map<String, dynamic>?;
            errorMessage =
                errorData?['message'] ??
                errorData?['error'] ??
                'Server error (${response.statusCode})';
          } catch (e) {
            errorMessage = 'Server error (${response.statusCode})';
          }

          AlertReturn.showToast(errorMessage);
        }
      } else {
        // User cancelled sign-in
      }
    } catch (error) {
      String errorMessage = _getErrorMessage(error);
      AlertReturn.showToast(errorMessage);
    }
  }

  // Smart error message extraction
  static String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorStr.contains('timeout')) {
      return 'Connection timeout. Please try again.';
    } else if (errorStr.contains('server')) {
      return 'Server error. Please try again later.';
    } else if (errorStr.contains('cancelled')) {
      return 'Sign-in was cancelled.';
    } else if (errorStr.contains('permission')) {
      return 'Permission denied. Please check app permissions.';
    }

    return 'Error signing in: ${error.toString()}';
  }

  Future<void> signOut(BuildContext context) async {
    try {
      // Step 1: Revoke token on backend
      final token = await UserPreferences.getApiToken();

      if (token != null && token.isNotEmpty) {
        try {
          final url = Uri.parse('$baseUrl/logout');
          final response = await http
              .post(
                url,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $token',
                },
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            // Token revoked
          } else {
            // Backend logout failed, continuing with local logout
          }
        } catch (e) {
          // Backend logout error, continuing with local logout
        }
      } else {
        // No token found, skipping backend logout
      }

      // Step 2: Sign out from Google
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        // Google sign out error, continuing
      }

      // Step 3: Clear all local data
      await UserPreferences.clearAll();

      // Step 4: Navigate to login
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (error) {
      // Even if there's an error, try to clear local data and navigate
      try {
        await UserPreferences.clearAll();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        // Failed to clear data
      }

      AlertReturn.showToast('Signed out (some errors occurred)');
    }
  }
}
