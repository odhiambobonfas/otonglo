import 'package:otonglo/core/models/payment_target.dart';

class ParseResult {
  final List<PaymentTarget> targets;
  final String rawText;

  const ParseResult({
    required this.targets,
    required this.rawText,
  });

  bool get hasResults => targets.isNotEmpty;
  bool get hasMultiple => targets.length > 1;
  PaymentTarget? get primary => targets.isNotEmpty ? targets.first : null;
}

class PaymentParser {
  ParseResult parse(String text) {
    if (text.trim().isEmpty) {
      return ParseResult(targets: [], rawText: text);
    }

    final targets = <PaymentTarget>[];
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    final fullText = text.toUpperCase();

    _extractPaybill(lines, fullText, targets);
    _extractTill(lines, fullText, targets);
    _extractStoreNumber(lines, fullText, targets);
    _extractPhoneNumbers(fullText, targets);

    if (targets.isEmpty) {
      _extractFallbackNumbers(fullText, targets);
    }

    return ParseResult(targets: targets, rawText: text);
  }

  void _extractPaybill(List<String> lines, String upperText, List<PaymentTarget> targets) {
    final isPaybill = upperText.contains('PAYBILL') ||
        upperText.contains('PAY BILL') ||
        upperText.contains('BUSINESS NUMBER');

    if (!isPaybill) return;

    String? businessNumber;
    String? accountNumber;
    double confidence = 0.7;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].toUpperCase();
      final current = lines[i];

      if (line.contains('BUSINESS') && line.contains('NUMBER')) {
        businessNumber = _extractNumberAfter(current);
        if (businessNumber == null && i + 1 < lines.length) {
          businessNumber = _extractStandaloneNumber(lines[i + 1]);
        }
      }

      if (line.contains('ACCOUNT') && (line.contains('NUMBER') || line.contains('NO'))) {
        accountNumber = _extractNumberAfter(current);
        if (accountNumber == null && i + 1 < lines.length) {
          accountNumber = _extractStandaloneNumber(lines[i + 1]);
        }
      }
    }

    if (businessNumber == null) {
      final nums = _findStandaloneNumbers(upperText);
      if (nums.isNotEmpty) businessNumber = nums[0];
      if (nums.length > 1) accountNumber ??= nums[1];
    }

    if (businessNumber != null) {
      confidence = accountNumber != null ? 0.95 : 0.8;
      targets.add(PaymentTarget(
        type: PaymentType.paybill,
        number: businessNumber,
        account: accountNumber,
        confidence: confidence,
      ));
    }
  }

  void _extractTill(List<String> lines, String upperText, List<PaymentTarget> targets) {
    final isTill = upperText.contains('TILL') ||
        upperText.contains('BUY GOODS') ||
        upperText.contains('BUY GOOD');

    if (!isTill) return;

    String? tillNumber;
    String? merchantName;
    double confidence = 0.7;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].toUpperCase();
      final current = lines[i];

      if (line.contains('TILL') && (line.contains('NUMBER') || line.contains('NO') || line.contains(':'))) {
        tillNumber = _extractNumberAfter(current);
        if (tillNumber == null && i + 1 < lines.length) {
          tillNumber = _extractStandaloneNumber(lines[i + 1]);
        }
      }

      if (!line.contains('TILL') && !line.contains('BUY') && !line.contains('GOOD')) {
        if (_isLikelyMerchantName(current)) {
          merchantName ??= current.trim();
        }
      }
    }

    if (tillNumber == null) {
      final nums = _findStandaloneNumbers(upperText);
      if (nums.isNotEmpty) tillNumber = nums[0];
    }

    if (tillNumber != null) {
      confidence = merchantName != null ? 0.95 : 0.8;
      targets.add(PaymentTarget(
        type: PaymentType.till,
        number: tillNumber,
        merchantName: merchantName,
        confidence: confidence,
      ));
    }
  }

  void _extractStoreNumber(List<String> lines, String upperText, List<PaymentTarget> targets) {
    final isStore = upperText.contains('STORE') ||
        upperText.contains('STORE NUMBER') ||
        upperText.contains('MERCHANT ID') ||
        upperText.contains('MERCHANT NUMBER');

    if (!isStore) return;

    String? storeNumber;
    double confidence = 0.7;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].toUpperCase();
      final current = lines[i];

      if ((line.contains('STORE') || line.contains('MERCHANT')) &&
          (line.contains('NUMBER') || line.contains('NO') || line.contains('ID'))) {
        storeNumber = _extractNumberAfter(current);
        if (storeNumber == null && i + 1 < lines.length) {
          storeNumber = _extractStandaloneNumber(lines[i + 1]);
        }
      }
    }

    if (storeNumber == null) {
      final nums = _findStandaloneNumbers(upperText);
      if (nums.isNotEmpty) storeNumber = nums[0];
    }

    if (storeNumber != null) {
      confidence = 0.8;
      targets.add(PaymentTarget(
        type: PaymentType.storeNumber,
        number: storeNumber,
        confidence: confidence,
      ));
    }
  }

  void _extractPhoneNumbers(String upperText, List<PaymentTarget> targets) {
    final phonePatterns = [
      RegExp(r'(?:\+254|254|0)?[17]\d{8}'),
      RegExp(r'(?:\+255|255)?[67]\d{8}'),
      RegExp(r'(?:\+256|256)?[7]\d{8}'),
      RegExp(r'(?:\+234|234)[789]\d{8}'),
      RegExp(r'(?:\+233|233)[25]\d{8}'),
      RegExp(r'(?:\+1|1)?[2-9]\d{9}'),
    ];

    final found = <String>{};

    for (final pattern in phonePatterns) {
      for (final match in pattern.allMatches(upperText)) {
        final num = match.group(0)!;
        if (num.length >= 9 && !found.any((f) => f.contains(num) || num.contains(f))) {
          found.add(num);
        }
      }
    }

    for (final phone in found) {
      targets.add(PaymentTarget(
        type: PaymentType.phone,
        number: phone,
        confidence: 0.75,
      ));
    }
  }

  void _extractFallbackNumbers(String upperText, List<PaymentTarget> targets) {
    final numbers = _findStandaloneNumbers(upperText);
    for (final num in numbers) {
      if (num.length >= 5 && num.length <= 15) {
        targets.add(PaymentTarget(
          type: PaymentType.unknown,
          number: num,
          confidence: 0.5,
        ));
      }
    }
  }

  String? _extractNumberAfter(String line) {
    final match = RegExp(r'[:\s](\d{4,12})').firstMatch(line);
    return match?.group(1);
  }

  String? _extractStandaloneNumber(String line) {
    final match = RegExp(r'^(\d{4,12})$').firstMatch(line.trim());
    return match?.group(1);
  }

  List<String> _findStandaloneNumbers(String text) {
    final matches = RegExp(r'\b(\d{4,12})\b').allMatches(text);
    return matches.map((m) => m.group(1)!).toList();
  }

  bool _isLikelyMerchantName(String text) {
    final cleaned = text.trim();
    if (cleaned.length < 3) return false;
    if (RegExp(r'^\d+$').hasMatch(cleaned)) return false;
    if (cleaned.toUpperCase().contains('NUMBER') || cleaned.toUpperCase().contains('TILL')) return false;
    return RegExp(r'[A-Z]').hasMatch(cleaned);
  }
}
