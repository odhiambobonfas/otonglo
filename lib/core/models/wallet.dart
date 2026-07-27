enum WalletProvider {
  mpesa('M-Pesa', 'M-Pesa'),
  airtelMoney('Airtel Money', 'Airtel Money'),
  tkash('T-Kash', 'Telkom T-Kash'),
  mtnMomo('MTN MoMo', 'MTN Mobile Money'),
  orangeMoney('Orange Money', 'Orange Money'),
  vodafoneCash('Vodafone Cash', 'Vodafone Cash'),
  moovMoney('Moov Money', 'Moov Money'),
  ecocash('EcoCash', 'EcoCash'),
  bank('Bank Transfer', 'Bank'),
  creditCard('Credit Card', 'Credit Card'),
  applePay('Apple Pay', 'Apple Pay'),
  googlePay('Google Pay', 'Google Pay'),
  samsungPay('Samsung Pay', 'Samsung Pay');

  final String label;
  final String shortName;
  const WalletProvider(this.label, this.shortName);
}

class Wallet {
  final WalletProvider provider;
  final String? phoneNumber;
  final String? accountNumber;
  final bool isSelected;

  const Wallet({
    required this.provider,
    this.phoneNumber,
    this.accountNumber,
    this.isSelected = false,
  });

  Wallet copyWith({
    WalletProvider? provider,
    String? phoneNumber,
    String? accountNumber,
    bool? isSelected,
  }) {
    return Wallet(
      provider: provider ?? this.provider,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      accountNumber: accountNumber ?? this.accountNumber,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
