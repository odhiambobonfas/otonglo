import 'package:flutter/material.dart';
import 'package:otonglo/core/models/payment_result.dart';
import 'package:otonglo/core/theme/app_theme.dart';
import 'package:otonglo/core/utils/formatters.dart';

class ReceiptPage extends StatelessWidget {
  final PaymentResult result;

  const ReceiptPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSuccess = result.status == PaymentStatus.success;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    _buildStatusIcon(isSuccess, theme),
                    const SizedBox(height: 24),
                    Text(
                      isSuccess ? 'Payment Successful' : 'Payment Failed',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Formatters.currency(result.amount),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.gold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildReceiptCard(theme),
                  ],
                ),
              ),
            ),
            _buildBottomActions(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(bool isSuccess, ThemeData theme) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: (isSuccess ? AppTheme.gold : Colors.red).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isSuccess ? Icons.check_rounded : Icons.close_rounded,
        size: 56,
        color: isSuccess ? AppTheme.gold : Colors.red,
      ),
    );
  }

  Widget _buildReceiptCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (result.receiptCode != null) ...[
              _buildReceiptRow(
                'Receipt',
                result.receiptCode!,
                theme,
                isBold: true,
              ),
              const Divider(height: 24),
            ],
            if (result.merchantName != null)
              _buildReceiptRow('Merchant', result.merchantName!, theme),
            _buildReceiptRow('Number', result.targetNumber, theme),
            _buildReceiptRow('Type', result.targetType, theme),
            _buildReceiptRow('Wallet', result.walletName, theme),
            _buildReceiptRow(
              'Date',
              Formatters.date(result.timestamp),
              theme,
            ),
            if (result.reference != null && result.reference!.isNotEmpty)
              _buildReceiptRow('Reference', result.reference!, theme),
            const Divider(height: 24),
            _buildReceiptRow(
              'Amount',
              Formatters.currency(result.amount),
              theme,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value,
    ThemeData theme, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
              style: TextStyle(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                fontSize: isBold ? 16 : 14,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
