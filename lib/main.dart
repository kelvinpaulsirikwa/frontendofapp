import 'package:bnbfrontendflutter/auth/loginpage.dart';
import 'package:bnbfrontendflutter/bnb/dashboard.dart';
import 'package:bnbfrontendflutter/l10n/app_localizations.dart';
import 'package:bnbfrontendflutter/l10n/languagemanagemen.dart';
import 'package:bnbfrontendflutter/services/favorites_service.dart';
import 'package:bnbfrontendflutter/utility/sharedpreferences.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ must be first
    await Hive.initFlutter(); // This automatically sets the path for mobile apps

  await FavoritesService.init();
  Locale savedLocale = await LocaleController.loadLocale();

  // Check login status before building the app
  String? username = await UserPreferences.getUsername();
  String? email = await UserPreferences.getEmail();
  String? apiToken = await UserPreferences.getApiToken();

  final bool isLoggedIn = username != null && email != null && apiToken != null;

  runApp(MyApp(savedLocale: savedLocale, isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  final Locale savedLocale;
  final bool isLoggedIn;
  const MyApp({super.key, required this.savedLocale, required this.isLoggedIn});

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

  @override
  void initState() {
    super.initState();
    _locale = widget.savedLocale;
  }

  void changeLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BnB',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      locale: _locale, // ✅ Use saved or selected locale
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
      home: widget.isLoggedIn ? const Dashboard() : const LoginPage(),
    );
  }
}
