import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../ocr_service.dart';

class ScanReceiptScreen extends StatefulWidget {
  const ScanReceiptScreen({Key? key}) : super(key: key);

  @override
  State<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends State<ScanReceiptScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitializing = true;
  bool _isProcessing = false;
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final GlobalKey _previewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      final cam = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );
      _controller = CameraController(cam, ResolutionPreset.high, enableAudio: false);
      await _controller!.initialize();
    } catch (_) {
      // ignore init errors; show fallback UI
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<ui.Image> _decodeImageFromBytes(Uint8List bytes) {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) => completer.complete(img));
    return completer.future;
  }

  Future<void> _captureAndProcess() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final XFile file = await _controller!.takePicture();
      final Uint8List bytes = await file.readAsBytes();
      final ui.Image decoded = await _decodeImageFromBytes(bytes);

      final input = InputImage.fromFilePath(file.path);
      final RecognizedText recognized = await _textRecognizer.processImage(input);

      // --- ROI on-screen (smaller) ---
      final screenSize = MediaQuery.of(context).size;
      final previewBox = _previewKey.currentContext?.size ?? screenSize;

      // Make the box smaller: 70% width, shorter height
      final holeWidth = screenSize.width * 0.70;
      const holeHeight = 90.0;
      final left = (screenSize.width - holeWidth) / 2;
      final top = screenSize.height * 0.38; // slightly lower

      // Map preview widget coords -> image coords.
      // CameraPreview usually uses BoxFit.cover: image is scaled by max(scaleX, scaleY) and centered.
      final imageW = decoded.width.toDouble();
      final imageH = decoded.height.toDouble();
      final previewW = previewBox.width;
      final previewH = previewBox.height;

      final scale = (imageW / previewW).compareTo(imageH / previewH) > 0
          ? imageW / previewW
          : imageH / previewH; // max(imageW/previewW, imageH/previewH)
      final visibleImageW = previewW * scale;
      final visibleImageH = previewH * scale;
      final offsetX = (imageW - visibleImageW) / 2;
      final offsetY = (imageH - visibleImageH) / 2;

      final roiImage = Rect.fromLTWH(
        offsetX + left * scale,
        offsetY + top * scale,
        holeWidth * scale,
        holeHeight * scale,
      );

      // Debug info
      debugPrint('decoded image size: ${decoded.width} x ${decoded.height}');
      debugPrint('preview widget size: $previewW x $previewH');
      debugPrint('scale: $scale, offset: $offsetX, $offsetY');
      debugPrint('roiImage: $roiImage');

      // Try ROI-first extraction
      double amount = ReceiptOcrHelper.extractTotalFromRecognizedText(recognized, roiImage);
      debugPrint('amount from ROI -> $amount');

      // If ROI found nothing, fallback to full image extraction and log
      if (amount == 0.0) {
        debugPrint('ROI returned 0. Trying full-image extraction...');
        amount = ReceiptOcrHelper.extractTotalFromRecognizedText(recognized, null);
        debugPrint('amount from full image -> $amount');
      }

      if (mounted) Navigator.of(context).pop(amount);
    } catch (e, st) {
      debugPrint('capture/process error: $e\n$st');
      if (mounted) Navigator.of(context).pop(0.0);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final holeWidth = size.width * 0.70; // updated smaller
    const holeHeight = 90.0; // updated smaller

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isInitializing
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  // Camera preview with key
                  Positioned.fill(
                    child: Container(
                      key: _previewKey,
                      child: (_controller != null && _controller!.value.isInitialized)
                          ? CameraPreview(_controller!)
                          : const ColoredBox(color: Colors.black),
                    ),
                  ),

                  // Dark overlay + transparent hole
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Stack(
                        children: [
                          Positioned.fill(child: Container(color: Colors.black54)),
                          // Transparent hole: we place a CustomPaint of hole size and rely on painter's clear technique
                          Positioned(
                            top: size.height * 0.38,
                            left: (size.width - holeWidth) / 2,
                            child: SizedBox(
                              width: holeWidth,
                              height: holeHeight,
                              child: CustomPaint(painter: _HolePainter()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Green border over hole
                  Positioned(
                    top: size.height * 0.38 - 4,
                    left: (size.width - holeWidth) / 2 - 4,
                    child: Container(
                      width: holeWidth + 8,
                      height: holeHeight + 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.greenAccent.shade400, width: 4),
                      ),
                    ),
                  ),

                  // Instruction text
                  Positioned(
                    top: size.height * 0.38 + holeHeight + 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Align total inside the box and tap capture',
                        style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 14),
                      ),
                    ),
                  ),

                  // Capture FAB
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FloatingActionButton(
                        onPressed: _isProcessing ? null : _captureAndProcess,
                        backgroundColor: Colors.green,
                        child: _isProcessing ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.camera),
                      ),
                    ),
                  ),

                  // Close button
                  Positioned(
                    top: 12,
                    left: 12,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(0.0),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Painter unchanged (hole using clear)
class _HolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintClear = Paint()..blendMode = BlendMode.clear;
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black54);
    final r = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8));
    canvas.drawRRect(r, paintClear);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

