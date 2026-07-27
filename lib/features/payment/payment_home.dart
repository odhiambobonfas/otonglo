import 'package:flutter/material.dart';
import 'package:otonglo/core/models/payment_result.dart';
import 'package:otonglo/core/theme/app_theme.dart';
import 'package:otonglo/core/utils/formatters.dart';
import 'package:otonglo/features/scanner/scanner_controller.dart';
import 'package:otonglo/features/scanner/camera_page.dart';
import 'package:otonglo/features/payment/wallet_selector.dart';
import 'package:provider/provider.dart';

class PaymentHome extends StatefulWidget {
  const PaymentHome({super.key});

  @override
  State<PaymentHome> createState() => _PaymentHomeState();
}

class _PaymentHomeState extends State<PaymentHome> {
  final List<PaymentResult> _recentPayments = [];
  final _manualController = TextEditingController();

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OTONGLO',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.gold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Universal Payment Scanner',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildScanButton(context, theme),
                    const SizedBox(height: 16),
                    _buildManualEntryButton(context, theme),
                    const SizedBox(height: 32),
                    Text(
                      'Recent Payments',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (_recentPayments.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildEmptyState(theme),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildRecentPaymentItem(
                    _recentPayments[index],
                    theme,
                  ),
                  childCount: _recentPayments.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () => _openScanner(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.black, AppTheme.blackLight],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 40,
                color: AppTheme.gold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Scan Payment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Point camera at merchant number',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualEntryButton(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () => _showManualEntryDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.keyboard,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              'Manual Entry',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No recent payments',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan a merchant number to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPaymentItem(PaymentResult payment, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: payment.status == PaymentStatus.success
                  ? AppTheme.gold.withValues(alpha: 0.15)
                  : Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              payment.status == PaymentStatus.success
                  ? Icons.check
                  : Icons.close,
              color: payment.status == PaymentStatus.success
                  ? AppTheme.gold
                  : Colors.red,
            ),
          ),
          title: Text(
            payment.merchantName ?? payment.targetType,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${payment.walletName} - ${Formatters.dateShort(payment.timestamp)}',
            style: theme.textTheme.bodySmall,
          ),
          trailing: Text(
            Formatters.currency(payment.amount),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  void _openScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ScannerController(),
          child: const _ScannerFlow(),
        ),
      ),
    );
  }

  void _showManualEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Payment Number'),
        content: TextField(
          controller: _manualController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. 589203, 247247, 0712345678',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _manualController.clear();
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = _manualController.text.trim();
              Navigator.of(ctx).pop();
              _manualController.clear();
              if (text.isNotEmpty) {
                _processManualEntry(context, text);
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _processManualEntry(BuildContext context, String text) {
    final controller = ScannerController();
    controller.parseText(text);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: const WalletSelectorPage(),
        ),
      ),
    );
  }
}

class _ScannerFlow extends StatelessWidget {
  const _ScannerFlow();

  @override
  Widget build(BuildContext context) {
    return Consumer<ScannerController>(
      builder: (context, scanner, _) {
        if (scanner.state == ScannerState.parsed ||
            scanner.detectedTargets.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToWalletSelection(context, scanner);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (scanner.selectedTarget != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToWalletSelection(context, scanner);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return const CameraPage();
      },
    );
  }

  void _navigateToWalletSelection(BuildContext context, ScannerController scanner) {
    if (scanner.selectedTarget == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: scanner,
          child: const WalletSelectorPage(),
        ),
      ),
    );
  }
}
