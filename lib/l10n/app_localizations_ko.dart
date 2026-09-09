// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '월세 수납';

  @override
  String get commonCancel => '취소';

  @override
  String get commonSave => '저장';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonEdit => '편집';

  @override
  String get commonPaid => '완납';

  @override
  String get commonUnpaid => '미납';

  @override
  String get commonTenantDeleted => '(삭제된 세입자)';

  @override
  String commonReceivedAmount(String amount) {
    return '완납 $amount';
  }

  @override
  String commonUnpaidAmount(String amount) {
    return '미납 $amount';
  }

  @override
  String get passwordShowTooltip => '비밀번호 표시';

  @override
  String get passwordHideTooltip => '비밀번호 숨기기';

  @override
  String passwordMinLengthError(int count) {
    return '최소 $count자 이상 입력해 주세요';
  }

  @override
  String get passwordMismatch => '비밀번호가 일치하지 않습니다';

  @override
  String get feeRent => '월세';

  @override
  String get feeProperty => '관리비';

  @override
  String get feeWater => '수도세';

  @override
  String get feeElectricity => '전기세';

  @override
  String get feeGas => '가스비';

  @override
  String billFeeSummary(String rent, String propertyFee, String utilities) {
    return '월세 $rent · 관리비 $propertyFee · 수도·전기·가스 $utilities';
  }

  @override
  String get lockViewTitle => '월세 수납이 잠겼습니다';

  @override
  String get lockViewPasswordLabel => '시작 비밀번호 입력';

  @override
  String get lockViewPasswordRequired => '비밀번호를 입력해 주세요';

  @override
  String get lockViewVerifying => '확인 중…';

  @override
  String get lockViewUnlock => '잠금 해제';

  @override
  String get lockViewForgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get lockViewWrongPassword => '비밀번호가 올바르지 않습니다. 다시 시도해 주세요';

  @override
  String get setPasswordTitle => '시작 비밀번호 설정';

  @override
  String get setPasswordSubtitle => '월세 청구서를 보호합니다. 다음에 열 때 입력해야 합니다';

  @override
  String setPasswordFieldLabel(int count) {
    return '비밀번호 설정 (최소 $count자)';
  }

  @override
  String get setPasswordConfirmLabel => '확인을 위해 다시 입력';

  @override
  String get setPasswordSubmit => '설정 완료';

  @override
  String get changePasswordTitle => '시작 비밀번호 변경';

  @override
  String get changePasswordOldLabel => '현재 비밀번호';

  @override
  String get changePasswordOldRequired => '현재 비밀번호를 입력해 주세요';

  @override
  String changePasswordNewLabel(int count) {
    return '새 비밀번호 (최소 $count자)';
  }

  @override
  String get changePasswordConfirmLabel => '새 비밀번호를 다시 입력';

  @override
  String get changePasswordMismatch => '새 비밀번호가 일치하지 않습니다';

  @override
  String get changePasswordOldIncorrect => '현재 비밀번호가 올바르지 않습니다';

  @override
  String get changePasswordSameAsOld => '새 비밀번호는 현재 비밀번호와 달라야 합니다';

  @override
  String get changePasswordSuccess => '시작 비밀번호가 변경되었습니다 ✓';

  @override
  String get changePasswordSubmit => '변경 확인';

  @override
  String get changePasswordHint =>
      '참고: 새 비밀번호는 현재 비밀번호와 달라야 하며, 두 번의 입력이 일치해야 합니다.';

  @override
  String get passwordGateResetMessage =>
      '시작 비밀번호와 모든 세입자 및 청구서 데이터가 삭제되며, 앱이 최초 사용 상태로 돌아갑니다. 이 작업은 되돌릴 수 없습니다.';

  @override
  String get passwordGateResetConfirm => '삭제하고 다시 시작';

  @override
  String get homeMoreTooltip => '더보기';

  @override
  String get homeAddBill => '청구서 추가';

  @override
  String get homeEmptyTenants => '아직 세입자가 없습니다. 먼저 추가해 주세요';

  @override
  String get homeAddTenant => '세입자 추가';

  @override
  String get homePreviousMonth => '이전 달';

  @override
  String get homeNextMonth => '다음 달';

  @override
  String get homeBackToThisMonth => '이번 달로 돌아가기';

  @override
  String get homeMonthlyReceivable => '이번 달 청구 합계';

  @override
  String homeCollectionSummary(int paid, int recorded, int total) {
    return '$paid/$recorded 완납 · 총 $total세대';
  }

  @override
  String homeNotRecorded(String rent, String propertyFee) {
    return '미입력 · 고정 월세 $rent + 관리비 $propertyFee';
  }

  @override
  String get homePending => '미입력';

  @override
  String get homeAddTenantFirst => '먼저 세입자를 추가해 주세요';

  @override
  String get homePickTenantTitle => '청구서를 작성할 세입자 선택';

  @override
  String get historyTitle => '기록';

  @override
  String get historyEmpty => '아직 청구서 기록이 없습니다';

  @override
  String historyMonthTotal(String amount) {
    return '합계 $amount';
  }

  @override
  String get historyPaidSuffix => ' · 완납 ✓';

  @override
  String get statsTitle => '통계';

  @override
  String get statsEmpty => '아직 청구서가 없습니다. 먼저 기록해 주세요';

  @override
  String get statsSummaryTitle => '누적 청구 / 수납';

  @override
  String get statsReceivable => '청구';

  @override
  String statsCollectionRate(String rate) {
    return '수납률 $rate%';
  }

  @override
  String get statsMonthlyTrendTitle => '최근 12개월 청구';

  @override
  String statsChartTooltip(String paid, String unpaid) {
    return '완납 $paid\n미납 $unpaid';
  }

  @override
  String get statsCategoryTitle => '비용 구성';

  @override
  String get statsCategoryEmpty => '비용 구성 (데이터 없음)';

  @override
  String get statsTenantRankingTitle => '세입자별 누적 청구';

  @override
  String get statsTenantRankingEmpty => '세입자별 누적 청구 (데이터 없음)';

  @override
  String get tenantsTitle => '세입자 관리';

  @override
  String get tenantsAdd => '세입자 추가';

  @override
  String get tenantsEmpty => '세입자가 없습니다. 오른쪽 아래 버튼으로 추가하세요';

  @override
  String tenantsFeeSummary(String rent, String propertyFee) {
    return '고정 월세 $rent / 월 · 관리비 $propertyFee / 월';
  }

  @override
  String get tenantsDeleteTitle => '세입자 삭제';

  @override
  String tenantsDeleteWithBillsMessage(String room, String name, int count) {
    return '$room $name의 청구서 기록 $count건도 함께 삭제됩니다. 계속할까요?';
  }

  @override
  String tenantsDeleteMessage(String room, String name) {
    return '$room $name을(를) 삭제할까요?';
  }

  @override
  String tenantsDeleted(String room, String name) {
    return '$room $name을(를) 삭제했습니다';
  }

  @override
  String tenantsDeletedWithBillsSuffix(int count) {
    return ' 및 청구서 $count건';
  }

  @override
  String tenantsAdded(String room, String name) {
    return '$room $name을(를) 추가했습니다';
  }

  @override
  String tenantsUpdated(String room, String name) {
    return '$room $name의 변경 사항을 저장했습니다';
  }

  @override
  String get tenantsEditTitle => '세입자 편집';

  @override
  String get tenantsRoomLabel => '호실 (예: 301)';

  @override
  String get tenantsRoomRequired => '호실을 입력해 주세요';

  @override
  String get tenantsNameLabel => '세입자 이름 (필수)';

  @override
  String get tenantsNameRequired => '세입자 이름을 입력해 주세요';

  @override
  String get tenantsRentLabel => '월 고정 월세 (위안)';

  @override
  String get tenantsPropertyLabel => '월 관리비 (위안)';

  @override
  String get billEditTotalLabel => '청구 합계';

  @override
  String get billEditPaidSwitch => '수납 완료';

  @override
  String get billEditNoteLabel => '비고 (선택 사항, 청구서 이미지에 표시됩니다)';

  @override
  String get billEditNoteHint => '예: 제 위챗으로 송금해 주세요 / 결제 QR 코드는 모멘트를 확인하세요';

  @override
  String get billEditHint => '참고: 고정 지출은 지난달 기준으로 자동 입력되며, 직접 수정할 수 있습니다.';

  @override
  String billEditMoneyFieldLabel(String label) {
    return '$label (위안)';
  }

  @override
  String get billEditSaveAndShare => '저장 후 이미지 공유';

  @override
  String get billEditDelete => '청구서 삭제';

  @override
  String get billEditDeleteMessage => '이번 달 청구서를 삭제할까요?';

  @override
  String get billShareViewTitle => '청구서 이미지';

  @override
  String get billShareEditTooltip => '청구서 편집';

  @override
  String get billShareSubmit => '이미지 생성 후 세입자에게 전송 (위챗)';

  @override
  String get billShareGenerating => '이미지 생성 중…';

  @override
  String billShareFailed(String error) {
    return '공유 실패: $error';
  }

  @override
  String billShareTitle(String room) {
    return '$room 월세 청구서';
  }

  @override
  String billShareText(String room, String name, String month, String total) {
    return '$room $name $month 청구서: 합계 $total, 자세한 내역은 이미지를 확인해 주세요.';
  }

  @override
  String get billShareFilePrefix => '월세-청구서';

  @override
  String get billCardTitle => '월세 청구서';

  @override
  String get billCardTenantLabel => '세입자';

  @override
  String get billCardTotalLabel => '청구 합계';

  @override
  String billCardNote(String note) {
    return '비고: $note';
  }

  @override
  String billCardIssuedOn(String date) {
    return '발행일: $date';
  }

  @override
  String get errorDataNotFound => '데이터가 없습니다';

  @override
  String get errorTenantOrBillNotFound => '해당 세입자 또는 청구서를 찾을 수 없습니다';

  @override
  String get homeLanguage => '언어';

  @override
  String get homeCurrency => '통화';

  @override
  String get languageSystem => '시스템 설정 따르기';

  @override
  String get currencyAuto => '자동 (언어 따름)';
}
