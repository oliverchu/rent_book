// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '家賃回収';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '削除';

  @override
  String get commonEdit => '編集';

  @override
  String get commonPaid => '入金済み';

  @override
  String get commonUnpaid => '未入金';

  @override
  String get commonTenantDeleted => '（入居者削除済み）';

  @override
  String commonReceivedAmount(String amount) {
    return '入金済み $amount';
  }

  @override
  String commonUnpaidAmount(String amount) {
    return '未入金 $amount';
  }

  @override
  String get passwordShowTooltip => 'パスワードを表示';

  @override
  String get passwordHideTooltip => 'パスワードを非表示';

  @override
  String passwordMinLengthError(int count) {
    return '$count文字以上で入力してください';
  }

  @override
  String get passwordMismatch => 'パスワードが一致しません';

  @override
  String get feeRent => '家賃';

  @override
  String get feeProperty => '管理費';

  @override
  String get feeWater => '水道代';

  @override
  String get feeElectricity => '電気代';

  @override
  String get feeGas => 'ガス代';

  @override
  String billFeeSummary(String rent, String propertyFee, String utilities) {
    return '家賃 $rent・管理費 $propertyFee・水道光熱 $utilities';
  }

  @override
  String get lockViewTitle => '家賃回収はロックされています';

  @override
  String get lockViewPasswordLabel => '起動パスワードを入力';

  @override
  String get lockViewPasswordRequired => 'パスワードを入力してください';

  @override
  String get lockViewVerifying => '確認中…';

  @override
  String get lockViewUnlock => 'ロック解除';

  @override
  String get lockViewForgotPassword => 'パスワードをお忘れですか？';

  @override
  String get lockViewWrongPassword => 'パスワードが違います。もう一度お試しください';

  @override
  String get setPasswordTitle => '起動パスワードの設定';

  @override
  String get setPasswordSubtitle => '家賃の請求書を保護します。次回起動時に入力が必要です';

  @override
  String setPasswordFieldLabel(int count) {
    return 'パスワードを設定（$count文字以上）';
  }

  @override
  String get setPasswordConfirmLabel => '確認のためもう一度入力';

  @override
  String get setPasswordSubmit => '設定を完了';

  @override
  String get changePasswordTitle => '起動パスワードの変更';

  @override
  String get changePasswordOldLabel => '現在のパスワード';

  @override
  String get changePasswordOldRequired => '現在のパスワードを入力してください';

  @override
  String changePasswordNewLabel(int count) {
    return '新しいパスワード（$count文字以上）';
  }

  @override
  String get changePasswordConfirmLabel => '新しいパスワードをもう一度入力';

  @override
  String get changePasswordMismatch => '新しいパスワードが一致しません';

  @override
  String get changePasswordOldIncorrect => '現在のパスワードが正しくありません';

  @override
  String get changePasswordSameAsOld => '新しいパスワードは現在のものと異なる必要があります';

  @override
  String get changePasswordSuccess => '起動パスワードを変更しました ✓';

  @override
  String get changePasswordSubmit => '変更を確認';

  @override
  String get changePasswordHint =>
      'ヒント：新しいパスワードは現在のものと異なる必要があり、2回の入力が一致している必要があります。';

  @override
  String get passwordGateResetMessage =>
      '起動パスワードとすべての入居者・請求データが削除され、アプリは初回起動時の状態に戻ります。この操作は取り消せません。';

  @override
  String get passwordGateResetConfirm => '削除してやり直す';

  @override
  String get homeMoreTooltip => 'その他';

  @override
  String get homeAddBill => '請求を記録';

  @override
  String get homeEmptyTenants => '入居者がまだいません。まず追加しましょう';

  @override
  String get homeAddTenant => '入居者を追加';

  @override
  String get homePreviousMonth => '前の月';

  @override
  String get homeNextMonth => '次の月';

  @override
  String get homeBackToThisMonth => '今月に戻る';

  @override
  String get homeMonthlyReceivable => '今月の請求合計';

  @override
  String homeCollectionSummary(int paid, int recorded, int total) {
    return '$paid/$recorded 入金済み・全$total戸';
  }

  @override
  String homeNotRecorded(String rent, String propertyFee) {
    return '未入力・固定家賃 $rent ＋ 管理費 $propertyFee';
  }

  @override
  String get homePending => '未入力';

  @override
  String get homeAddTenantFirst => '先に入居者を追加してください';

  @override
  String get homePickTenantTitle => '記録する入居者を選択';

  @override
  String get historyTitle => '履歴';

  @override
  String get historyEmpty => '請求記録はまだありません';

  @override
  String historyMonthTotal(String amount) {
    return '合計 $amount';
  }

  @override
  String get historyPaidSuffix => ' · 入金済み ✓';

  @override
  String get statsTitle => '統計';

  @override
  String get statsEmpty => '請求がまだありません。まず記録しましょう';

  @override
  String get statsSummaryTitle => '累計請求 / 入金';

  @override
  String get statsReceivable => '請求';

  @override
  String statsCollectionRate(String rate) {
    return '回収率 $rate%';
  }

  @override
  String get statsMonthlyTrendTitle => '直近12か月の請求';

  @override
  String statsChartTooltip(String paid, String unpaid) {
    return '入金済み $paid\n未入金 $unpaid';
  }

  @override
  String get statsCategoryTitle => '費用の内訳';

  @override
  String get statsCategoryEmpty => '費用の内訳（データなし）';

  @override
  String get statsTenantRankingTitle => '入居者別の累計請求';

  @override
  String get statsTenantRankingEmpty => '入居者別の累計請求（データなし）';

  @override
  String get tenantsTitle => '入居者管理';

  @override
  String get tenantsAdd => '入居者を追加';

  @override
  String get tenantsEmpty => '入居者がいません。右下のボタンから追加してください';

  @override
  String tenantsFeeSummary(String rent, String propertyFee) {
    return '固定家賃 $rent / 月・管理費 $propertyFee / 月';
  }

  @override
  String get tenantsDeleteTitle => '入居者を削除';

  @override
  String tenantsDeleteWithBillsMessage(String room, String name, int count) {
    return '「$room $name」の請求記録$count件も同時に削除されます。よろしいですか？';
  }

  @override
  String tenantsDeleteMessage(String room, String name) {
    return '「$room $name」を削除しますか？';
  }

  @override
  String tenantsDeleted(String room, String name) {
    return '「$room $name」を削除しました';
  }

  @override
  String tenantsDeletedWithBillsSuffix(int count) {
    return ' と請求記録$count件';
  }

  @override
  String tenantsAdded(String room, String name) {
    return '「$room $name」を追加しました';
  }

  @override
  String tenantsUpdated(String room, String name) {
    return '「$room $name」の変更を保存しました';
  }

  @override
  String get tenantsEditTitle => '入居者を編集';

  @override
  String get tenantsRoomLabel => '部屋番号（例：301）';

  @override
  String get tenantsRoomRequired => '部屋番号を入力してください';

  @override
  String get tenantsNameLabel => '入居者名（必須）';

  @override
  String get tenantsNameRequired => '入居者名を入力してください';

  @override
  String get tenantsRentLabel => '毎月の固定家賃（元）';

  @override
  String get tenantsPropertyLabel => '毎月の管理費（元）';

  @override
  String get billEditTotalLabel => '請求合計';

  @override
  String get billEditPaidSwitch => '入金済み';

  @override
  String get billEditNoteLabel => '備考（任意、請求画像に表示されます）';

  @override
  String get billEditNoteHint => '例：私のWeChatへお振込みください／支払いQRコードはモーメンツをご覧ください';

  @override
  String get billEditHint => 'ヒント：固定費は前月分から自動入力されています。そのまま編集できます。';

  @override
  String billEditMoneyFieldLabel(String label) {
    return '$label（元）';
  }

  @override
  String get billEditSaveAndShare => '保存して画像を送信';

  @override
  String get billEditDelete => '請求を削除';

  @override
  String get billEditDeleteMessage => '今月の請求を削除しますか？';

  @override
  String get billShareViewTitle => '請求画像';

  @override
  String get billShareEditTooltip => '請求を編集';

  @override
  String get billShareSubmit => '画像を生成して入居者に送信（WeChat）';

  @override
  String get billShareGenerating => '画像を生成中…';

  @override
  String billShareFailed(String error) {
    return '共有に失敗しました：$error';
  }

  @override
  String billShareTitle(String room) {
    return '「$room」家賃請求書';
  }

  @override
  String billShareText(String room, String name, String month, String total) {
    return '「$room $name」$monthの請求書：合計 $total。明細は画像をご確認ください。';
  }

  @override
  String get billShareFilePrefix => '家賃請求書';

  @override
  String get billCardTitle => '家賃請求書';

  @override
  String get billCardTenantLabel => '入居者';

  @override
  String get billCardTotalLabel => '請求合計';

  @override
  String billCardNote(String note) {
    return '備考：$note';
  }

  @override
  String billCardIssuedOn(String date) {
    return '発行日：$date';
  }

  @override
  String get errorDataNotFound => 'データが見つかりません';

  @override
  String get errorTenantOrBillNotFound => '該当する入居者または請求が見つかりません';

  @override
  String get homeLanguage => '言語';

  @override
  String get homeCurrency => '通貨';

  @override
  String get languageSystem => 'システムに従う';

  @override
  String get currencyAuto => '自動（言語に従う）';
}
