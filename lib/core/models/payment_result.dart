import 'package:uuid/uuid.dart';

enum PaymentStatus {
  pending,
  processing,
  success,
  failed,
  cancelled;
}

class PaymentResult {
  final String id;
  final String targetNumber;
  final String targetType;
  final String walletName;
  final double amount;
  final String? reference;
  final String? merchantName;
  final PaymentStatus status;
  final DateTime timestamp;
  final String? receiptCode;

  PaymentResult({
    String? id,
    required this.targetNumber,
    required this.targetType,
    required this.walletName,
    required this.amount,
    this.reference,
    this.merchantName,
    this.status = PaymentStatus.pending,
    DateTime? timestamp,
    this.receiptCode,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  PaymentResult copyWith({
    PaymentStatus? status,
    String? receiptCode,
    String? reference,
  }) {
    return PaymentResult(
      id: id,
      targetNumber: targetNumber,
      targetType: targetType,
      walletName: walletName,
      amount: amount,
      reference: reference ?? this.reference,
      merchantName: merchantName,
      status: status ?? this.status,
      timestamp: timestamp,
      receiptCode: receiptCode ?? this.receiptCode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'targetNumber': targetNumber,
      'targetType': targetType,
      'walletName': walletName,
      'amount': amount,
      'reference': reference,
      'merchantName': merchantName,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'receiptCode': receiptCode,
    };
  }

  factory PaymentResult.fromMap(Map<String, dynamic> map) {
    return PaymentResult(
      id: map['id'],
      targetNumber: map['targetNumber'],
      targetType: map['targetType'],
      walletName: map['walletName'],
      amount: (map['amount'] as num).toDouble(),
      reference: map['reference'],
      merchantName: map['merchantName'],
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PaymentStatus.failed,
      ),
      timestamp: DateTime.parse(map['timestamp']),
      receiptCode: map['receiptCode'],
    );
  }
}
