import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// Application name shown as the window/task title and on the home app bar
  ///
  /// In en, this message translates to:
  /// **'Rent Book'**
  String get appTitle;

  /// Label of the cancel button in dialogs
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Label of the save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Label of the delete button and tooltip of the delete icon
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Tooltip of the edit icon
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// Status label for a bill that has been paid
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get commonPaid;

  /// Status label for a bill that has not been paid
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get commonUnpaid;

  /// Placeholder shown when the tenant of a bill no longer exists
  ///
  /// In en, this message translates to:
  /// **'(Tenant deleted)'**
  String get commonTenantDeleted;

  /// Received amount shown in list headers
  ///
  /// In en, this message translates to:
  /// **'Received {amount}'**
  String commonReceivedAmount(String amount);

  /// Outstanding amount shown in statistics
  ///
  /// In en, this message translates to:
  /// **'Unpaid {amount}'**
  String commonUnpaidAmount(String amount);

  /// Tooltip of the visibility icon when the password is hidden
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get passwordShowTooltip;

  /// Tooltip of the visibility icon when the password is visible
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get passwordHideTooltip;

  /// Validation error when the password is too short
  ///
  /// In en, this message translates to:
  /// **'At least {count} characters'**
  String passwordMinLengthError(int count);

  /// Snack bar shown when the two password entries differ
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match'**
  String get passwordMismatch;

  /// Fee label for the monthly rent
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get feeRent;

  /// Fee label for the monthly property management fee
  ///
  /// In en, this message translates to:
  /// **'Property fee'**
  String get feeProperty;

  /// Fee label for the water charge
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get feeWater;

  /// Fee label for the electricity charge
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get feeElectricity;

  /// Fee label for the gas charge
  ///
  /// In en, this message translates to:
  /// **'Gas'**
  String get feeGas;

  /// Compact fee breakdown shown in bill lists
  ///
  /// In en, this message translates to:
  /// **'Rent {rent} · Property fee {propertyFee} · Utilities {utilities}'**
  String billFeeSummary(String rent, String propertyFee, String utilities);

  /// Title of the unlock screen
  ///
  /// In en, this message translates to:
  /// **'Rent Book is locked'**
  String get lockViewTitle;

  /// Label of the password field on the unlock screen
  ///
  /// In en, this message translates to:
  /// **'Enter startup password'**
  String get lockViewPasswordLabel;

  /// Validation error when the password field is empty on the unlock screen
  ///
  /// In en, this message translates to:
  /// **'Please enter the password'**
  String get lockViewPasswordRequired;

  /// Label of the unlock button while the password is being verified
  ///
  /// In en, this message translates to:
  /// **'Verifying…'**
  String get lockViewVerifying;

  /// Label of the unlock button
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockViewUnlock;

  /// Link label to start the password reset flow
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get lockViewForgotPassword;

  /// Snack bar shown after a failed unlock attempt
  ///
  /// In en, this message translates to:
  /// **'Wrong password, please try again'**
  String get lockViewWrongPassword;

  /// Title of the first-run password setup screen
  ///
  /// In en, this message translates to:
  /// **'Set a startup password'**
  String get setPasswordTitle;

  /// Subtitle of the first-run password setup screen
  ///
  /// In en, this message translates to:
  /// **'Protects your rent records; you will need to enter it next time'**
  String get setPasswordSubtitle;

  /// Label of the first password field on the setup screen
  ///
  /// In en, this message translates to:
  /// **'Set a password (at least {count} characters)'**
  String setPasswordFieldLabel(int count);

  /// Label of the confirmation password field on the setup screen
  ///
  /// In en, this message translates to:
  /// **'Enter it again to confirm'**
  String get setPasswordConfirmLabel;

  /// Label of the submit button on the password setup screen
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get setPasswordSubmit;

  /// Title of the change-password screen and of its entry in the home menu
  ///
  /// In en, this message translates to:
  /// **'Change startup password'**
  String get changePasswordTitle;

  /// Label of the current password field
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get changePasswordOldLabel;

  /// Validation error when the current password field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter the current password'**
  String get changePasswordOldRequired;

  /// Label of the new password field
  ///
  /// In en, this message translates to:
  /// **'New password (at least {count} characters)'**
  String changePasswordNewLabel(int count);

  /// Label of the new password confirmation field
  ///
  /// In en, this message translates to:
  /// **'Enter the new password again'**
  String get changePasswordConfirmLabel;

  /// Validation error when the two new password entries differ
  ///
  /// In en, this message translates to:
  /// **'The new passwords do not match'**
  String get changePasswordMismatch;

  /// Snack bar shown when the current password is wrong
  ///
  /// In en, this message translates to:
  /// **'The current password is incorrect'**
  String get changePasswordOldIncorrect;

  /// Snack bar shown when the new password equals the current one
  ///
  /// In en, this message translates to:
  /// **'The new password must differ from the current one'**
  String get changePasswordSameAsOld;

  /// Snack bar shown after the password was changed successfully
  ///
  /// In en, this message translates to:
  /// **'Startup password updated ✓'**
  String get changePasswordSuccess;

  /// Label of the submit button on the change-password screen
  ///
  /// In en, this message translates to:
  /// **'Confirm change'**
  String get changePasswordSubmit;

  /// Hint text shown below the change-password form
  ///
  /// In en, this message translates to:
  /// **'Note: the new password must differ from the current one, and both entries must match.'**
  String get changePasswordHint;

  /// Body of the confirmation dialog for forgetting the password
  ///
  /// In en, this message translates to:
  /// **'This will erase the startup password and all tenant and bill data, and the app will return to its first-run state. This cannot be undone.'**
  String get passwordGateResetMessage;

  /// Label of the destructive button in the forget-password dialog
  ///
  /// In en, this message translates to:
  /// **'Erase and start over'**
  String get passwordGateResetConfirm;

  /// Tooltip of the overflow menu button on the home screen
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get homeMoreTooltip;

  /// Label of the floating action button on the home screen
  ///
  /// In en, this message translates to:
  /// **'Add a bill'**
  String get homeAddBill;

  /// Empty state message when no tenant exists
  ///
  /// In en, this message translates to:
  /// **'No tenants yet — add one first'**
  String get homeEmptyTenants;

  /// Label of the button that opens the tenant management screen from the empty state
  ///
  /// In en, this message translates to:
  /// **'Add tenant'**
  String get homeAddTenant;

  /// Tooltip of the button that goes to the previous month
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get homePreviousMonth;

  /// Tooltip of the button that goes to the next month
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get homeNextMonth;

  /// Label of the button that jumps back to the current month
  ///
  /// In en, this message translates to:
  /// **'Back to this month'**
  String get homeBackToThisMonth;

  /// Label of the total amount due in the monthly summary card
  ///
  /// In en, this message translates to:
  /// **'Total due this month'**
  String get homeMonthlyReceivable;

  /// Collection progress shown in the monthly summary card
  ///
  /// In en, this message translates to:
  /// **'{paid}/{recorded} received · {total} tenants'**
  String homeCollectionSummary(int paid, int recorded, int total);

  /// Subtitle of a tenant card for a month without a bill
  ///
  /// In en, this message translates to:
  /// **'Not recorded · fixed rent {rent} + property fee {propertyFee}'**
  String homeNotRecorded(String rent, String propertyFee);

  /// Amount placeholder of a tenant card for a month without a bill
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get homePending;

  /// Snack bar shown when adding a bill without any tenant
  ///
  /// In en, this message translates to:
  /// **'Please add a tenant first'**
  String get homeAddTenantFirst;

  /// Title of the bottom sheet that asks which tenant the bill belongs to
  ///
  /// In en, this message translates to:
  /// **'Choose a tenant'**
  String get homePickTenantTitle;

  /// Title of the history screen
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// Empty state message of the history screen
  ///
  /// In en, this message translates to:
  /// **'No bills yet'**
  String get historyEmpty;

  /// Total amount of one month group in the history list
  ///
  /// In en, this message translates to:
  /// **'Total {amount}'**
  String historyMonthTotal(String amount);

  /// Suffix appended to the tenant title in the history list when the bill is paid
  ///
  /// In en, this message translates to:
  /// **' · Paid ✓'**
  String get historyPaidSuffix;

  /// Title of the statistics screen
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// Empty state message of the statistics screen
  ///
  /// In en, this message translates to:
  /// **'No bills yet — add one first'**
  String get statsEmpty;

  /// Title of the accumulated summary card
  ///
  /// In en, this message translates to:
  /// **'Total due / received'**
  String get statsSummaryTitle;

  /// Label of the total amount that is due
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get statsReceivable;

  /// Collection rate shown below the progress bar
  ///
  /// In en, this message translates to:
  /// **'Collection rate {rate}%'**
  String statsCollectionRate(String rate);

  /// Title of the 12-month bar chart card
  ///
  /// In en, this message translates to:
  /// **'Due over the last 12 months'**
  String get statsMonthlyTrendTitle;

  /// Tooltip of a bar in the 12-month chart
  ///
  /// In en, this message translates to:
  /// **'Received {paid}\nUnpaid {unpaid}'**
  String statsChartTooltip(String paid, String unpaid);

  /// Title of the fee category pie chart card
  ///
  /// In en, this message translates to:
  /// **'Fee breakdown'**
  String get statsCategoryTitle;

  /// Fee category card title when there is nothing to show
  ///
  /// In en, this message translates to:
  /// **'Fee breakdown (no data)'**
  String get statsCategoryEmpty;

  /// Title of the per-tenant ranking card
  ///
  /// In en, this message translates to:
  /// **'Total due by tenant'**
  String get statsTenantRankingTitle;

  /// Per-tenant ranking card title when there is nothing to show
  ///
  /// In en, this message translates to:
  /// **'Total due by tenant (no data)'**
  String get statsTenantRankingEmpty;

  /// Title of the tenant management screen
  ///
  /// In en, this message translates to:
  /// **'Tenants'**
  String get tenantsTitle;

  /// Label of the add-tenant button and title of the add-tenant dialog
  ///
  /// In en, this message translates to:
  /// **'Add tenant'**
  String get tenantsAdd;

  /// Empty state message of the tenant management screen
  ///
  /// In en, this message translates to:
  /// **'No tenants — tap the button below to add one'**
  String get tenantsEmpty;

  /// Fixed monthly fees shown in a tenant list tile
  ///
  /// In en, this message translates to:
  /// **'Rent {rent} / month · Property fee {propertyFee} / month'**
  String tenantsFeeSummary(String rent, String propertyFee);

  /// Title of the delete-tenant confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete tenant'**
  String get tenantsDeleteTitle;

  /// Body of the delete-tenant dialog when the tenant still has bills
  ///
  /// In en, this message translates to:
  /// **'This will also delete {count, plural, =1{1 bill record} other{{count} bill records}} for {room} {name}. Continue?'**
  String tenantsDeleteWithBillsMessage(String room, String name, int count);

  /// Body of the delete-tenant dialog when the tenant has no bills
  ///
  /// In en, this message translates to:
  /// **'Delete {room} {name}?'**
  String tenantsDeleteMessage(String room, String name);

  /// Snack bar shown after a tenant was deleted
  ///
  /// In en, this message translates to:
  /// **'Deleted {room} {name}'**
  String tenantsDeleted(String room, String name);

  /// Suffix appended to the delete confirmation when bills were removed too
  ///
  /// In en, this message translates to:
  /// **' and {count} bill records'**
  String tenantsDeletedWithBillsSuffix(int count);

  /// Snack bar shown after a tenant was created
  ///
  /// In en, this message translates to:
  /// **'Added {room} {name}'**
  String tenantsAdded(String room, String name);

  /// Snack bar shown after a tenant was edited
  ///
  /// In en, this message translates to:
  /// **'Saved changes to {room} {name}'**
  String tenantsUpdated(String room, String name);

  /// Title of the edit-tenant dialog
  ///
  /// In en, this message translates to:
  /// **'Edit tenant'**
  String get tenantsEditTitle;

  /// Label of the room number field
  ///
  /// In en, this message translates to:
  /// **'Room number (e.g. 301)'**
  String get tenantsRoomLabel;

  /// Validation error when the room number is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter the room number'**
  String get tenantsRoomRequired;

  /// Label of the tenant name field
  ///
  /// In en, this message translates to:
  /// **'Tenant name (required)'**
  String get tenantsNameLabel;

  /// Validation error when the tenant name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter the tenant name'**
  String get tenantsNameRequired;

  /// Label of the fixed monthly rent field
  ///
  /// In en, this message translates to:
  /// **'Fixed monthly rent (yuan)'**
  String get tenantsRentLabel;

  /// Label of the monthly property fee field
  ///
  /// In en, this message translates to:
  /// **'Monthly property fee (yuan)'**
  String get tenantsPropertyLabel;

  /// Label of the total amount card on the bill edit screen
  ///
  /// In en, this message translates to:
  /// **'Total due'**
  String get billEditTotalLabel;

  /// Title of the paid switch on the bill edit screen
  ///
  /// In en, this message translates to:
  /// **'Payment received'**
  String get billEditPaidSwitch;

  /// Label of the note field on the bill edit screen
  ///
  /// In en, this message translates to:
  /// **'Note (optional, shown on the bill image)'**
  String get billEditNoteLabel;

  /// Hint text of the note field on the bill edit screen
  ///
  /// In en, this message translates to:
  /// **'e.g. Please transfer to my WeChat / see Moments for the payment QR code'**
  String get billEditNoteHint;

  /// Hint text at the bottom of the bill edit screen
  ///
  /// In en, this message translates to:
  /// **'Note: fixed charges are pre-filled from last month and can be edited.'**
  String get billEditHint;

  /// Label of a money input field, where the label is a fee name
  ///
  /// In en, this message translates to:
  /// **'{label} (yuan)'**
  String billEditMoneyFieldLabel(String label);

  /// Label of the button that saves the bill and opens the share screen
  ///
  /// In en, this message translates to:
  /// **'Save & share image'**
  String get billEditSaveAndShare;

  /// Tooltip of the delete icon and title of the delete-bill dialog
  ///
  /// In en, this message translates to:
  /// **'Delete bill'**
  String get billEditDelete;

  /// Body of the delete-bill confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete this month\'s bill?'**
  String get billEditDeleteMessage;

  /// Title of the bill share screen
  ///
  /// In en, this message translates to:
  /// **'Bill image'**
  String get billShareViewTitle;

  /// Tooltip of the edit icon on the bill share screen
  ///
  /// In en, this message translates to:
  /// **'Edit bill'**
  String get billShareEditTooltip;

  /// Label of the share button on the bill share screen
  ///
  /// In en, this message translates to:
  /// **'Generate image & send to tenant (WeChat)'**
  String get billShareSubmit;

  /// Label of the share button while the image is being generated
  ///
  /// In en, this message translates to:
  /// **'Generating image…'**
  String get billShareGenerating;

  /// Snack bar shown when sharing the bill image failed
  ///
  /// In en, this message translates to:
  /// **'Share failed: {error}'**
  String billShareFailed(String error);

  /// Title of the shared bill payload
  ///
  /// In en, this message translates to:
  /// **'{room} rent bill'**
  String billShareTitle(String room);

  /// Text of the shared bill payload
  ///
  /// In en, this message translates to:
  /// **'{room} {name} {month} bill: total {total}. See the image for details.'**
  String billShareText(String room, String name, String month, String total);

  /// Prefix of the generated bill image file name
  ///
  /// In en, this message translates to:
  /// **'rent-bill'**
  String get billShareFilePrefix;

  /// Title printed on the exported bill card image
  ///
  /// In en, this message translates to:
  /// **'Rent bill'**
  String get billCardTitle;

  /// Label of the tenant row on the exported bill card image
  ///
  /// In en, this message translates to:
  /// **'Tenant'**
  String get billCardTenantLabel;

  /// Label of the total row on the exported bill card image
  ///
  /// In en, this message translates to:
  /// **'Total due'**
  String get billCardTotalLabel;

  /// Note line on the exported bill card image
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String billCardNote(String note);

  /// Issue date line on the exported bill card image
  ///
  /// In en, this message translates to:
  /// **'Issued on: {date}'**
  String billCardIssuedOn(String date);

  /// Title of the fallback screen when route data is missing
  ///
  /// In en, this message translates to:
  /// **'Data not found'**
  String get errorDataNotFound;

  /// Body of the fallback screen when route data is missing
  ///
  /// In en, this message translates to:
  /// **'The tenant or bill could not be found'**
  String get errorTenantOrBillNotFound;

  /// Entry of the language picker in the home overflow menu and its dialog title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get homeLanguage;

  /// Entry of the currency picker in the home overflow menu and its dialog title
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get homeCurrency;

  /// Option that restores following the system language
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get languageSystem;

  /// Option that restores deriving the currency from the app language
  ///
  /// In en, this message translates to:
  /// **'Auto (follow language)'**
  String get currencyAuto;
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
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
