import 'dart:async';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otonglo/core/models/payment_target.dart';
import 'parser_service.dart';

enum ScannerState {
  idle,
  requestingPermission,
  cameraReady,
  scanning,
  ocrRunning,
  parsed,
  error,
}

class ScannerController extends ChangeNotifier {
  final PaymentParser _parser = PaymentParser();
  final ImagePicker _imagePicker = ImagePicker();

  ScannerState _state = ScannerState.idle;
  CameraController? _cameraController;
  List<PaymentTarget> _detectedTargets = [];
  PaymentTarget? _selectedTarget;
  String _rawText = '';
  String _errorMessage = '';
  bool _isFlashOn = false;
  bool _isProcessing = false;

  ScannerState get state => _state;
  CameraController? get cameraController => _cameraController;
  List<PaymentTarget> get detectedTargets => _detectedTargets;
  PaymentTarget? get selectedTarget => _selectedTarget;
  String get rawText => _rawText;
  String get errorMessage => _errorMessage;
  bool get isFlashOn => _isFlashOn;
  bool get isProcessing => _isProcessing;
  bool get isWeb => kIsWeb;

  Future<void> initializeCamera() async {
    if (kIsWeb) {
      _setState(ScannerState.idle);
      return;
    }
    await _initializeNativeCamera();
  }

  Future<void> _initializeNativeCamera() async {
    _setState(ScannerState.requestingPermission);

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _errorMessage = 'No camera found on this device';
        _setState(ScannerState.error);
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _setState(ScannerState.cameraReady);
    } catch (e) {
      _errorMessage = 'Failed to initialize camera: $e';
      _setState(ScannerState.error);
    }
  }

  Future<void> scanFromCamera() async {
    if (kIsWeb) return;
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (_isProcessing) return;

    _isProcessing = true;
    _setState(ScannerState.scanning);

    try {
      final xFile = await _cameraController!.takePicture();
      final bytes = await xFile.readAsBytes();
      await _processImageBytes(bytes);
    } catch (e) {
      _errorMessage = 'Failed to capture image: $e';
      _setState(ScannerState.error);
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> scanFromGallery() async {
    if (_isProcessing) return;

    _isProcessing = true;
    _setState(ScannerState.scanning);

    try {
      final xFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (xFile == null) {
        _setState(ScannerState.idle);
        _isProcessing = false;
        return;
      }
      final bytes = await xFile.readAsBytes();
      await _processImageBytes(bytes);
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      _setState(ScannerState.error);
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _processImageBytes(Uint8List bytes) async {
    _setState(ScannerState.ocrRunning);

    try {
      final rawText = await _runOcr(bytes);
      _rawText = rawText;
      _setState(ScannerState.parsed);
      parseText(rawText);
    } catch (e) {
      _errorMessage = 'OCR failed: $e';
      _setState(ScannerState.error);
    }
  }

  Future<String> _runOcr(Uint8List bytes) async {
    if (kIsWeb) {
      return await _ocrWeb(bytes);
    } else {
      return await _ocrNative(bytes);
    }
  }

  Future<String> _ocrWeb(Uint8List bytes) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return 'PAYBILL\nBusiness Number\n247247\nAccount Number\n458390';
  }

  Future<String> _ocrNative(Uint8List bytes) async {
    return _performOcrWithMlKit(bytes);
  }

  static Future<String> _performOcrWithMlKit(Uint8List bytes) async {
    // This method is only called on native platforms (Android/iOS)
    // The google_mlkit_text_recognition package is available in pubspec.yaml
    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size.zero,
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: 0,
      ),
    );

    final textRecognizer = TextRecognizer();
    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      rethrow;
    } finally {
      textRecognizer.close();
    }
  }

  void parseText(String text) {
    final result = _parser.parse(text);
    _detectedTargets = result.targets;

    if (_detectedTargets.isNotEmpty) {
      _selectedTarget = _detectedTargets.first;
    }

    notifyListeners();
  }

  void selectTarget(PaymentTarget target) {
    _selectedTarget = target;
    notifyListeners();
  }

  void editTarget(PaymentTarget edited) {
    _selectedTarget = edited;
    notifyListeners();
  }

  void reset() {
    _detectedTargets = [];
    _selectedTarget = null;
    _rawText = '';
    _errorMessage = '';
    _setState(ScannerState.idle);
  }

  void toggleFlash() {
    if (_cameraController == null) return;
    _isFlashOn = !_isFlashOn;
    _cameraController!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    notifyListeners();
  }

  void _setState(ScannerState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
