/// 租户（房间）：房租与物业费为每月固定金额。
///
/// 金额一律以“分”（int）存储，避免浮点精度问题。
class Tenant {
  final String id;
  final String name;
  final String room;

  /// 固定月租（分）。
  final int rent;

  /// 固定物业费（分）。
  final int propertyFee;

  const Tenant({
    required this.id,
    required this.name,
    required this.room,
    required this.rent,
    required this.propertyFee,
  });

  Tenant copyWith({
    String? name,
    String? room,
    int? rent,
    int? propertyFee,
  }) {
    return Tenant(
      id: id,
      name: name ?? this.name,
      room: room ?? this.room,
      rent: rent ?? this.rent,
      propertyFee: propertyFee ?? this.propertyFee,
    );
  }

  /// 兼容旧数据（JSON 中为“元”的 num）。
  factory Tenant.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': String id,
        'name': String name,
        'room': String room,
      } =>
        Tenant(
          id: id,
          name: name,
          room: room,
          rent: _readCents(json['rentCents'], json['rent']),
          propertyFee:
              _readCents(json['propertyFeeCents'], json['propertyFee']),
        ),
      _ => throw const FormatException('Failed to load Tenant.'),
    };
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'room': room,
      // 以"分"为整数字段写盘（*Cents）；读侧同时兼容旧版"元"字段。
      'rentCents': rent,
      'propertyFeeCents': propertyFee,
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
      other is Tenant &&
          other.id == id &&
          other.name == name &&
          other.room == room &&
          other.rent == rent &&
          other.propertyFee == propertyFee;

  @override
  int get hashCode => Object.hash(id, name, room, rent, propertyFee);
}
