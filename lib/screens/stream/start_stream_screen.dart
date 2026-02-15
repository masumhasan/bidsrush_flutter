import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/video_stream_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'broadcast_screen.dart';

/// Mobile-first Start Stream Screen
class StartStreamScreen extends StatefulWidget {
  const StartStreamScreen({super.key});

  @override
  State<StartStreamScreen> createState() => _StartStreamScreenState();
}

class _StartStreamScreenState extends State<StartStreamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _apiService = ApiService();
  bool _enableRecording = true;
  bool _isCreating = false;

  // Camera state
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFrontCamera = true;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    _initializeApiService();
    _initializeCamera();
  }

  Future<void> _initializeApiService() async {
    // Get auth token and set it on ApiService
    final token = await AuthService().getToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  Future<void> _initializeCamera() async {
    // Skip camera on web - not well supported
    if (kIsWeb) {
      setState(() {
        _cameraError = 'Camera preview available on mobile';
      });
      return;
    }

    try {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();

      if (cameraStatus.isDenied || micStatus.isDenied) {
        setState(() {
          _cameraError = 'Camera or microphone permission denied';
        });
        return;
      }

      if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
        setState(() {
          _cameraError = 'Please enable permissions in settings';
        });
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _cameraError = 'No cameras available';
        });
        return;
      }

      // Find front camera
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      await _setupCamera(frontCamera);
    } catch (e) {
      setState(() {
        _cameraError = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    _cameraController?.dispose();

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false, // Audio handled by stream
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isFrontCamera = camera.lensDirection == CameraLensDirection.front;
        });
      }
    } catch (e) {
      setState(() {
        _cameraError = 'Camera initialization failed: $e';
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    final newCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection != (_isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
      orElse: () => _cameras!.first,
    );

    await _setupCamera(newCamera);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _handleStartStream() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    final title = _titleController.text.trim();
    final authProvider = context.read<AuthProvider>();
    final streamProvider = context.read<VideoStreamProvider>();
    final chatProvider = context.read<ChatProvider>();

    try {
      // Step 1: Dispose the local camera controller immediately to release hardware
      debugPrint('[StartStream] Disposing local camera preview to release hardware...');
      await _cameraController?.dispose();
      _cameraController = null;
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }

      // Step 2: Give OS a moment to fully release the camera resource
      await Future.delayed(const Duration(milliseconds: 500));

      // Generate unique call ID
      final callId = const Uuid().v4();

      debugPrint('Creating stream with callId: $callId');

      // Create stream in backend
      await _apiService.createStream(
        callId: callId,
        title: title,
        isRecordingEnabled: _enableRecording,
      );

      debugPrint('Stream created in backend');

      // Initialize Stream.io if not already
      if (streamProvider.activeCall == null) {
        debugPrint('Initializing stream provider...');
        await streamProvider.initialize(authProvider.user!.id);
      }

      // Initialize Chat if not already
      final chatProvider = context.read<ChatProvider>();
      if (!chatProvider.isConnected) {
        debugPrint('Initializing chat provider...');
        await chatProvider.initialize(
          authProvider.user!.id,
          authProvider.user!.displayName,
          authProvider.user!.imageUrl,
        );
      }

      // Start the stream with timeout
      debugPrint('Starting stream...');
      final success = await streamProvider.startStream(
        callId,
        enableRecording: _enableRecording,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('Stream start timed out');
          return false;
        },
      );

      if (success) {
        debugPrint('Stream started, joining chat...');
        await chatProvider.joinChat(callId);
      }

      if (success && mounted) {
        debugPrint('Navigating to broadcast screen');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => BroadcastScreen(
              callId: callId,
              title: title,
            ),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(
              streamProvider.error ?? 'Failed to start stream'
            )),
          );
        }
      }
    } catch (e) {
      debugPrint('Error in _handleStartStream: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1a1a1a)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Go Live',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1a1a1a),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalMargin = constraints.maxWidth * 0.05;
            final verticalMargin = MediaQuery.of(context).size.height * 0.05;
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalMargin,
                  vertical: verticalMargin,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  const SizedBox(height: 16),
                  // Camera preview
                  Container(
                    height: 380,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0a0a0a),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Camera preview or placeholder
                        if (_isCameraInitialized && _cameraController != null)
                          Positioned.fill(
                            child: CameraPreview(_cameraController!),
                          )
                        else
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _cameraError != null ? Icons.error_outline : Icons.videocam_rounded,
                                  size: 56,
                                  color: const Color(0xFF444444),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _cameraError ?? 'Initializing camera...',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF666666),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        // Top controls
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: _switchCamera,
                                child: _buildPreviewControl(Icons.flip_camera_ios_rounded),
                              ),
                              const SizedBox(width: 8),
                              _buildPreviewControl(Icons.flash_off_rounded),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Stream title field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stream Title',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1a1a1a),
                        ),
                        decoration: InputDecoration(
                          hintText: 'What are you streaming today?',
                          hintStyle: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFAAAAAA),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F7),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E5E5),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF005FFF),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFDC2626),
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a stream title';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Recording toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE5E5E5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _enableRecording
                                ? const Color(0xFFFEE2E2)
                                : const Color(0xFFE5E5E5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.fiber_manual_record_rounded,
                            color: _enableRecording
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF999999),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Save Recording',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1a1a1a),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Keep the stream for later replay',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: const Color(0xFF666666).withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _enableRecording,
                          onChanged: (value) {
                            setState(() {
                              _enableRecording = value;
                            });
                          },
                          activeColor: const Color(0xFF005FFF),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Go Live button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isCreating ? null : _handleStartStream,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        disabledBackgroundColor: const Color(0xFFFFB3B3),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isCreating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.videocam_rounded, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  'Go Live',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPreviewControl(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
