import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:otonglo/core/theme/app_theme.dart';
import 'scanner_controller.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScannerController>().initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ScannerController>(
        builder: (context, scanner, _) {
          if (scanner.isWeb) {
            return _buildWebScanner(context, scanner);
          }
          return _buildNativeScanner(context, scanner);
        },
      ),
    );
  }

  Widget _buildWebScanner(BuildContext context, ScannerController scanner) {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(context, scanner),
          Expanded(child: _buildWebDemoArea(context, scanner)),
          _buildWebBottomBar(context, scanner),
        ],
      ),
    );
  }

  Widget _buildWebDemoArea(BuildContext context, ScannerController scanner) {
    if (scanner.state == ScannerState.ocrRunning) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.gold),
            SizedBox(height: 16),
            Text(
              'Analyzing image...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.gold.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.document_scanner,
                    size: 64,
                    color: AppTheme.gold,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Demo Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Web Preview',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Camera is not available in web preview.\nUse the options below to test the payment flow.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebBottomBar(BuildContext context, ScannerController scanner) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.blackLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => _showWebDemoDialog(context, scanner),
              icon: const Icon(Icons.text_fields),
              label: const Text(
                'Enter Payment Number',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => _showWebPresetDialog(context, scanner),
              icon: const Icon(Icons.qr_code),
              label: const Text(
                'Try Demo Scenarios',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWebDemoDialog(BuildContext context, ScannerController scanner) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Payment Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Type any number to test the parser.',
              style: TextStyle(fontSize: 13, color: AppTheme.gray),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.text,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'e.g. 589203, 247247, 0712345678',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.dispose();
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              Navigator.of(ctx).pop();
              controller.dispose();
              if (text.isNotEmpty) {
                scanner.parseText(text);
              }
            },
            child: const Text('Parse'),
          ),
        ],
      ),
    );
  }

  void _showWebPresetDialog(BuildContext context, ScannerController scanner) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Demo Scenarios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _presetOption(
              ctx,
              scanner,
              'Paybill',
              'PAYBILL\nBusiness Number\n247247\nAccount Number\n458390',
            ),
            _presetOption(
              ctx,
              scanner,
              'Buy Goods Till',
              'BUY GOODS\nTill Number\n589203',
            ),
            _presetOption(
              ctx,
              scanner,
              'Phone Number',
              '0712345678',
            ),
            _presetOption(
              ctx,
              scanner,
              'Store Number',
              'STORE NUMBER\n12345',
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetOption(
    BuildContext ctx,
    ScannerController scanner,
    String label,
    String text,
  ) {
    return ListTile(
      title: Text(label),
      subtitle: Text(
        text.replaceAll('\n', ' | '),
        style: const TextStyle(fontSize: 12),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.of(ctx).pop();
        scanner.parseText(text);
      },
    );
  }

  Widget _buildNativeScanner(BuildContext context, ScannerController scanner) {
    return Column(
      children: [
        _buildTopBar(context, scanner),
        Expanded(child: _buildCameraPreview(scanner)),
        _buildNativeBottomBar(context, scanner),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, ScannerController scanner) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            ),
            Text(
              scanner.isWeb ? 'Enter Payment Details' : 'Scan Merchant Number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!scanner.isWeb)
              IconButton(
                onPressed: scanner.toggleFlash,
                icon: Icon(
                  scanner.isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: scanner.isFlashOn ? AppTheme.gold : Colors.white,
                  size: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(ScannerController scanner) {
    if (scanner.state == ScannerState.requestingPermission) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.gold),
            SizedBox(height: 16),
            Text(
              'Requesting camera permission...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (scanner.state == ScannerState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
              const SizedBox(height: 16),
              Text(
                scanner.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => scanner.initializeCamera(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (scanner.cameraController == null ||
        !scanner.cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.gold),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        CameraPreview(scanner.cameraController!),
        _buildScanOverlay(),
        if (scanner.state == ScannerState.ocrRunning)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.gold),
                  SizedBox(height: 16),
                  Text(
                    'Reading text...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScanOverlay() {
    return CustomPaint(
      size: Size.infinite,
      painter: _ScanFramePainter(),
    );
  }

  Widget _buildNativeBottomBar(BuildContext context, ScannerController scanner) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.blackLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Keep payment details inside the rectangle',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.flash_off,
                label: 'Flash',
                onTap: scanner.toggleFlash,
              ),
              _buildScanButton(scanner),
              _buildActionButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: () => scanner.scanFromGallery(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(ScannerController scanner) {
    final isScanning = scanner.state == ScannerState.scanning ||
        scanner.state == ScannerState.ocrRunning;

    return GestureDetector(
      onTap: isScanning ? null : () => scanner.scanFromCamera(),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isScanning ? Colors.grey : AppTheme.gold,
          boxShadow: [
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: isScanning
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Icon(Icons.camera_alt, color: Colors.white, size: 36),
        ),
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.gold
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final frameWidth = size.width * 0.75;
    final frameHeight = size.height * 0.35;
    final rect = Rect.fromCenter(
      center: center,
      width: frameWidth,
      height: frameHeight,
    );

    const cornerLen = 30.0;

    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLen),
      Offset(rect.left, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLen, rect.top),
      paint,
    );

    canvas.drawLine(
      Offset(rect.right, rect.top + cornerLen),
      Offset(rect.right, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right - cornerLen, rect.top),
      paint,
    );

    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLen),
      Offset(rect.left, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLen, rect.bottom),
      paint,
    );

    canvas.drawLine(
      Offset(rect.right, rect.bottom - cornerLen),
      Offset(rect.right, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right - cornerLen, rect.bottom),
      paint,
    );

    final dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    canvas.drawRect(
      Rect.fromLTRB(0, 0, size.width, rect.top),
      dimPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(0, rect.bottom, size.width, size.height),
      dimPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(0, rect.top, rect.left, rect.bottom),
      dimPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(rect.right, rect.top, size.width, rect.bottom),
      dimPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
