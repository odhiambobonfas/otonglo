import 'package:flutter/material.dart';
import 'package:otonglo/core/models/payment_target.dart';
import 'package:otonglo/core/models/wallet.dart';
import 'package:otonglo/core/models/payment_result.dart';
import 'package:otonglo/core/theme/app_theme.dart';
import 'package:otonglo/core/utils/formatters.dart';
import 'package:otonglo/features/payment/receipt_page.dart';

class PaymentConfirmationPage extends StatefulWidget {
  final PaymentTarget? target;
  final WalletProvider wallet;
  final double amount;
  final String? reference;

  const PaymentConfirmationPage({
    super.key,
    this.target,
    required this.wallet,
    required this.amount,
    this.reference,
  });

  @override
  State<PaymentConfirmationPage> createState() =>
      _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildAmountDisplay(theme),
                  const SizedBox(height: 32),
                  _buildDetailsCard(theme),
                  const SizedBox(height: 24),
                  _buildFeeNotice(theme),
                ],
              ),
            ),
          ),
          _buildConfirmButton(theme),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay(ThemeData theme) {
    return Column(
      children: [
        Text(
          Formatters.currency(widget.amount),
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppTheme.gold,
          ),
        ),
        const SizedBox(height: 4),
        if (widget.reference != null && widget.reference!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.reference!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (widget.target?.merchantName != null)
              _buildDetailRow(
                'Merchant',
                widget.target!.merchantName!,
                theme,
              ),
            _buildDetailRow(
              widget.target?.type.label ?? 'Number',
              widget.target?.number ?? 'N/A',
              theme,
            ),
            _buildDetailRow(
              'Wallet',
              widget.wallet.label,
              theme,
            ),
            if (widget.reference != null && widget.reference!.isNotEmpty)
              _buildDetailRow('Reference', widget.reference!, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeNotice(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: AppTheme.gold,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Transaction fees may apply depending on your provider',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: _isProcessing ? null : _onConfirm,
          child: _isProcessing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Confirm Payment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final result = PaymentResult(
      targetNumber: widget.target?.number ?? 'N/A',
      targetType: widget.target?.type.label ?? 'Manual',
      walletName: widget.wallet.label,
      amount: widget.amount,
      reference: widget.reference,
      merchantName: widget.target?.merchantName,
      status: PaymentStatus.success,
      receiptCode: Formatters.reference(),
    );

    setState(() => _isProcessing = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReceiptPage(result: result),
      ),
    );
  }
}
