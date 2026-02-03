import 'package:bnbfrontendflutter/auth/loginpage.dart';
import 'package:bnbfrontendflutter/bnb/dashboard.dart';
import 'package:bnbfrontendflutter/l10n/app_localizations.dart';
import 'package:bnbfrontendflutter/l10n/languagemanagemen.dart';
import 'package:bnbfrontendflutter/layouts/loading.dart';
import 'package:bnbfrontendflutter/services/api_client.dart';
import 'package:bnbfrontendflutter/services/deep_link_service.dart';
import 'package:bnbfrontendflutter/services/favorites_service.dart';
import 'package:bnbfrontendflutter/utility/sharedpreferences.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Global navigator key for handling logout navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Global variables to store login state after initialization
bool _isLoggedIn = false;
Locale _savedLocale = const Locale('en');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Set the global navigator key for ApiClient to use for logout navigation
  ApiClient.setNavigatorKey(navigatorKey);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) async {
    await LocaleController.saveLocale(newLocale);
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _locale = const Locale('en');
  }

  @override
  void dispose() {
    DeepLinkService.dispose();
    super.dispose();
  }

  void changeLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  Future<void> _initializeApp() async {
    // Initialize favorites service
    await FavoritesService.init();
    
    // Load saved locale
    _savedLocale = await LocaleController.loadLocale();
    
    // Check login status
    String? username = await UserPreferences.getUsername();
    String? email = await UserPreferences.getEmail();
    String? apiToken = await UserPreferences.getApiToken();

    _isLoggedIn = username != null && email != null && apiToken != null;
    
    // Update locale in state
    if (mounted) {
      setState(() {
        _locale = _savedLocale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize deep link handling after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        DeepLinkService.init(context);
      }
    });

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'BnB',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513), // deepTerracotta
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
      home: _showSplash
          ? Loading.splashLoading(
              onInit: _initializeApp,
              onComplete: (isLoggedIn) {
                // Mark splash as complete
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _showSplash = false;
                    });
                  }
                });
                // Return the appropriate page based on login status
                return _isLoggedIn ? const Dashboard() : const LoginPage();
              },
            )
          : _isLoggedIn
              ? const Dashboard()
              : const LoginPage(),
    );
  }
}
