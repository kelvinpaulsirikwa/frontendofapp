// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get chooseLanguage => 'English';

  @override
  String get welcometoappname => 'Welcome to GestiBora';

  @override
  String get readOur => 'Read our ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get tapAgree => '. Tap \"Agree and continue\" to accept the ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get language => 'English';

  @override
  String get agreeAndContinue => 'Agree And Continue';

  @override
  String get guestUser => 'Guest User';

  @override
  String get emailNotAvailable => 'Email not available';

  @override
  String get logOut => 'Log Out';

  @override
  String get logoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get myActivityTitle => 'My Activity';

  @override
  String get currentStaysTitle => 'Current Stays';

  @override
  String get currentStaysSubtitle => 'Current stays';

  @override
  String get upcomingBookingsTitle => 'Upcoming Bookings';

  @override
  String get upcomingBookingsSubtitle => 'Scheduled trips';

  @override
  String get pastStaysTitle => 'Past Stays';

  @override
  String get pastStaysSubtitle => 'Previous booked trips';

  @override
  String get paymentHistoryTitle => 'Payment History';

  @override
  String get paymentHistorySubtitle => 'View your payment history';

  @override
  String get favoritePlacesTitle => 'Favorite Places';

  @override
  String favoritePlacesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count properties saved',
      one: '1 property saved',
      zero: 'No properties saved',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'Change your language';

  @override
  String get supportAboutTitle => 'Support & About';

  @override
  String get aboutBnBTitle => 'About Tanzania BnB';

  @override
  String get aboutBnBSubtitle => 'Learn about Tanzania BnB';

  @override
  String get termsOfServiceSubtitle => 'Read our terms of service';

  @override
  String versionLabel(Object version) {
    return 'Version $version';
  }

  @override
  String get missingCustomerIdBookings =>
      'Unable to load bookings: missing customer id.';

  @override
  String get missingCustomerIdPastStays =>
      'Unable to load past stays: missing customer id.';

  @override
  String get missingCustomerIdTransactions =>
      'Unable to load transactions: missing customer id.';

  @override
  String get failedToLoadBookings => 'Failed to load bookings';

  @override
  String get failedToLoadPastStays => 'Failed to load past stays';

  @override
  String get failedToLoadTransactions => 'Failed to load transactions';

  @override
  String get failedToLoadMoreBookings => 'Failed to load more bookings';

  @override
  String get failedToLoadMorePastStays => 'Failed to load more past stays';

  @override
  String get failedToLoadMoreTransactions => 'Failed to load more transactions';

  @override
  String errorLoadingBookings(Object error) {
    return 'Error loading bookings: $error';
  }

  @override
  String errorLoadingPastStays(Object error) {
    return 'Error loading past stays: $error';
  }

  @override
  String errorLoadingTransactions(Object error) {
    return 'Error loading transactions: $error';
  }

  @override
  String errorLoadingMoreBookings(Object error) {
    return 'Error loading more bookings: $error';
  }

  @override
  String errorLoadingMorePastStays(Object error) {
    return 'Error loading more past stays: $error';
  }

  @override
  String errorLoadingMoreTransactions(Object error) {
    return 'Error loading more transactions: $error';
  }

  @override
  String get noBookingsFound => 'No Bookings Found';

  @override
  String get noBookingsResponse => 'No bookings were found in the response';

  @override
  String get noTransactionsFound => 'No Transactions Found';

  @override
  String get noTransactionsDescription =>
      'You don\'t have any transaction history';

  @override
  String get messageHost => 'Message Host';

  @override
  String nightCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nights',
      one: '$count night',
    );
    return '$_temp0';
  }

  @override
  String get pastBookingsAndStaysTitle => 'Past Bookings and Stays';

  @override
  String get stayCompleted => 'Stay completed successfully';

  @override
  String get transactionHistoryTitle => 'Transaction History';

  @override
  String paymentMethodLabel(Object method) {
    return 'Payment method: $method';
  }

  @override
  String referenceLabel(Object reference) {
    return 'Reference: $reference';
  }

  @override
  String get amountLabel => 'Amount';

  @override
  String get processedLabel => 'Processed';

  @override
  String get createdLabel => 'Created';

  @override
  String transactionStatusMessage(Object status) {
    return 'Transaction $status';
  }

  @override
  String get bookingDetailsTitle => 'Booking Details';

  @override
  String get bookingReferenceLabel => 'Booking Reference';

  @override
  String get stayDatesLabel => 'Stay Dates';

  @override
  String get nightsLabel => 'Nights';

  @override
  String get stayTotalLabel => 'Stay Total';

  @override
  String get propertySectionTitle => 'Property';

  @override
  String get nameLabel => 'Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get addressLabel => 'Address';

  @override
  String get roomSectionTitle => 'Room';

  @override
  String get roomLabel => 'Room';

  @override
  String get pricePerNightLabel => 'Price / Night';

  @override
  String get guestSectionTitle => 'Guest';

  @override
  String get phoneLabel => 'Phone';

  @override
  String timeAgoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}d ago',
      one: '${count}d ago',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}h ago',
      one: '${count}h ago',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}m ago',
      one: '${count}m ago',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoJustNow => 'Just now';

  @override
  String get homeWelcomeTitle => 'Welcome to Tanzania BnB';

  @override
  String get homeWelcomeSubtitle => 'Discover amazing stays';

  @override
  String get homeAccommodationTypeTitle => 'Accommodation Type';

  @override
  String get homeUnknownType => 'Unknown';

  @override
  String get homeNearByTitle => 'Nearby';

  @override
  String get homeViewAll => 'View all';

  @override
  String get homePopularDestinationsTitle => 'Popular Destinations';

  @override
  String get homeAllRegions => 'All Regions';

  @override
  String get homeAllTypes => 'All Types';

  @override
  String get homeLoadingLabel => 'Loading...';

  @override
  String get homeNoDataTitle => 'No data available. Tap refresh to try again.';

  @override
  String get favoritePageTitle => 'Favorites';

  @override
  String get favoriteEmptyTitle => 'No favorites yet';

  @override
  String get favoriteEmptyDescription =>
      'Tap the heart icon on a stay to save it for later.';

  @override
  String get loginTitle => 'Tanzania BnB';

  @override
  String get loginSubtitle => 'Your gateway to authentic stays';

  @override
  String get loginContinueWithGoogle => 'Continue with Google';

  @override
  String get loginWhyUsTitle => 'Why Us?';

  @override
  String get loginBenefitSaveFavorites => 'Save your favorite places';

  @override
  String get loginBenefitQuickBooking => 'Quick booking process';

  @override
  String get loginBenefitExclusiveDeals => 'Get exclusive deals & updates';

  @override
  String get loginFooterPrefix => 'By continuing, you agree to our ';

  @override
  String get loginFooterTerms => 'Terms';

  @override
  String get loginFooterAnd => ' & ';
}
