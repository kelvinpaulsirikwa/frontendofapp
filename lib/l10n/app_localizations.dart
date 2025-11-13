import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw'),
  ];

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get chooseLanguage;

  /// No description provided for @welcometoappname.
  ///
  /// In en, this message translates to:
  /// **'Welcome to GestiBora'**
  String get welcometoappname;

  /// No description provided for @readOur.
  ///
  /// In en, this message translates to:
  /// **'Read our '**
  String get readOur;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @tapAgree.
  ///
  /// In en, this message translates to:
  /// **'. Tap \"Agree and continue\" to accept the '**
  String get tapAgree;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// No description provided for @agreeAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Agree And Continue'**
  String get agreeAndContinue;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// No description provided for @emailNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Email not available'**
  String get emailNotAvailable;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @myActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'My Activity'**
  String get myActivityTitle;

  /// No description provided for @currentStaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Stays'**
  String get currentStaysTitle;

  /// No description provided for @currentStaysSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Current stays'**
  String get currentStaysSubtitle;

  /// No description provided for @upcomingBookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Bookings'**
  String get upcomingBookingsTitle;

  /// No description provided for @upcomingBookingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scheduled trips'**
  String get upcomingBookingsSubtitle;

  /// No description provided for @pastStaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Past Stays'**
  String get pastStaysTitle;

  /// No description provided for @pastStaysSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Previous booked trips'**
  String get pastStaysSubtitle;

  /// No description provided for @paymentHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistoryTitle;

  /// No description provided for @paymentHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your payment history'**
  String get paymentHistorySubtitle;

  /// No description provided for @favoritePlacesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorite Places'**
  String get favoritePlacesTitle;

  /// No description provided for @favoritePlacesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No properties saved} =1 {1 property saved} other {{count} properties saved}}'**
  String favoritePlacesCount(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change your language'**
  String get languageSubtitle;

  /// No description provided for @supportAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'Support & About'**
  String get supportAboutTitle;

  /// No description provided for @aboutBnBTitle.
  ///
  /// In en, this message translates to:
  /// **'About Tanzania BnB'**
  String get aboutBnBTitle;

  /// No description provided for @aboutBnBSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn about Tanzania BnB'**
  String get aboutBnBSubtitle;

  /// No description provided for @termsOfServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our terms of service'**
  String get termsOfServiceSubtitle;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(Object version);

  /// No description provided for @missingCustomerIdBookings.
  ///
  /// In en, this message translates to:
  /// **'Unable to load bookings: missing customer id.'**
  String get missingCustomerIdBookings;

  /// No description provided for @missingCustomerIdPastStays.
  ///
  /// In en, this message translates to:
  /// **'Unable to load past stays: missing customer id.'**
  String get missingCustomerIdPastStays;

  /// No description provided for @missingCustomerIdTransactions.
  ///
  /// In en, this message translates to:
  /// **'Unable to load transactions: missing customer id.'**
  String get missingCustomerIdTransactions;

  /// No description provided for @failedToLoadBookings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load bookings'**
  String get failedToLoadBookings;

  /// No description provided for @failedToLoadPastStays.
  ///
  /// In en, this message translates to:
  /// **'Failed to load past stays'**
  String get failedToLoadPastStays;

  /// No description provided for @failedToLoadTransactions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load transactions'**
  String get failedToLoadTransactions;

  /// No description provided for @failedToLoadMoreBookings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load more bookings'**
  String get failedToLoadMoreBookings;

  /// No description provided for @failedToLoadMorePastStays.
  ///
  /// In en, this message translates to:
  /// **'Failed to load more past stays'**
  String get failedToLoadMorePastStays;

  /// No description provided for @failedToLoadMoreTransactions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load more transactions'**
  String get failedToLoadMoreTransactions;

  /// No description provided for @errorLoadingBookings.
  ///
  /// In en, this message translates to:
  /// **'Error loading bookings: {error}'**
  String errorLoadingBookings(Object error);

  /// No description provided for @errorLoadingPastStays.
  ///
  /// In en, this message translates to:
  /// **'Error loading past stays: {error}'**
  String errorLoadingPastStays(Object error);

  /// No description provided for @errorLoadingTransactions.
  ///
  /// In en, this message translates to:
  /// **'Error loading transactions: {error}'**
  String errorLoadingTransactions(Object error);

  /// No description provided for @errorLoadingMoreBookings.
  ///
  /// In en, this message translates to:
  /// **'Error loading more bookings: {error}'**
  String errorLoadingMoreBookings(Object error);

  /// No description provided for @errorLoadingMorePastStays.
  ///
  /// In en, this message translates to:
  /// **'Error loading more past stays: {error}'**
  String errorLoadingMorePastStays(Object error);

  /// No description provided for @errorLoadingMoreTransactions.
  ///
  /// In en, this message translates to:
  /// **'Error loading more transactions: {error}'**
  String errorLoadingMoreTransactions(Object error);

  /// No description provided for @noBookingsFound.
  ///
  /// In en, this message translates to:
  /// **'No Bookings Found'**
  String get noBookingsFound;

  /// No description provided for @noBookingsResponse.
  ///
  /// In en, this message translates to:
  /// **'No bookings were found in the response'**
  String get noBookingsResponse;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No Transactions Found'**
  String get noTransactionsFound;

  /// No description provided for @noTransactionsDescription.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any transaction history'**
  String get noTransactionsDescription;

  /// No description provided for @messageHost.
  ///
  /// In en, this message translates to:
  /// **'Message Host'**
  String get messageHost;

  /// No description provided for @nightCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {{count} night} other {{count} nights}}'**
  String nightCount(int count);

  /// No description provided for @pastBookingsAndStaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Past Bookings and Stays'**
  String get pastBookingsAndStaysTitle;

  /// No description provided for @stayCompleted.
  ///
  /// In en, this message translates to:
  /// **'Stay completed successfully'**
  String get stayCompleted;

  /// No description provided for @transactionHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistoryTitle;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment method: {method}'**
  String paymentMethodLabel(Object method);

  /// No description provided for @referenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference: {reference}'**
  String referenceLabel(Object reference);

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @processedLabel.
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get processedLabel;

  /// No description provided for @createdLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdLabel;

  /// No description provided for @transactionStatusMessage.
  ///
  /// In en, this message translates to:
  /// **'Transaction {status}'**
  String transactionStatusMessage(Object status);

  /// No description provided for @bookingDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetailsTitle;

  /// No description provided for @bookingReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Booking Reference'**
  String get bookingReferenceLabel;

  /// No description provided for @stayDatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Stay Dates'**
  String get stayDatesLabel;

  /// No description provided for @nightsLabel.
  ///
  /// In en, this message translates to:
  /// **'Nights'**
  String get nightsLabel;

  /// No description provided for @stayTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Stay Total'**
  String get stayTotalLabel;

  /// No description provided for @propertySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get propertySectionTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @roomSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get roomSectionTitle;

  /// No description provided for @roomLabel.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get roomLabel;

  /// No description provided for @pricePerNightLabel.
  ///
  /// In en, this message translates to:
  /// **'Price / Night'**
  String get pricePerNightLabel;

  /// No description provided for @guestSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestSectionTitle;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @timeAgoDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {{count}d ago} other {{count}d ago}}'**
  String timeAgoDays(int count);

  /// No description provided for @timeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {{count}h ago} other {{count}h ago}}'**
  String timeAgoHours(int count);

  /// No description provided for @timeAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {{count}m ago} other {{count}m ago}}'**
  String timeAgoMinutes(int count);

  /// No description provided for @timeAgoJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeAgoJustNow;

  /// No description provided for @homeWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Tanzania BnB'**
  String get homeWelcomeTitle;

  /// No description provided for @homeWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover amazing stays'**
  String get homeWelcomeSubtitle;

  /// No description provided for @homeAccommodationTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Accommodation Type'**
  String get homeAccommodationTypeTitle;

  /// No description provided for @homeUnknownType.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get homeUnknownType;

  /// No description provided for @homeNearByTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get homeNearByTitle;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAll;

  /// No description provided for @homePopularDestinationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular Destinations'**
  String get homePopularDestinationsTitle;

  /// No description provided for @homeAllRegions.
  ///
  /// In en, this message translates to:
  /// **'All Regions'**
  String get homeAllRegions;

  /// No description provided for @homeAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get homeAllTypes;

  /// No description provided for @homeLoadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get homeLoadingLabel;

  /// No description provided for @homeNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No data available. Tap refresh to try again.'**
  String get homeNoDataTitle;

  /// No description provided for @favoritePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritePageTitle;

  /// No description provided for @favoriteEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoriteEmptyTitle;

  /// No description provided for @favoriteEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on a stay to save it for later.'**
  String get favoriteEmptyDescription;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Tanzania BnB'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your gateway to authentic stays'**
  String get loginSubtitle;

  /// No description provided for @loginContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginContinueWithGoogle;

  /// No description provided for @loginWhyUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Why Us?'**
  String get loginWhyUsTitle;

  /// No description provided for @loginBenefitSaveFavorites.
  ///
  /// In en, this message translates to:
  /// **'Save your favorite places'**
  String get loginBenefitSaveFavorites;

  /// No description provided for @loginBenefitQuickBooking.
  ///
  /// In en, this message translates to:
  /// **'Quick booking process'**
  String get loginBenefitQuickBooking;

  /// No description provided for @loginBenefitExclusiveDeals.
  ///
  /// In en, this message translates to:
  /// **'Get exclusive deals & updates'**
  String get loginBenefitExclusiveDeals;

  /// No description provided for @loginFooterPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get loginFooterPrefix;

  /// No description provided for @loginFooterTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get loginFooterTerms;

  /// No description provided for @loginFooterAnd.
  ///
  /// In en, this message translates to:
  /// **' & '**
  String get loginFooterAnd;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
