// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get chooseLanguage => 'Swahili';

  @override
  String get welcometoappname => 'Karibu kwenye GestiBora';

  @override
  String get readOur => 'Soma yetu ';

  @override
  String get privacyPolicy => 'Sera ya Faragha';

  @override
  String get tapAgree => '. Gonga \"Kubali na endelea\" kukubaliana na ';

  @override
  String get termsOfService => 'Masharti ya Huduma';

  @override
  String get language => 'Kiswahili';

  @override
  String get agreeAndContinue => 'Kubali na Endelea';

  @override
  String get guestUser => 'Mtumiaji Mgeni';

  @override
  String get emailNotAvailable => 'Barua pepe haipatikani';

  @override
  String get logOut => 'Toka';

  @override
  String get logoutConfirmation => 'Una uhakika unataka kutoka?';

  @override
  String get cancelAction => 'Ghairi';

  @override
  String get myActivityTitle => 'Shughuli Zangu';

  @override
  String get currentStaysTitle => 'Malazi ya Sasa';

  @override
  String get currentStaysSubtitle => 'Malazi yanayoendelea';

  @override
  String get upcomingBookingsTitle => 'Uhifadhi Ujao';

  @override
  String get upcomingBookingsSubtitle => 'Safari zilizopangwa';

  @override
  String get pastStaysTitle => 'Malazi ya Zamani';

  @override
  String get pastStaysSubtitle => 'Safari zilizohifadhiwa awali';

  @override
  String get paymentHistoryTitle => 'Historia ya Malipo';

  @override
  String get paymentHistorySubtitle => 'Tazama historia ya malipo yako';

  @override
  String get favoritePlacesTitle => 'Maeneo Unayopenda';

  @override
  String favoritePlacesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nyumba $count zimehifadhiwa',
      one: 'Nyumba 1 imehifadhiwa',
      zero: 'Hakuna nyumba zilizohifadhiwa',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Mipangilio';

  @override
  String get languageTitle => 'Lugha';

  @override
  String get languageSubtitle => 'Badilisha lugha yako';

  @override
  String get supportAboutTitle => 'Msaada na Kuhusu';

  @override
  String get aboutBnBTitle => 'Kuhusu Tanzania BnB';

  @override
  String get aboutBnBSubtitle => 'Jifunze kuhusu Tanzania BnB';

  @override
  String get termsOfServiceSubtitle => 'Soma masharti ya huduma yetu';

  @override
  String versionLabel(Object version) {
    return 'Toleo $version';
  }

  @override
  String get missingCustomerIdBookings =>
      'Imeshindikana kupakia uhifadhi: kitambulisho cha mteja hakipo.';

  @override
  String get missingCustomerIdPastStays =>
      'Imeshindikana kupakia malazi ya zamani: kitambulisho cha mteja hakipo.';

  @override
  String get missingCustomerIdTransactions =>
      'Imeshindikana kupakia miamala: kitambulisho cha mteja hakipo.';

  @override
  String get failedToLoadBookings => 'Imeshindikana kupakia uhifadhi';

  @override
  String get failedToLoadPastStays => 'Imeshindikana kupakia malazi ya zamani';

  @override
  String get failedToLoadTransactions => 'Imeshindikana kupakia miamala';

  @override
  String get failedToLoadMoreBookings => 'Imeshindikana kupakia uhifadhi zaidi';

  @override
  String get failedToLoadMorePastStays =>
      'Imeshindikana kupakia malazi ya zamani zaidi';

  @override
  String get failedToLoadMoreTransactions =>
      'Imeshindikana kupakia miamala zaidi';

  @override
  String errorLoadingBookings(Object error) {
    return 'Hitilafu wakati wa kupakia uhifadhi: $error';
  }

  @override
  String errorLoadingPastStays(Object error) {
    return 'Hitilafu wakati wa kupakia malazi ya zamani: $error';
  }

  @override
  String errorLoadingTransactions(Object error) {
    return 'Hitilafu wakati wa kupakia miamala: $error';
  }

  @override
  String errorLoadingMoreBookings(Object error) {
    return 'Hitilafu wakati wa kupakia uhifadhi zaidi: $error';
  }

  @override
  String errorLoadingMorePastStays(Object error) {
    return 'Hitilafu wakati wa kupakia malazi ya zamani zaidi: $error';
  }

  @override
  String errorLoadingMoreTransactions(Object error) {
    return 'Hitilafu wakati wa kupakia miamala zaidi: $error';
  }

  @override
  String get noBookingsFound => 'Hakuna uhifadhi uliopatikana';

  @override
  String get noBookingsResponse => 'Hakuna uhifadhi uliopatikana kwenye majibu';

  @override
  String get noTransactionsFound => 'Hakuna miamala iliyopatikana';

  @override
  String get noTransactionsDescription => 'Huna historia yoyote ya miamala';

  @override
  String get messageHost => 'Tuma ujumbe kwa mwenyeji';

  @override
  String nightCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Usiku $count',
      one: 'Usiku $count',
    );
    return '$_temp0';
  }

  @override
  String get pastBookingsAndStaysTitle => 'Uhifadhi na Malazi ya Zamani';

  @override
  String get stayCompleted => 'Malazi yalikamilika kwa mafanikio';

  @override
  String get transactionHistoryTitle => 'Historia ya Miamala';

  @override
  String paymentMethodLabel(Object method) {
    return 'Njia ya malipo: $method';
  }

  @override
  String referenceLabel(Object reference) {
    return 'Rejea: $reference';
  }

  @override
  String get amountLabel => 'Kiasi';

  @override
  String get processedLabel => 'Imechakatwa';

  @override
  String get createdLabel => 'Imeundwa';

  @override
  String transactionStatusMessage(Object status) {
    return 'Muamala $status';
  }

  @override
  String get bookingDetailsTitle => 'Maelezo ya Uhifadhi';

  @override
  String get bookingReferenceLabel => 'Rejea ya Uhifadhi';

  @override
  String get stayDatesLabel => 'Tarehe za Kukaa';

  @override
  String get nightsLabel => 'Usiku';

  @override
  String get stayTotalLabel => 'Jumla ya Malazi';

  @override
  String get propertySectionTitle => 'Mali';

  @override
  String get nameLabel => 'Jina';

  @override
  String get emailLabel => 'Barua pepe';

  @override
  String get addressLabel => 'Anwani';

  @override
  String get roomSectionTitle => 'Chumba';

  @override
  String get roomLabel => 'Chumba';

  @override
  String get pricePerNightLabel => 'Bei kwa Usiku';

  @override
  String get guestSectionTitle => 'Mgeni';

  @override
  String get phoneLabel => 'Simu';

  @override
  String timeAgoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'siku $count zilizopita',
      one: 'siku $count zilizopita',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'saa $count zilizopita',
      one: 'saa $count zilizopita',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dakika $count zilizopita',
      one: 'dakika $count zilizopita',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoJustNow => 'Sasa hivi';

  @override
  String get homeWelcomeTitle => 'Karibu Kwa FBC';

  @override
  String get homeWelcomeSubtitle => 'Tabasamu lako, tabasamu letu.';

  @override
  String get homeAccommodationTypeTitle => 'Aina ya Malazi';

  @override
  String get homeUnknownType => 'Haijulikani';

  @override
  String get homeNearByTitle => 'Karibu';

  @override
  String get homeViewAll => 'Tazama yote';

  @override
  String get homePopularDestinationsTitle => 'Maeneo Maarufu';

  @override
  String get homeAllRegions => 'Mikoa Yote';

  @override
  String get homeAllTypes => 'Aina Zote';

  @override
  String get homeLoadingLabel => 'Inapakia...';

  @override
  String get homeNoDataTitle => 'Hakuna data. Gusa upya kujaribu tena.';

  @override
  String get favoritePageTitle => 'Vipendwa Vyako';

  @override
  String get favoriteEmptyTitle => 'Bado hakuna vipendwa';

  @override
  String get favoriteEmptyDescription =>
      'Gonga ikoni ya moyo kwenye malazi uyapendayo ili kuyaokoa kwa baadaye.';

  @override
  String get loginTitle => 'BnB';

  @override
  String get loginSubtitle => 'Mlango wako wa malazi halisi';

  @override
  String get loginContinueWithGoogle => 'Endelea kwa Google';

  @override
  String get loginWhyUsTitle => 'Kwa nini sisi?';

  @override
  String get loginBenefitSaveFavorites => 'Hifadhi maeneo unayoyapenda';

  @override
  String get loginBenefitQuickBooking => 'Mchakato wa kuhifadhi kwa haraka';

  @override
  String get loginBenefitExclusiveDeals => 'Pata ofa maalum na masasisho';

  @override
  String get loginFooterPrefix => 'Kwa kuendelea, unakubali ';

  @override
  String get loginFooterTerms => 'Masharti';

  @override
  String get loginFooterAnd => ' na ';
}
