// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Rent Book';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonPaid => 'Received';

  @override
  String get commonUnpaid => 'Unpaid';

  @override
  String get commonTenantDeleted => '(Tenant deleted)';

  @override
  String commonReceivedAmount(String amount) {
    return 'Received $amount';
  }

  @override
  String commonUnpaidAmount(String amount) {
    return 'Unpaid $amount';
  }

  @override
  String get passwordShowTooltip => 'Show password';

  @override
  String get passwordHideTooltip => 'Hide password';

  @override
  String passwordMinLengthError(int count) {
    return 'At least $count characters';
  }

  @override
  String get passwordMismatch => 'The passwords do not match';

  @override
  String get feeRent => 'Rent';

  @override
  String get feeProperty => 'Property fee';

  @override
  String get feeWater => 'Water';

  @override
  String get feeElectricity => 'Electricity';

  @override
  String get feeGas => 'Gas';

  @override
  String billFeeSummary(String rent, String propertyFee, String utilities) {
    return 'Rent $rent · Property fee $propertyFee · Utilities $utilities';
  }

  @override
  String get lockViewTitle => 'Rent Book is locked';

  @override
  String get lockViewPasswordLabel => 'Enter startup password';

  @override
  String get lockViewPasswordRequired => 'Please enter the password';

  @override
  String get lockViewVerifying => 'Verifying…';

  @override
  String get lockViewUnlock => 'Unlock';

  @override
  String get lockViewForgotPassword => 'Forgot password?';

  @override
  String get lockViewWrongPassword => 'Wrong password, please try again';

  @override
  String get setPasswordTitle => 'Set a startup password';

  @override
  String get setPasswordSubtitle =>
      'Protects your rent records; you will need to enter it next time';

  @override
  String setPasswordFieldLabel(int count) {
    return 'Set a password (at least $count characters)';
  }

  @override
  String get setPasswordConfirmLabel => 'Enter it again to confirm';

  @override
  String get setPasswordSubmit => 'Finish setup';

  @override
  String get changePasswordTitle => 'Change startup password';

  @override
  String get changePasswordOldLabel => 'Current password';

  @override
  String get changePasswordOldRequired => 'Please enter the current password';

  @override
  String changePasswordNewLabel(int count) {
    return 'New password (at least $count characters)';
  }

  @override
  String get changePasswordConfirmLabel => 'Enter the new password again';

  @override
  String get changePasswordMismatch => 'The new passwords do not match';

  @override
  String get changePasswordOldIncorrect => 'The current password is incorrect';

  @override
  String get changePasswordSameAsOld =>
      'The new password must differ from the current one';

  @override
  String get changePasswordSuccess => 'Startup password updated ✓';

  @override
  String get changePasswordSubmit => 'Confirm change';

  @override
  String get changePasswordHint =>
      'Note: the new password must differ from the current one, and both entries must match.';

  @override
  String get passwordGateResetMessage =>
      'This will erase the startup password and all tenant and bill data, and the app will return to its first-run state. This cannot be undone.';

  @override
  String get passwordGateResetConfirm => 'Erase and start over';

  @override
  String get homeMoreTooltip => 'More';

  @override
  String get homeAddBill => 'Add a bill';

  @override
  String get homeEmptyTenants => 'No tenants yet — add one first';

  @override
  String get homeAddTenant => 'Add tenant';

  @override
  String get homePreviousMonth => 'Previous month';

  @override
  String get homeNextMonth => 'Next month';

  @override
  String get homeBackToThisMonth => 'Back to this month';

  @override
  String get homeMonthlyReceivable => 'Total due this month';

  @override
  String homeCollectionSummary(int paid, int recorded, int total) {
    return '$paid/$recorded received · $total tenants';
  }

  @override
  String homeNotRecorded(String rent, String propertyFee) {
    return 'Not recorded · fixed rent $rent + property fee $propertyFee';
  }

  @override
  String get homePending => 'Not recorded';

  @override
  String get homeAddTenantFirst => 'Please add a tenant first';

  @override
  String get homePickTenantTitle => 'Choose a tenant';

  @override
  String get historyTitle => 'History';

  @override
  String get historyEmpty => 'No bills yet';

  @override
  String historyMonthTotal(String amount) {
    return 'Total $amount';
  }

  @override
  String get historyPaidSuffix => ' · Paid ✓';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsEmpty => 'No bills yet — add one first';

  @override
  String get statsSummaryTitle => 'Total due / received';

  @override
  String get statsReceivable => 'Due';

  @override
  String statsCollectionRate(String rate) {
    return 'Collection rate $rate%';
  }

  @override
  String get statsMonthlyTrendTitle => 'Due over the last 12 months';

  @override
  String statsChartTooltip(String paid, String unpaid) {
    return 'Received $paid\nUnpaid $unpaid';
  }

  @override
  String get statsCategoryTitle => 'Fee breakdown';

  @override
  String get statsCategoryEmpty => 'Fee breakdown (no data)';

  @override
  String get statsTenantRankingTitle => 'Total due by tenant';

  @override
  String get statsTenantRankingEmpty => 'Total due by tenant (no data)';

  @override
  String get tenantsTitle => 'Tenants';

  @override
  String get tenantsAdd => 'Add tenant';

  @override
  String get tenantsEmpty => 'No tenants — tap the button below to add one';

  @override
  String tenantsFeeSummary(String rent, String propertyFee) {
    return 'Rent $rent / month · Property fee $propertyFee / month';
  }

  @override
  String get tenantsDeleteTitle => 'Delete tenant';

  @override
  String tenantsDeleteWithBillsMessage(String room, String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bill records',
      one: '1 bill record',
    );
    return 'This will also delete $_temp0 for $room $name. Continue?';
  }

  @override
  String tenantsDeleteMessage(String room, String name) {
    return 'Delete $room $name?';
  }

  @override
  String tenantsDeleted(String room, String name) {
    return 'Deleted $room $name';
  }

  @override
  String tenantsDeletedWithBillsSuffix(int count) {
    return ' and $count bill records';
  }

  @override
  String tenantsAdded(String room, String name) {
    return 'Added $room $name';
  }

  @override
  String tenantsUpdated(String room, String name) {
    return 'Saved changes to $room $name';
  }

  @override
  String get tenantsEditTitle => 'Edit tenant';

  @override
  String get tenantsRoomLabel => 'Room number (e.g. 301)';

  @override
  String get tenantsRoomRequired => 'Please enter the room number';

  @override
  String get tenantsNameLabel => 'Tenant name (required)';

  @override
  String get tenantsNameRequired => 'Please enter the tenant name';

  @override
  String get tenantsRentLabel => 'Fixed monthly rent (yuan)';

  @override
  String get tenantsPropertyLabel => 'Monthly property fee (yuan)';

  @override
  String get billEditTotalLabel => 'Total due';

  @override
  String get billEditPaidSwitch => 'Payment received';

  @override
  String get billEditNoteLabel => 'Note (optional, shown on the bill image)';

  @override
  String get billEditNoteHint =>
      'e.g. Please transfer to my WeChat / see Moments for the payment QR code';

  @override
  String get billEditHint =>
      'Note: fixed charges are pre-filled from last month and can be edited.';

  @override
  String billEditMoneyFieldLabel(String label) {
    return '$label (yuan)';
  }

  @override
  String get billEditSaveAndShare => 'Save & share image';

  @override
  String get billEditDelete => 'Delete bill';

  @override
  String get billEditDeleteMessage => 'Delete this month\'s bill?';

  @override
  String get billShareViewTitle => 'Bill image';

  @override
  String get billShareEditTooltip => 'Edit bill';

  @override
  String get billShareSubmit => 'Generate image & send to tenant (WeChat)';

  @override
  String get billShareGenerating => 'Generating image…';

  @override
  String billShareFailed(String error) {
    return 'Share failed: $error';
  }

  @override
  String billShareTitle(String room) {
    return '$room rent bill';
  }

  @override
  String billShareText(String room, String name, String month, String total) {
    return '$room $name $month bill: total $total. See the image for details.';
  }

  @override
  String get billShareFilePrefix => 'rent-bill';

  @override
  String get billCardTitle => 'Rent bill';

  @override
  String get billCardTenantLabel => 'Tenant';

  @override
  String get billCardTotalLabel => 'Total due';

  @override
  String billCardNote(String note) {
    return 'Note: $note';
  }

  @override
  String billCardIssuedOn(String date) {
    return 'Issued on: $date';
  }

  @override
  String get errorDataNotFound => 'Data not found';

  @override
  String get errorTenantOrBillNotFound =>
      'The tenant or bill could not be found';

  @override
  String get homeLanguage => 'Language';

  @override
  String get homeCurrency => 'Currency';

  @override
  String get languageSystem => 'Follow system';

  @override
  String get currencyAuto => 'Auto (follow language)';
}
