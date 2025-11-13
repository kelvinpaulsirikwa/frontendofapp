import 'package:flutter/material.dart';
import 'package:bnbfrontendflutter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController {
  static const _languageCodeKey = 'language_code';

  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, locale.languageCode);
  }

  static Future<Locale> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_languageCodeKey) ?? 'en';
    return Locale(langCode);
  }
}
//language sheet

class LanguageBottomSheet {
  static final Map<String, String> _flags = {"en": "🇬🇧", "sw": "🇹🇿"};

  static final Map<String, String> _languageNames = {
    "en": "English",
    "sw": "Kiswahili",
  };

  static void show(BuildContext context, String currentLocale) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Language", // Your localized title
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Divider(height: 30, thickness: 1),
              _buildLanguageOption(
                context,
                localeCode: 'en',
                isSelected: currentLocale == 'en',
              ),
              const SizedBox(height: 10),
              _buildLanguageOption(
                context,
                localeCode: 'sw',
                isSelected: currentLocale == 'sw',
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildLanguageOption(
    BuildContext context, {
    required String localeCode,
    required bool isSelected,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        MyApp.setLocale(context, Locale(localeCode));
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(_flags[localeCode]!, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _languageNames[localeCode]!,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
