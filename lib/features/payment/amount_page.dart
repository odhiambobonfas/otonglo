import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otonglo/core/models/wallet.dart';
import 'package:otonglo/features/scanner/scanner_controller.dart';
import 'package:otonglo/features/payment/payment_confirmation.dart';
import 'package:provider/provider.dart';

class AmountPage extends StatefulWidget {
  final WalletProvider selectedWallet;

  const AmountPage({super.key, required this.selectedWallet});

  @override
  State<AmountPage> createState() => _AmountPageState();
}

class _AmountPageState extends State<AmountPage> {
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _amountFocus.requestFocus();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scanner = context.watch<ScannerController>();
    final target = scanner.selectedTarget;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Amount'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (target != null) _buildTargetInfo(target, theme),
            const SizedBox(height: 32),
            _buildWalletBadge(theme),
            const SizedBox(height: 32),
            _buildAmountField(theme),
            const SizedBox(height: 20),
            _buildReferenceField(theme),
            const SizedBox(height: 40),
            _buildContinueButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetInfo(dynamic target, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                target.merchantName ?? target.type.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                target.number,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletBadge(ThemeData theme) {
    return Row(
      children: [
        Text(
          'Paying with',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.selectedWallet.label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          focusNode: _amountFocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            prefixText: 'KES ',
            prefixStyle: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            filled: false,
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reference (optional)',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _referenceController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g. Shopping, Rent, Food',
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _onContinue,
        child: const Text(
          'Continue',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _onContinue() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final scanner = context.read<ScannerController>();
    final target = scanner.selectedTarget;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: scanner,
          child: PaymentConfirmationPage(
            target: target,
            wallet: widget.selectedWallet,
            amount: amount,
            reference: _referenceController.text.trim(),
          ),
        ),
      ),
    );
  }
}
