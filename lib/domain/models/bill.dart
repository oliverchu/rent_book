import 'tenant.dart';

/// 某租户某个月份的账单。
///
/// 金额一律以“分”（int）存储，避免浮点精度问题。
class Bill {
  final String id;
  final String tenantId;
  final int year;
  final int month;

  final int rent;
  final int propertyFee;
  final int waterFee;
  final int electricityFee;
  final int gasFee;

  final bool paid;
  final String note;

  const Bill({
    required this.id,
    required this.tenantId,
    required this.year,
    required this.month,
    required this.rent,
    required this.propertyFee,
    required this.waterFee,
    required this.electricityFee,
    required this.gasFee,
    required this.paid,
    required this.note,
  });

  /// 应缴合计 = 房租 + 物业 + 水 + 电 + 燃气。
  int get total => rent + propertyFee + waterFee + electricityFee + gasFee;

  /// 用租户的固定费用创建指定月份的新账单。
  factory Bill.fromTenant(Tenant tenant, int year, int month, {required String id}) {
    return Bill(
      id: id,
      tenantId: tenant.id,
      year: year,
      month: month,
      rent: tenant.rent,
      propertyFee: tenant.propertyFee,
      waterFee: 0,
      electricityFee: 0,
      gasFee: 0,
      paid: false,
      note: '',
    );
  }

  /// 同样金额、换到另一个月份的空白账单（用于"带上个月数据"）。
  Bill copyForPeriod(int year, int month, {required String newId}) {
    return Bill(
      id: newId,
      tenantId: tenantId,
      year: year,
      month: month,
      rent: rent,
      propertyFee: propertyFee,
      waterFee: waterFee,
      electricityFee: electricityFee,
      gasFee: gasFee,
      paid: false,
      note: '',
    );
  }

  Bill copyWith({
    int? rent,
    int? propertyFee,
    int? waterFee,
    int? electricityFee,
    int? gasFee,
    bool? paid,
    String? note,
  }) {
    return Bill(
      id: id,
      tenantId: tenantId,
      year: year,
      month: month,
      rent: rent ?? this.rent,
      propertyFee: propertyFee ?? this.propertyFee,
      waterFee: waterFee ?? this.waterFee,
      electricityFee: electricityFee ?? this.electricityFee,
      gasFee: gasFee ?? this.gasFee,
      paid: paid ?? this.paid,
      note: note ?? this.note,
    );
  }

  int get periodKey => year * 12 + month;

  /// 兼容旧数据（JSON 中为“元”的 num），缺失字段给默认值以向后兼容。
  factory Bill.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': String id,
        'tenantId': String tenantId,
        'year': int year,
        'month': int month,
      } =>
        Bill(
          id: id,
          tenantId: tenantId,
          year: year,
          month: month,
          rent: _readCents(json['rentCents'], json['rent']),
          propertyFee:
              _readCents(json['propertyFeeCents'], json['propertyFee']),
          waterFee: _readCents(json['waterFeeCents'], json['waterFee']),
          electricityFee:
              _readCents(json['electricityFeeCents'], json['electricityFee']),
          gasFee: _readCents(json['gasFeeCents'], json['gasFee']),
          paid: json['paid'] is bool ? json['paid'] as bool : false,
          note: json['note'] is String ? json['note'] as String : '',
        ),
      _ => throw const FormatException('Failed to load Bill.'),
    };
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'tenantId': tenantId,
      'year': year,
      'month': month,
      // 以"分"为整数字段写盘（*Cents）；读侧同时兼容旧版"元"字段。
      'rentCents': rent,
      'propertyFeeCents': propertyFee,
      'waterFeeCents': waterFee,
      'electricityFeeCents': electricityFee,
      'gasFeeCents': gasFee,
      'paid': paid,
      'note': note,
    };
  }

  /// 新格式直接读"分"；缺失时回退旧版"元"（num）换算。
  static int _readCents(Object? cents, Object? legacyYuan) {
    if (cents is num) {
      return cents.round();
    }
    if (legacyYuan is num) {
      return (legacyYuan * 100).round();
    }
    return 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bill &&
          other.id == id &&
          other.tenantId == tenantId &&
          other.year == year &&
          other.month == month &&
          other.rent == rent &&
          other.propertyFee == propertyFee &&
          other.waterFee == waterFee &&
          other.electricityFee == electricityFee &&
          other.gasFee == gasFee &&
          other.paid == paid &&
          other.note == note;

  @override
  int get hashCode => Object.hash(
      id, tenantId, year, month, rent, propertyFee, waterFee, electricityFee, gasFee, paid, note);
}
