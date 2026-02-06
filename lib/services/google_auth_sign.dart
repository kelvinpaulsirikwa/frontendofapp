import 'dart:convert';
import 'package:bnbfrontendflutter/auth/loginpage.dart';
import 'package:bnbfrontendflutter/bnb/dashboard.dart';
import 'package:bnbfrontendflutter/services/api_client.dart';
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
    ApiClient.log("=== GOOGLE SIGN-IN PROCESS STARTED ===");
    ApiClient.log("Timestamp: ${DateTime.now().toIso8601String()}");
    ApiClient.log("Context mounted: ${context.mounted}");

    try {
      // Step 1: Check current sign-in status
      ApiClient.log("\n--- STEP 1: CHECKING CURRENT SIGN-IN STATUS ---");
      final bool isCurrentlySignedIn = await _googleSignIn.isSignedIn();
      ApiClient.log("Currently signed in: $isCurrentlySignedIn");

      if (isCurrentlySignedIn) {
        ApiClient.log("User is already signed in, getting current user...");
        final GoogleSignInAccount? currentUser = _googleSignIn.currentUser;
        ApiClient.log("Current user: ${currentUser?.email ?? 'No email'}");
        ApiClient.log(
          "Current user display name: ${currentUser?.displayName ?? 'No display name'}",
        );

        ApiClient.log("Signing out to force account selection...");
        await _googleSignIn.signOut();
        ApiClient.log("Sign out completed successfully");

        // Verify sign out
        final bool isSignedOut = await _googleSignIn.isSignedIn();
        ApiClient.log("Verification - Is signed in after sign out: $isSignedOut");
      } else {
        ApiClient.log("User is not currently signed in, proceeding with sign-in...");
      }

      // Step 2: Initiate Google Sign-In
      ApiClient.log("\n--- STEP 2: INITIATING GOOGLE SIGN-IN ---");
      ApiClient.log("Starting Google Sign-In process...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        ApiClient.log("Google Sign-In successful!");
        ApiClient.log("Google user object received: ${googleUser.toString()}");

        // Step 3: Extract and validate user data
        ApiClient.log("\n--- STEP 3: EXTRACTING USER DATA ---");
        final userName = googleUser.displayName ?? '';
        final userEmail = googleUser.email;
        final userImageurl = googleUser.photoUrl ?? "";

        // Validate required data
        ApiClient.log("\n--- STEP 3.1: VALIDATING USER DATA ---");
        if (userEmail.isEmpty) {
          ApiClient.log("ERROR: User email is empty!");
          AlertReturn.showToast(
            'Authentication failed: No email received from Google',
          );
          return;
        }
        if (userName.isEmpty) {
          ApiClient.log("WARNING: User display name is empty, using email as fallback");
        }

        ApiClient.log("User data validation passed");

        // Step 4: Prepare request data
        ApiClient.log("\n--- STEP 4: PREPARING REQUEST DATA ---");
        final requestData = {
          'username': userName,
          'email': userEmail,
          'userimage': userImageurl,
          'phone': '',
        };

        ApiClient.log("Request data prepared:");
        requestData.forEach((key, value) {
          ApiClient.log("  - $key: '$value'");
        });

        // Step 5: Prepare HTTP request
        ApiClient.log("\n--- STEP 5: PREPARING HTTP REQUEST ---");
        final String requestUrl = '$baseUrl/userlogin';
        ApiClient.log("Request URL: $requestUrl");

        final Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };
        ApiClient.log("Request headers:");
        headers.forEach((key, value) {
          ApiClient.log("  - $key: $value");
        });

        final String requestBody = json.encode(requestData);
        ApiClient.log("Request body (JSON): $requestBody");
        ApiClient.log("Request body length: ${requestBody.length} characters");

        // Step 6: Execute HTTP request
        ApiClient.log("\n--- STEP 6: EXECUTING HTTP REQUEST ---");
        ApiClient.log("Sending POST request to server...");
        ApiClient.log("Timeout set to: 30 seconds");

        final DateTime requestStartTime = DateTime.now();
        final response = await http
            .post(Uri.parse(requestUrl), headers: headers, body: requestBody)
            .timeout(Duration(seconds: 30));
        final DateTime requestEndTime = DateTime.now();
        final Duration requestDuration = requestEndTime.difference(
          requestStartTime,
        );

        ApiClient.log("Request completed!");
        ApiClient.log("Request duration: ${requestDuration.inMilliseconds}ms");
        ApiClient.log("Response status code: ${response.statusCode}");
        ApiClient.log("Response headers:");
        response.headers.forEach((key, value) {
          ApiClient.log("  - $key: $value");
        });
        ApiClient.log("Response body length: ${response.body.length} characters");
        ApiClient.log("Response body: ${response.body}");
        // Step 7: Process response
        ApiClient.log("\n--- STEP 7: PROCESSING RESPONSE ---");
        if (response.statusCode == 200 || response.statusCode == 201) {
          ApiClient.log(
            "SUCCESS: Response received with status code ${response.statusCode}",
          );

          // Parse response body
          ApiClient.log("Parsing response body as JSON...");
          Map<String, dynamic> data;
          try {
            data = json.decode(response.body);
            ApiClient.log("JSON parsing successful!");
            ApiClient.log("Parsed response data structure:");
            data.forEach((key, value) {
              ApiClient.log("  - $key: ${value.runtimeType} = $value");
            });
          } catch (e) {
            ApiClient.log("ERROR: Failed to parse response as JSON: $e");
            ApiClient.log("Raw response body: ${response.body}");
            AlertReturn.showToast(
              'Authentication failed: Invalid server response',
            );
            return;
          }

          // Step 7.1: Extract token and customer ID from response
          ApiClient.log("\n--- STEP 7.1: EXTRACTING AUTH DATA ---");

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
              ApiClient.log("✓ Token found at data.token: ${token.length} chars");
            }

            // Extract customer ID from user object
            if (dataMap['user'] is Map<String, dynamic>) {
              final Map<String, dynamic> userMap =
                  dataMap['user'] as Map<String, dynamic>;
              if (userMap['id'] != null) {
                customerId = userMap['id'] is int
                    ? userMap['id'] as int
                    : int.tryParse(userMap['id'].toString());
                ApiClient.log("✓ Customer ID found: $customerId");
              }
            }
          }

          // Fallback: Try root level (for backward compatibility)
          if (token.isEmpty && data['token'] != null) {
            token = data['token'].toString();
            ApiClient.log("✓ Token found at root level: ${token.length} chars");
          }

          // Validate token
          if (token.isEmpty) {
            ApiClient.log("✗ ERROR: No valid token found in response!");
            ApiClient.log("Response structure: ${data.keys.toList()}");
            AlertReturn.showToast(
              'Authentication failed: No token received from server',
            );
            return;
          }

          ApiClient.log("✓ Token extraction successful!");
          if (customerId != null) {
            ApiClient.log("✓ Customer ID extraction successful!");
          } else {
            ApiClient.log("⚠ WARNING: Customer ID not found, but continuing...");
          }

          // Step 8: Generate account ID and save user data
          ApiClient.log("\n--- STEP 8: SAVING USER DATA ---");
          final String accountId =
              "acct_${DateTime.now().millisecondsSinceEpoch}";

          ApiClient.log("User data to save:");
          ApiClient.log("  ✓ Username: '$userName'");
          ApiClient.log("  ✓ Email: '$userEmail'");
          ApiClient.log("  ✓ Account ID: '$accountId'");
          ApiClient.log(
            "  ${customerId != null ? '✓' : '⚠'} Customer ID: ${customerId ?? 'Not found'}",
          );
          ApiClient.log(
            "  ✓ Google Image: ${userImageurl.isNotEmpty ? 'Present' : 'Not provided'}",
          );
          ApiClient.log("  ✓ API Token: ${token.length} characters");

          try {
            await UserPreferences.saveUserData(
              username: userName,
              email: userEmail,
              accountId: accountId,
              googleimageurl: userImageurl,
              apiToken: token,
              customerId: customerId,
            );
            ApiClient.log("✓ User data saved successfully!");

            // Quick verification
            final savedToken = await UserPreferences.getApiToken();
            final savedCustomerId = await UserPreferences.getCustomerId();
            ApiClient.log(
              "✓ Verification: Token=${savedToken != null ? 'Saved' : 'Missing'}, CustomerID=${savedCustomerId ?? 'Not found'}",
            );
          } catch (e) {
            ApiClient.log("✗ ERROR: Failed to save user data: $e");
            AlertReturn.showToast(
              'Authentication failed: Could not save user data',
            );
            return;
          }

          // Step 9: Navigate to Dashboard
          ApiClient.log("\n--- STEP 9: NAVIGATION ---");

          if (!context.mounted) {
            ApiClient.log("✗ Context not mounted, cannot navigate");
            AlertReturn.showToast(
              'Authentication successful but screen is no longer available',
            );
            return;
          }

          try {
            ApiClient.log("Navigating to Dashboard...");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                NavigationUtil.pushAndRemoveUntil(context, const Dashboard());
                ApiClient.log("✓ Navigation successful!");
              }
            });
            ApiClient.log("=== ✓ GOOGLE SIGN-IN COMPLETED SUCCESSFULLY ===");
          } catch (e) {
            ApiClient.log("✗ Navigation error: $e");
            AlertReturn.showToast(
              'Authentication successful but navigation failed',
            );
          }
        } else {
          // Handle server error response
          ApiClient.log("\n--- ✗ SERVER ERROR ---");
          ApiClient.log("Status: ${response.statusCode}");

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

          ApiClient.log("Error: $errorMessage");
          AlertReturn.showToast(errorMessage);
        }
      } else {
        // User cancelled sign-in
        ApiClient.log("\n--- ⚠ USER CANCELLED ---");
        ApiClient.log("=== GOOGLE SIGN-IN CANCELLED ===");
      }
    } catch (error) {
      // Handle unexpected errors
      ApiClient.log("\n--- ✗ ERROR ---");
      ApiClient.log("Error: $error");

      String errorMessage = _getErrorMessage(error);
      ApiClient.log("Message: $errorMessage");

      AlertReturn.showToast(errorMessage);
      ApiClient.log("=== SIGN-IN FAILED ===");
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
    ApiClient.log("=== SIGN-OUT STARTED ===");

    try {
      // Step 1: Revoke token on backend
      ApiClient.log("Revoking token on backend...");
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
            ApiClient.log("✓ Token revoked on backend");
          } else {
            ApiClient.log(
              "⚠ Backend logout failed (${response.statusCode}), continuing...",
            );
          }
        } catch (e) {
          ApiClient.log("⚠ Backend logout error: $e (continuing with local logout)");
        }
      } else {
        ApiClient.log("⚠ No token found, skipping backend logout");
      }

      // Step 2: Sign out from Google
      try {
        await _googleSignIn.signOut();
        ApiClient.log("✓ Google sign out completed");
      } catch (e) {
        ApiClient.log("⚠ Google sign out error: $e (continuing...)");
      }

      // Step 3: Clear all local data
      await UserPreferences.clearAll();
      ApiClient.log("✓ User data cleared");

      // Step 4: Navigate to login
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
        ApiClient.log("✓ Navigation to login completed");
      }

      ApiClient.log("=== ✓ SIGN-OUT COMPLETED ===");
    } catch (error) {
      ApiClient.log("✗ Sign-out error: $error");

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
        ApiClient.log("✗ Failed to clear data: $e");
      }

      AlertReturn.showToast('Signed out (some errors occurred)');
    }
  }
}
