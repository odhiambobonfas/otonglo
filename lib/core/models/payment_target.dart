import 'package:uuid/uuid.dart';

enum PaymentType {
  phone,
  till,
  paybill,
  storeNumber,
  merchant,
  unknown;

  String get label {
    switch (this) {
      case PaymentType.phone:
        return 'Phone Number';
      case PaymentType.till:
        return 'Buy Goods Till';
      case PaymentType.paybill:
        return 'Paybill';
      case PaymentType.storeNumber:
        return 'Store Number';
      case PaymentType.merchant:
        return 'Merchant ID';
      case PaymentType.unknown:
        return 'Unknown';
    }
  }
}

class PaymentTarget {
  final String id;
  final PaymentType type;
  final String number;
  final String? account;
  final String? merchantName;
  final double confidence;

  PaymentTarget({
    String? id,
    required this.type,
    required this.number,
    this.account,
    this.merchantName,
    this.confidence = 0.0,
  }) : id = id ?? const Uuid().v4();

  PaymentTarget copyWith({
    PaymentType? type,
    String? number,
    String? account,
    String? merchantName,
    double? confidence,
  }) {
    return PaymentTarget(
      id: id,
      type: type ?? this.type,
      number: number ?? this.number,
      account: account ?? this.account,
      merchantName: merchantName ?? this.merchantName,
      confidence: confidence ?? this.confidence,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'number': number,
      'account': account,
      'merchantName': merchantName,
      'confidence': confidence,
    };
  }

  factory PaymentTarget.fromMap(Map<String, dynamic> map) {
    return PaymentTarget(
      id: map['id'],
      type: PaymentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PaymentType.unknown,
      ),
      number: map['number'],
      account: map['account'],
      merchantName: map['merchantName'],
      confidence: (map['confidence'] as num).toDouble(),
    );
  }
}
