import 'package:flutter/material.dart';
import 'package:otonglo/core/models/wallet.dart';
import 'package:otonglo/core/constants/payment_constants.dart';
import 'package:otonglo/core/theme/app_theme.dart';
import 'package:otonglo/features/scanner/scanner_controller.dart';
import 'package:otonglo/features/payment/amount_page.dart';
import 'package:provider/provider.dart';

class WalletSelectorPage extends StatefulWidget {
  const WalletSelectorPage({super.key});

  @override
  State<WalletSelectorPage> createState() => _WalletSelectorPageState();
}

class _WalletSelectorPageState extends State<WalletSelectorPage> {
  WalletProvider? _selectedWallet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scanner = context.watch<ScannerController>();
    final target = scanner.selectedTarget;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Wallet'),
      ),
      body: Column(
        children: [
          if (target != null) _buildTargetSummary(target, theme),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose payment method',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: PaymentConstants.defaultWallets.length,
              itemBuilder: (context, index) {
                final wallet = PaymentConstants.defaultWallets[index];
                return _buildWalletOption(wallet, theme);
              },
            ),
          ),
          _buildContinueButton(theme),
        ],
      ),
    );
  }

  Widget _buildTargetSummary(dynamic target, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.store,
              color: AppTheme.gold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  target.type.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  target.number,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(target.confidence * 100).toInt()}%',
              style: const TextStyle(
                color: AppTheme.gold,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletOption(WalletProvider wallet, ThemeData theme) {
    final isSelected = _selectedWallet == wallet;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? AppTheme.gold
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _selectedWallet = wallet),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.gold.withValues(alpha: 0.15)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      wallet.shortName.substring(0, 1),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppTheme.gold
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    wallet.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? AppTheme.gold : theme.colorScheme.outline,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: _selectedWallet != null ? _onContinue : null,
          child: Text(
            'Continue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _selectedWallet != null
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  void _onContinue() {
    if (_selectedWallet == null) return;
    final scanner = context.read<ScannerController>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: scanner,
          child: AmountPage(selectedWallet: _selectedWallet!),
        ),
      ),
    );
  }
}
