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
    print("=== GOOGLE SIGN-IN PROCESS STARTED ===");
    print("Timestamp: ${DateTime.now().toIso8601String()}");
    print("Context mounted: ${context.mounted}");

    try {
      // Step 1: Check current sign-in status
      print("\n--- STEP 1: CHECKING CURRENT SIGN-IN STATUS ---");
      final bool isCurrentlySignedIn = await _googleSignIn.isSignedIn();
      print("Currently signed in: $isCurrentlySignedIn");

      if (isCurrentlySignedIn) {
        print("User is already signed in, getting current user...");
        final GoogleSignInAccount? currentUser = _googleSignIn.currentUser;
        print("Current user: ${currentUser?.email ?? 'No email'}");
        print(
          "Current user display name: ${currentUser?.displayName ?? 'No display name'}",
        );

        print("Signing out to force account selection...");
        await _googleSignIn.signOut();
        print("Sign out completed successfully");

        // Verify sign out
        final bool isSignedOut = await _googleSignIn.isSignedIn();
        print("Verification - Is signed in after sign out: $isSignedOut");
      } else {
        print("User is not currently signed in, proceeding with sign-in...");
      }

      // Step 2: Initiate Google Sign-In
      print("\n--- STEP 2: INITIATING GOOGLE SIGN-IN ---");
      print("Starting Google Sign-In process...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        print("Google Sign-In successful!");
        print("Google user object received: ${googleUser.toString()}");

        // Step 3: Extract and validate user data
        print("\n--- STEP 3: EXTRACTING USER DATA ---");
        final userName = googleUser.displayName ?? '';
        final userEmail = googleUser.email;
        final userImageurl = googleUser.photoUrl ?? "";

        // Validate required data
        print("\n--- STEP 3.1: VALIDATING USER DATA ---");
        if (userEmail.isEmpty) {
          print("ERROR: User email is empty!");
          AlertReturn.showToast(
            'Authentication failed: No email received from Google',
          );
          return;
        }
        if (userName.isEmpty) {
          print("WARNING: User display name is empty, using email as fallback");
        }

        print("User data validation passed");

        // Step 4: Prepare request data
        print("\n--- STEP 4: PREPARING REQUEST DATA ---");
        final requestData = {
          'username': userName,
          'email': userEmail,
          'userimage': userImageurl,
          'phone': '',
        };

        print("Request data prepared:");
        requestData.forEach((key, value) {
          print("  - $key: '$value'");
        });

        // Step 5: Prepare HTTP request
        print("\n--- STEP 5: PREPARING HTTP REQUEST ---");
        final String requestUrl = '$baseUrl/userlogin';
        print("Request URL: $requestUrl");

        final Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };
        print("Request headers:");
        headers.forEach((key, value) {
          print("  - $key: $value");
        });

        final String requestBody = json.encode(requestData);
        print("Request body (JSON): $requestBody");
        print("Request body length: ${requestBody.length} characters");

        // Step 6: Execute HTTP request
        print("\n--- STEP 6: EXECUTING HTTP REQUEST ---");
        print("Sending POST request to server...");
        print("Timeout set to: 30 seconds");

        final DateTime requestStartTime = DateTime.now();
        final response = await http
            .post(Uri.parse(requestUrl), headers: headers, body: requestBody)
            .timeout(Duration(seconds: 30));
        final DateTime requestEndTime = DateTime.now();
        final Duration requestDuration = requestEndTime.difference(
          requestStartTime,
        );

        print("Request completed!");
        print("Request duration: ${requestDuration.inMilliseconds}ms");
        print("Response status code: ${response.statusCode}");
        print("Response headers:");
        response.headers.forEach((key, value) {
          print("  - $key: $value");
        });
        print("Response body length: ${response.body.length} characters");
        print("Response body: ${response.body}");
        // Step 7: Process response
        print("\n--- STEP 7: PROCESSING RESPONSE ---");
        if (response.statusCode == 200 || response.statusCode == 201) {
          print(
            "SUCCESS: Response received with status code ${response.statusCode}",
          );

          // Parse response body
          print("Parsing response body as JSON...");
          Map<String, dynamic> data;
          try {
            data = json.decode(response.body);
            print("JSON parsing successful!");
            print("Parsed response data structure:");
            data.forEach((key, value) {
              print("  - $key: ${value.runtimeType} = $value");
            });
          } catch (e) {
            print("ERROR: Failed to parse response as JSON: $e");
            print("Raw response body: ${response.body}");
            AlertReturn.showToast(
              'Authentication failed: Invalid server response',
            );
            return;
          }

          // Step 7.1: Extract token and customer ID from response
          print("\n--- STEP 7.1: EXTRACTING AUTH DATA ---");

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
              print("✓ Token found at data.token: ${token.length} chars");
            }

            // Extract customer ID from user object
            if (dataMap['user'] is Map<String, dynamic>) {
              final Map<String, dynamic> userMap =
                  dataMap['user'] as Map<String, dynamic>;
              if (userMap['id'] != null) {
                customerId = userMap['id'] is int
                    ? userMap['id'] as int
                    : int.tryParse(userMap['id'].toString());
                print("✓ Customer ID found: $customerId");
              }
            }
          }

          // Fallback: Try root level (for backward compatibility)
          if (token.isEmpty && data['token'] != null) {
            token = data['token'].toString();
            print("✓ Token found at root level: ${token.length} chars");
          }

          // Validate token
          if (token.isEmpty) {
            print("✗ ERROR: No valid token found in response!");
            print("Response structure: ${data.keys.toList()}");
            AlertReturn.showToast(
              'Authentication failed: No token received from server',
            );
            return;
          }

          print("✓ Token extraction successful!");
          if (customerId != null) {
            print("✓ Customer ID extraction successful!");
          } else {
            print("⚠ WARNING: Customer ID not found, but continuing...");
          }

          // Step 8: Generate account ID and save user data
          print("\n--- STEP 8: SAVING USER DATA ---");
          final String accountId =
              "acct_${DateTime.now().millisecondsSinceEpoch}";

          print("User data to save:");
          print("  ✓ Username: '$userName'");
          print("  ✓ Email: '$userEmail'");
          print("  ✓ Account ID: '$accountId'");
          print(
            "  ${customerId != null ? '✓' : '⚠'} Customer ID: ${customerId ?? 'Not found'}",
          );
          print(
            "  ✓ Google Image: ${userImageurl.isNotEmpty ? 'Present' : 'Not provided'}",
          );
          print("  ✓ API Token: ${token.length} characters");

          try {
            await UserPreferences.saveUserData(
              username: userName,
              email: userEmail,
              accountId: accountId,
              googleimageurl: userImageurl,
              apiToken: token,
              customerId: customerId,
            );
            print("✓ User data saved successfully!");

            // Quick verification
            final savedToken = await UserPreferences.getApiToken();
            final savedCustomerId = await UserPreferences.getCustomerId();
            print(
              "✓ Verification: Token=${savedToken != null ? 'Saved' : 'Missing'}, CustomerID=${savedCustomerId ?? 'Not found'}",
            );
          } catch (e) {
            print("✗ ERROR: Failed to save user data: $e");
            AlertReturn.showToast(
              'Authentication failed: Could not save user data',
            );
            return;
          }

          // Step 9: Navigate to Dashboard
          print("\n--- STEP 9: NAVIGATION ---");

          if (!context.mounted) {
            print("✗ Context not mounted, cannot navigate");
            AlertReturn.showToast(
              'Authentication successful but screen is no longer available',
            );
            return;
          }

          try {
            print("Navigating to Dashboard...");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                NavigationUtil.pushAndRemoveUntil(context, const Dashboard());
                print("✓ Navigation successful!");
              }
            });
            print("=== ✓ GOOGLE SIGN-IN COMPLETED SUCCESSFULLY ===");
          } catch (e) {
            print("✗ Navigation error: $e");
            AlertReturn.showToast(
              'Authentication successful but navigation failed',
            );
          }
        } else {
          // Handle server error response
          print("\n--- ✗ SERVER ERROR ---");
          print("Status: ${response.statusCode}");

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

          print("Error: $errorMessage");
          AlertReturn.showToast(errorMessage);
        }
      } else {
        // User cancelled sign-in
        print("\n--- ⚠ USER CANCELLED ---");
        print("=== GOOGLE SIGN-IN CANCELLED ===");
      }
    } catch (error) {
      // Handle unexpected errors
      print("\n--- ✗ ERROR ---");
      print("Error: $error");

      String errorMessage = _getErrorMessage(error);
      print("Message: $errorMessage");

      AlertReturn.showToast(errorMessage);
      print("=== SIGN-IN FAILED ===");
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
    print("=== SIGN-OUT STARTED ===");

    try {
      // Step 1: Revoke token on backend
      print("Revoking token on backend...");
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
            print("✓ Token revoked on backend");
          } else {
            print(
              "⚠ Backend logout failed (${response.statusCode}), continuing...",
            );
          }
        } catch (e) {
          print("⚠ Backend logout error: $e (continuing with local logout)");
        }
      } else {
        print("⚠ No token found, skipping backend logout");
      }

      // Step 2: Sign out from Google
      try {
        await _googleSignIn.signOut();
        print("✓ Google sign out completed");
      } catch (e) {
        print("⚠ Google sign out error: $e (continuing...)");
      }

      // Step 3: Clear all local data
      await UserPreferences.clearAll();
      print("✓ User data cleared");

      // Step 4: Navigate to login
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
        print("✓ Navigation to login completed");
      }

      print("=== ✓ SIGN-OUT COMPLETED ===");
    } catch (error) {
      print("✗ Sign-out error: $error");

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
        print("✗ Failed to clear data: $e");
      }

      AlertReturn.showToast('Signed out (some errors occurred)');
    }
  }
}
