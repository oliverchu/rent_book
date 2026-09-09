// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '收租啦';

  @override
  String get commonCancel => '取消';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '删除';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonPaid => '已收';

  @override
  String get commonUnpaid => '未收';

  @override
  String get commonTenantDeleted => '（租户已删除）';

  @override
  String commonReceivedAmount(String amount) {
    return '已收 $amount';
  }

  @override
  String commonUnpaidAmount(String amount) {
    return '未收 $amount';
  }

  @override
  String get passwordShowTooltip => '显示密码';

  @override
  String get passwordHideTooltip => '隐藏密码';

  @override
  String passwordMinLengthError(int count) {
    return '至少 $count 位字符';
  }

  @override
  String get passwordMismatch => '两次输入的密码不一致';

  @override
  String get feeRent => '房租';

  @override
  String get feeProperty => '物业费';

  @override
  String get feeWater => '水费';

  @override
  String get feeElectricity => '电费';

  @override
  String get feeGas => '燃气费';

  @override
  String billFeeSummary(String rent, String propertyFee, String utilities) {
    return '房租 $rent · 物业 $propertyFee · 水电气 $utilities';
  }

  @override
  String get lockViewTitle => '收租啦已上锁';

  @override
  String get lockViewPasswordLabel => '输入启动密码';

  @override
  String get lockViewPasswordRequired => '请输入密码';

  @override
  String get lockViewVerifying => '校验中…';

  @override
  String get lockViewUnlock => '解锁';

  @override
  String get lockViewForgotPassword => '忘记密码？';

  @override
  String get lockViewWrongPassword => '密码错误，请重试';

  @override
  String get setPasswordTitle => '设置启动密码';

  @override
  String get setPasswordSubtitle => '保护你的房租账单，下次打开需要输入';

  @override
  String setPasswordFieldLabel(int count) {
    return '设置密码（至少 $count 位）';
  }

  @override
  String get setPasswordConfirmLabel => '再次输入确认';

  @override
  String get setPasswordSubmit => '完成设置';

  @override
  String get changePasswordTitle => '修改启动密码';

  @override
  String get changePasswordOldLabel => '原密码';

  @override
  String get changePasswordOldRequired => '请输入原密码';

  @override
  String changePasswordNewLabel(int count) {
    return '新密码（至少 $count 位）';
  }

  @override
  String get changePasswordConfirmLabel => '再次输入新密码';

  @override
  String get changePasswordMismatch => '两次输入的新密码不一致';

  @override
  String get changePasswordOldIncorrect => '原密码不正确';

  @override
  String get changePasswordSameAsOld => '新密码不能与原密码相同';

  @override
  String get changePasswordSuccess => '启动密码已修改 ✓';

  @override
  String get changePasswordSubmit => '确认修改';

  @override
  String get changePasswordHint => '提示：新密码需与原密码不同；两次新密码必须一致。';

  @override
  String get passwordGateResetMessage =>
      '将清除启动密码和所有租户、账单数据，\n应用会恢复到首次使用的状态。此操作无法撤销。';

  @override
  String get passwordGateResetConfirm => '清除并重来';

  @override
  String get homeMoreTooltip => '更多';

  @override
  String get homeAddBill => '记一笔';

  @override
  String get homeEmptyTenants => '还没有租户，先去添加一位吧';

  @override
  String get homeAddTenant => '添加租户';

  @override
  String get homePreviousMonth => '上个月';

  @override
  String get homeNextMonth => '下个月';

  @override
  String get homeBackToThisMonth => '回到本月';

  @override
  String get homeMonthlyReceivable => '本月应收合计';

  @override
  String homeCollectionSummary(int paid, int recorded, int total) {
    return '$paid/$recorded 已收 · 共$total户';
  }

  @override
  String homeNotRecorded(String rent, String propertyFee) {
    return '未录入，固定房租 $rent + 物业 $propertyFee';
  }

  @override
  String get homePending => '待录入';

  @override
  String get homeAddTenantFirst => '请先添加租户';

  @override
  String get homePickTenantTitle => '选择要录入的租户';

  @override
  String get historyTitle => '历史记录';

  @override
  String get historyEmpty => '还没有账单记录';

  @override
  String historyMonthTotal(String amount) {
    return '合计 $amount';
  }

  @override
  String get historyPaidSuffix => '　已收 ✓';

  @override
  String get statsTitle => '统计';

  @override
  String get statsEmpty => '还没有账单，先去记一笔吧';

  @override
  String get statsSummaryTitle => '累计应收 / 实收';

  @override
  String get statsReceivable => '应收';

  @override
  String statsCollectionRate(String rate) {
    return '收缴率 $rate%';
  }

  @override
  String get statsMonthlyTrendTitle => '近 12 个月应收';

  @override
  String statsChartTooltip(String paid, String unpaid) {
    return '已收 $paid\n未收 $unpaid';
  }

  @override
  String get statsCategoryTitle => '费用构成';

  @override
  String get statsCategoryEmpty => '费用构成（暂无数据）';

  @override
  String get statsTenantRankingTitle => '租户累计应收';

  @override
  String get statsTenantRankingEmpty => '租户累计应收（暂无数据）';

  @override
  String get tenantsTitle => '租户管理';

  @override
  String get tenantsAdd => '新增租户';

  @override
  String get tenantsEmpty => '暂无租户，点右下角添加';

  @override
  String tenantsFeeSummary(String rent, String propertyFee) {
    return '固定房租 $rent / 月 · 物业费 $propertyFee / 月';
  }

  @override
  String get tenantsDeleteTitle => '删除租户';

  @override
  String tenantsDeleteWithBillsMessage(String room, String name, int count) {
    return '将同时删除「$room $name」的 $count 条账单记录，确定吗？';
  }

  @override
  String tenantsDeleteMessage(String room, String name) {
    return '确定删除「$room $name」吗？';
  }

  @override
  String tenantsDeleted(String room, String name) {
    return '已删除「$room $name」';
  }

  @override
  String tenantsDeletedWithBillsSuffix(int count) {
    return '及其 $count 条账单';
  }

  @override
  String tenantsAdded(String room, String name) {
    return '已添加「$room $name」';
  }

  @override
  String tenantsUpdated(String room, String name) {
    return '已保存「$room $name」的修改';
  }

  @override
  String get tenantsEditTitle => '编辑租户';

  @override
  String get tenantsRoomLabel => '房间号（如 301）';

  @override
  String get tenantsRoomRequired => '请填写房间号';

  @override
  String get tenantsNameLabel => '租户姓名（必填）';

  @override
  String get tenantsNameRequired => '请填写租户姓名';

  @override
  String get tenantsRentLabel => '每月固定房租（元）';

  @override
  String get tenantsPropertyLabel => '每月物业费（元）';

  @override
  String get billEditTotalLabel => '合计应缴';

  @override
  String get billEditPaidSwitch => '已收到账';

  @override
  String get billEditNoteLabel => '备注（可选，会显示在图片账单上）';

  @override
  String get billEditNoteHint => '例如：请转到我微信 / 收款码见朋友圈';

  @override
  String get billEditHint => '提示：固定支出已按上月自动带出，可直接修改。';

  @override
  String billEditMoneyFieldLabel(String label) {
    return '$label（元）';
  }

  @override
  String get billEditSaveAndShare => '保存并发图收租';

  @override
  String get billEditDelete => '删除账单';

  @override
  String get billEditDeleteMessage => '确定删除这个月的账单吗？';

  @override
  String get billShareViewTitle => '账单图片';

  @override
  String get billShareEditTooltip => '编辑账单';

  @override
  String get billShareSubmit => '生成图片并发送给租客（微信）';

  @override
  String get billShareGenerating => '正在生成图片…';

  @override
  String billShareFailed(String error) {
    return '分享失败：$error';
  }

  @override
  String billShareTitle(String room) {
    return '$room 房租缴费单';
  }

  @override
  String billShareText(String room, String name, String month, String total) {
    return '$room $name $month 账单：合计 $total，明细见图片。';
  }

  @override
  String get billShareFilePrefix => '房租缴费单';

  @override
  String get billCardTitle => '房租缴费单';

  @override
  String get billCardTenantLabel => '租户';

  @override
  String get billCardTotalLabel => '应缴合计';

  @override
  String billCardNote(String note) {
    return '备注：$note';
  }

  @override
  String billCardIssuedOn(String date) {
    return '出具日期：$date';
  }

  @override
  String get errorDataNotFound => '数据不存在';

  @override
  String get errorTenantOrBillNotFound => '找不到对应的租户或账单';

  @override
  String get homeLanguage => '语言';

  @override
  String get homeCurrency => '货币';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get currencyAuto => '自动（跟随语言）';
}
