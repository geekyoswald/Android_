import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../main.dart';
import '../../../import/data/participant_repository.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  final _repository = ParticipantRepository();

  CameraController? _cameraController;
  bool _permissionGranted = false;
  bool _cameraReady = false;
  bool _isCapturing = false;

  int _presentCount = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissionAndInit();
    _loadCounts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _requestPermissionAndInit() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status.isGranted) {
      setState(() => _permissionGranted = true);
      await _initCamera();
    } else {
      setState(() => _permissionGranted = false);
    }
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty || !mounted) return;

    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller.initialize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _cameraController = controller;
      _cameraReady = true;
    });
  }

  Future<void> _loadCounts() async {
    final counts = await _repository.getStatusCounts();
    if (!mounted) return;
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final present = counts[1] ?? 0;
    setState(() {
      _presentCount = present;
      _totalCount = total;
    });
  }

  /// Capture a still image — OCR processing will be wired in Commit 23.
  Future<void> _captureAndScan() async {
    if (_isCapturing || _cameraController == null || !_cameraReady) return;
    setState(() => _isCapturing = true);
    try {
      final image = await _cameraController!.takePicture();
      if (!mounted) return;
      // Commit 23 will pass image.path to the OCR service here.
      // For now just show a snackbar confirming the capture worked.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image captured: ${image.name} — OCR coming in next step'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan ID Card'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Manual Search',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.manualSearch),
          ),
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Participant List',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.participantList),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Live counts bar ──────────────────────────────────────────────
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Present: $_presentCount / $_totalCount',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: _loadCounts,
                  icon: const Icon(Icons.refresh, color: Colors.white70, size: 18),
                  label: const Text('Refresh', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),

          // ── Camera preview or fallback ───────────────────────────────────
          Expanded(
            child: _buildCameraArea(),
          ),

          // ── Tap-to-scan button ───────────────────────────────────────────
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cameraReady ? Theme.of(context).colorScheme.primary : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                onPressed: _cameraReady && !_isCapturing ? _captureAndScan : null,
                icon: _isCapturing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.camera_alt),
                label: Text(_isCapturing ? 'Scanning…' : 'Tap to Scan'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraArea() {
    if (!_permissionGranted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, color: Colors.white54, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Camera permission is required to scan ID cards.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: openAppSettings,
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_cameraReady || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // Camera preview with framing guide overlay
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _cameraController!.value.previewSize!.height,
              height: _cameraController!.value.previewSize!.width,
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),
        // Framing guide
        Container(
          width: 280,
          height: 160,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        Positioned(
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Align ID card within the frame',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
