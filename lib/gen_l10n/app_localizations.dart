import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AgroPilot AI'**
  String get appName;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @sensors.
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get sensors;

  /// No description provided for @yieldPrediction.
  ///
  /// In en, this message translates to:
  /// **'Yield Prediction'**
  String get yieldPrediction;

  /// No description provided for @harvestLog.
  ///
  /// In en, this message translates to:
  /// **'Harvest Log'**
  String get harvestLog;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @farmerProfile.
  ///
  /// In en, this message translates to:
  /// **'Farmer Profile'**
  String get farmerProfile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @co2.
  ///
  /// In en, this message translates to:
  /// **'CO₂ Level'**
  String get co2;

  /// No description provided for @soilMoisture.
  ///
  /// In en, this message translates to:
  /// **'Soil Moisture'**
  String get soilMoisture;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light Intensity'**
  String get light;

  /// No description provided for @ph.
  ///
  /// In en, this message translates to:
  /// **'Soil pH'**
  String get ph;

  /// No description provided for @predictedYield.
  ///
  /// In en, this message translates to:
  /// **'Predicted Yield'**
  String get predictedYield;

  /// No description provided for @targetYield.
  ///
  /// In en, this message translates to:
  /// **'Target Yield'**
  String get targetYield;

  /// No description provided for @yieldGap.
  ///
  /// In en, this message translates to:
  /// **'Yield Gap'**
  String get yieldGap;

  /// No description provided for @totalHarvest.
  ///
  /// In en, this message translates to:
  /// **'Total Harvest'**
  String get totalHarvest;

  /// No description provided for @alertLevel.
  ///
  /// In en, this message translates to:
  /// **'Alert Level'**
  String get alertLevel;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @cropType.
  ///
  /// In en, this message translates to:
  /// **'Crop Type'**
  String get cropType;

  /// No description provided for @daysPlanted.
  ///
  /// In en, this message translates to:
  /// **'Days Planted'**
  String get daysPlanted;

  /// No description provided for @growthStage.
  ///
  /// In en, this message translates to:
  /// **'Growth Stage'**
  String get growthStage;

  /// No description provided for @soilType.
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get soilType;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @farmSize.
  ///
  /// In en, this message translates to:
  /// **'Farm Size'**
  String get farmSize;

  /// No description provided for @harvestDate.
  ///
  /// In en, this message translates to:
  /// **'Harvest Date'**
  String get harvestDate;

  /// No description provided for @quantityHarvested.
  ///
  /// In en, this message translates to:
  /// **'Quantity Harvested'**
  String get quantityHarvested;

  /// No description provided for @pricePerKg.
  ///
  /// In en, this message translates to:
  /// **'Price per kg'**
  String get pricePerKg;

  /// No description provided for @totalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total Earned'**
  String get totalEarned;

  /// No description provided for @whereSold.
  ///
  /// In en, this message translates to:
  /// **'Where Sold'**
  String get whereSold;

  /// No description provided for @grade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get grade;

  /// No description provided for @harvestType.
  ///
  /// In en, this message translates to:
  /// **'Harvest Type'**
  String get harvestType;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @saveRecord.
  ///
  /// In en, this message translates to:
  /// **'Save Harvest Record'**
  String get saveRecord;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No harvest records yet'**
  String get noRecords;

  /// No description provided for @earningsChart.
  ///
  /// In en, this message translates to:
  /// **'Earnings Per Harvest Cycle'**
  String get earningsChart;

  /// No description provided for @quantityChart.
  ///
  /// In en, this message translates to:
  /// **'Harvest Quantity Trend'**
  String get quantityChart;

  /// No description provided for @gradeChart.
  ///
  /// In en, this message translates to:
  /// **'Quality Grade Distribution'**
  String get gradeChart;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @tempHigh.
  ///
  /// In en, this message translates to:
  /// **'Temperature is too high'**
  String get tempHigh;

  /// No description provided for @tempLow.
  ///
  /// In en, this message translates to:
  /// **'Temperature is too low'**
  String get tempLow;

  /// No description provided for @humidHigh.
  ///
  /// In en, this message translates to:
  /// **'Humidity is too high'**
  String get humidHigh;

  /// No description provided for @moistureLow.
  ///
  /// In en, this message translates to:
  /// **'Soil moisture is too low'**
  String get moistureLow;

  /// No description provided for @phAlert.
  ///
  /// In en, this message translates to:
  /// **'Soil pH is out of range'**
  String get phAlert;

  /// No description provided for @fixNow.
  ///
  /// In en, this message translates to:
  /// **'Fix Now'**
  String get fixNow;

  /// No description provided for @monitor.
  ///
  /// In en, this message translates to:
  /// **'Monitor'**
  String get monitor;

  /// No description provided for @allGood.
  ///
  /// In en, this message translates to:
  /// **'All conditions are optimal'**
  String get allGood;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @liveSensors.
  ///
  /// In en, this message translates to:
  /// **'Live Sensors'**
  String get liveSensors;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All →'**
  String get viewAll;

  /// No description provided for @alertsAndActions.
  ///
  /// In en, this message translates to:
  /// **'Alerts & Actions'**
  String get alertsAndActions;

  /// No description provided for @allSensorsGood.
  ///
  /// In en, this message translates to:
  /// **'All sensors within ideal range 🎉'**
  String get allSensorsGood;

  /// No description provided for @viewHistoryReports.
  ///
  /// In en, this message translates to:
  /// **'View History & Reports'**
  String get viewHistoryReports;

  /// No description provided for @sensorDetails.
  ///
  /// In en, this message translates to:
  /// **'Sensor Details'**
  String get sensorDetails;

  /// No description provided for @last24Hours.
  ///
  /// In en, this message translates to:
  /// **'Last 24 Hours'**
  String get last24Hours;

  /// No description provided for @actual.
  ///
  /// In en, this message translates to:
  /// **'Actual'**
  String get actual;

  /// No description provided for @idealRangeMid.
  ///
  /// In en, this message translates to:
  /// **'Ideal Range Mid'**
  String get idealRangeMid;

  /// No description provided for @minimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimum;

  /// No description provided for @maximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get maximum;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @yieldForecast.
  ///
  /// In en, this message translates to:
  /// **'Yield Forecast'**
  String get yieldForecast;

  /// No description provided for @viewFullPrediction.
  ///
  /// In en, this message translates to:
  /// **'View Full Prediction →'**
  String get viewFullPrediction;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @gap.
  ///
  /// In en, this message translates to:
  /// **'Gap'**
  String get gap;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'Days Left'**
  String get daysLeft;

  /// No description provided for @featureImportance.
  ///
  /// In en, this message translates to:
  /// **'📊 Feature Importance (SHAP)'**
  String get featureImportance;

  /// No description provided for @weekComparison.
  ///
  /// In en, this message translates to:
  /// **'📆 Week on Week Comparison'**
  String get weekComparison;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// No description provided for @trend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trend;

  /// No description provided for @allHarvestEntries.
  ///
  /// In en, this message translates to:
  /// **'All Harvest Entries'**
  String get allHarvestEntries;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get newEntry;

  /// No description provided for @harvestDetails.
  ///
  /// In en, this message translates to:
  /// **'Harvest Details'**
  String get harvestDetails;

  /// No description provided for @newHarvestEntry.
  ///
  /// In en, this message translates to:
  /// **'New Harvest Entry'**
  String get newHarvestEntry;

  /// No description provided for @recordYourHarvest.
  ///
  /// In en, this message translates to:
  /// **'Record Your Harvest'**
  String get recordYourHarvest;

  /// No description provided for @fillDetails.
  ///
  /// In en, this message translates to:
  /// **'Fill in all details below'**
  String get fillDetails;

  /// No description provided for @dateOfHarvest.
  ///
  /// In en, this message translates to:
  /// **'📅 Date of Harvest'**
  String get dateOfHarvest;

  /// No description provided for @sellingPricePerKg.
  ///
  /// In en, this message translates to:
  /// **'💰 Selling Price per kg'**
  String get sellingPricePerKg;

  /// No description provided for @totalAmountReceived.
  ///
  /// In en, this message translates to:
  /// **'🏆 Total Amount Received'**
  String get totalAmountReceived;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'📝 Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @autoCalculated.
  ///
  /// In en, this message translates to:
  /// **'Auto calculated'**
  String get autoCalculated;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @homeDashboard.
  ///
  /// In en, this message translates to:
  /// **'Home Dashboard'**
  String get homeDashboard;

  /// No description provided for @historyReports.
  ///
  /// In en, this message translates to:
  /// **'History & Reports'**
  String get historyReports;

  /// No description provided for @aiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get aiAnalysis;

  /// No description provided for @cropConfiguration.
  ///
  /// In en, this message translates to:
  /// **'🌿 Crop Configuration'**
  String get cropConfiguration;

  /// No description provided for @pidSetpoints.
  ///
  /// In en, this message translates to:
  /// **'⚙️ PID Setpoints (Read-Only)'**
  String get pidSetpoints;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'🔔 Notifications'**
  String get notificationsTitle;

  /// No description provided for @criticalAlerts.
  ///
  /// In en, this message translates to:
  /// **'Critical Alerts'**
  String get criticalAlerts;

  /// No description provided for @criticalAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Immediately notify on critical sensor values'**
  String get criticalAlertsSubtitle;

  /// No description provided for @dailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily Summary'**
  String get dailySummary;

  /// No description provided for @dailySummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get daily crop health report at 8 AM'**
  String get dailySummarySubtitle;

  /// No description provided for @harvestReminder.
  ///
  /// In en, this message translates to:
  /// **'Harvest Reminder'**
  String get harvestReminder;

  /// No description provided for @harvestReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notify 3 days before estimated harvest date'**
  String get harvestReminderSubtitle;

  /// No description provided for @estHarvest.
  ///
  /// In en, this message translates to:
  /// **'Est. Harvest:'**
  String get estHarvest;

  /// No description provided for @daysLeftSuffix.
  ///
  /// In en, this message translates to:
  /// **'days left'**
  String get daysLeftSuffix;

  /// No description provided for @deleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry?'**
  String get deleteEntry;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'This record will be permanently deleted.'**
  String get deleteConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @addFirstEntry.
  ///
  /// In en, this message translates to:
  /// **'Add First Entry'**
  String get addFirstEntry;

  /// No description provided for @startByAdding.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first harvest entry.'**
  String get startByAdding;

  /// No description provided for @entryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get entryDeleted;

  /// No description provided for @totalHarvested.
  ///
  /// In en, this message translates to:
  /// **'Total Harvested'**
  String get totalHarvested;

  /// No description provided for @avgPrice.
  ///
  /// In en, this message translates to:
  /// **'Avg Price'**
  String get avgPrice;

  /// No description provided for @earningsChartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Total amount earned (₹) per harvest'**
  String get earningsChartSubtitle;

  /// No description provided for @quantityChartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quantity harvested (kg) over time'**
  String get quantityChartSubtitle;

  /// No description provided for @gradeChartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Percentage of each quality grade'**
  String get gradeChartSubtitle;

  /// No description provided for @addEntriesToSeeCharts.
  ///
  /// In en, this message translates to:
  /// **'Add harvest entries to see your earnings charts.'**
  String get addEntriesToSeeCharts;

  /// No description provided for @aiAccuracy.
  ///
  /// In en, this message translates to:
  /// **'AgroPilot AI Accuracy'**
  String get aiAccuracy;

  /// No description provided for @predicted.
  ///
  /// In en, this message translates to:
  /// **'Predicted'**
  String get predicted;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @smartInsights.
  ///
  /// In en, this message translates to:
  /// **'Smart Insights'**
  String get smartInsights;

  /// No description provided for @dataPoints.
  ///
  /// In en, this message translates to:
  /// **'Data Points'**
  String get dataPoints;

  /// No description provided for @totalAlerts.
  ///
  /// In en, this message translates to:
  /// **'Total Alerts'**
  String get totalAlerts;

  /// No description provided for @yieldTrend.
  ///
  /// In en, this message translates to:
  /// **'Yield Trend'**
  String get yieldTrend;

  /// No description provided for @keyInsights.
  ///
  /// In en, this message translates to:
  /// **'💡 Key Insights'**
  String get keyInsights;

  /// No description provided for @temperatureStability.
  ///
  /// In en, this message translates to:
  /// **'Temperature Stability'**
  String get temperatureStability;

  /// No description provided for @soilMoistureConcern.
  ///
  /// In en, this message translates to:
  /// **'Soil Moisture Concern'**
  String get soilMoistureConcern;

  /// No description provided for @co2Trend.
  ///
  /// In en, this message translates to:
  /// **'CO₂ Trend'**
  String get co2Trend;

  /// No description provided for @yieldForecastInsight.
  ///
  /// In en, this message translates to:
  /// **'Yield Forecast'**
  String get yieldForecastInsight;

  /// No description provided for @llmExportTitle.
  ///
  /// In en, this message translates to:
  /// **'🧠 LLM Training Data Export'**
  String get llmExportTitle;

  /// No description provided for @llmExportDesc.
  ///
  /// In en, this message translates to:
  /// **'Export readings as structured JSON for LLM training or analysis'**
  String get llmExportDesc;

  /// No description provided for @showCopyJson.
  ///
  /// In en, this message translates to:
  /// **'Show & Copy JSON'**
  String get showCopyJson;

  /// No description provided for @hideJson.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hideJson;

  /// No description provided for @jsonCopied.
  ///
  /// In en, this message translates to:
  /// **'JSON copied to clipboard!'**
  String get jsonCopied;

  /// No description provided for @alertStats.
  ///
  /// In en, this message translates to:
  /// **'📊 Alert Statistics (30 Days)'**
  String get alertStats;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @liveBadge.
  ///
  /// In en, this message translates to:
  /// **'🔴 Live'**
  String get liveBadge;

  /// No description provided for @demoBadge.
  ///
  /// In en, this message translates to:
  /// **'🟡 Demo'**
  String get demoBadge;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'hi',
    'kn',
    'ml',
    'mr',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
