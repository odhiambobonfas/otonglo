import '../models/wallet.dart';

class PaymentConstants {
  PaymentConstants._();

  static const String appName = 'OTONGLO';

  static const List<WalletProvider> defaultWallets = [
    WalletProvider.mpesa,
    WalletProvider.airtelMoney,
    WalletProvider.tkash,
    WalletProvider.mtnMomo,
    WalletProvider.orangeMoney,
    WalletProvider.vodafoneCash,
    WalletProvider.moovMoney,
    WalletProvider.ecocash,
    WalletProvider.bank,
    WalletProvider.creditCard,
    WalletProvider.applePay,
    WalletProvider.googlePay,
    WalletProvider.samsungPay,
  ];

  static const Map<String, List<WalletProvider>> regionWallets = {
    'KE': [
      WalletProvider.mpesa,
      WalletProvider.airtelMoney,
      WalletProvider.tkash,
      WalletProvider.bank,
      WalletProvider.creditCard,
    ],
    'UG': [
      WalletProvider.mpesa,
      WalletProvider.mtnMomo,
      WalletProvider.airtelMoney,
      WalletProvider.bank,
    ],
    'TZ': [
      WalletProvider.mpesa,
      WalletProvider.airtelMoney,
      WalletProvider.bank,
    ],
    'NG': [
      WalletProvider.mtnMomo,
      WalletProvider.airtelMoney,
      WalletProvider.bank,
    ],
    'GH': [
      WalletProvider.mtnMomo,
      WalletProvider.vodafoneCash,
      WalletProvider.airtelMoney,
      WalletProvider.bank,
    ],
  };
}
