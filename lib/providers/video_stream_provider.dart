import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import '../services/stream_service.dart';

class VideoStreamProvider with ChangeNotifier {
  final StreamService _streamService = StreamService();

  Call? _activeCall;
  bool _isLoading = false;
  String? _error;
  bool _isCameraEnabled = true;
  bool _isMicEnabled = true;
  bool _isRecording = false;
  bool _isLive = false;

  Call? get activeCall => _activeCall;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCameraEnabled => _isCameraEnabled;
  bool get isMicEnabled => _isMicEnabled;
  bool get isRecording => _isRecording;
  bool get isStreaming => _activeCall != null;
  bool get isLive => _isLive;
  bool get isHost => _streamService.isHost;

  // Initialize Stream Video
  Future<void> initialize(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _streamService.initialize(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Stream initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create and start livestream (host)
  Future<bool> startStream(
    String callId, {
    bool enableRecording = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('[VideoStreamProvider] Creating livestream $callId...');
      _activeCall = await _streamService.createLivestream(callId);

      if (_activeCall != null) {
        debugPrint('[VideoStreamProvider] Call created, waiting to go live...');
        // Wait for state to synchronize
        await Future.delayed(const Duration(seconds: 1));
        
        // Go live immediately
        debugPrint('[VideoStreamProvider] Calling goLive...');
        await _streamService.goLive();
        _isLive = true;

        if (enableRecording) {
          debugPrint('[VideoStreamProvider] Starting recording...');
          await _streamService.startRecording();
          _isRecording = true;
        }
      }

      _isLoading = false;
      notifyListeners();
      return _activeCall != null;
    } catch (e) {
      debugPrint('[VideoStreamProvider] Error in startStream: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Go live (if not already)
  Future<void> goLive() async {
    if (_activeCall == null || _isLive) return;

    try {
      await _streamService.goLive();
      _isLive = true;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Go live error: $e');
      notifyListeners();
    }
  }

  // Stop live but keep call
  Future<void> stopLive() async {
    if (_activeCall == null || !_isLive) return;

    try {
      await _streamService.stopLive();
      _isLive = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Stop live error: $e');
      notifyListeners();
    }
  }

  // Join stream (viewer)
  Future<bool> joinStream(String callId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activeCall = await _streamService.joinLivestream(callId);
      _isLoading = false;
      notifyListeners();
      return _activeCall != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Leave stream
  Future<void> leaveStream() async {
    try {
      if (_isRecording) {
        await _streamService.stopRecording();
        _isRecording = false;
      }
      await _streamService.leaveCall();
      _activeCall = null;
      _isLive = false;
      _isCameraEnabled = true;
      _isMicEnabled = true;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Leave stream error: $e');
      notifyListeners();
    }
  }

  // End stream (host only)
  Future<void> endStream() async {
    try {
      if (_isRecording) {
        await _streamService.stopRecording();
        _isRecording = false;
      }
      await _streamService.endCall();
      _activeCall = null;
      _isLive = false;
      _isCameraEnabled = true;
      _isMicEnabled = true;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('End stream error: $e');
      notifyListeners();
    }
  }

  // Toggle camera
  Future<void> toggleCamera() async {
    try {
      await _streamService.toggleCamera();
      _isCameraEnabled = !_isCameraEnabled;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Toggle camera error: $e');
      notifyListeners();
    }
  }

  // Toggle microphone
  Future<void> toggleMicrophone() async {
    try {
      await _streamService.toggleMicrophone();
      _isMicEnabled = !_isMicEnabled;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Toggle microphone error: $e');
      notifyListeners();
    }
  }

  // Flip camera
  Future<void> flipCamera() async {
    try {
      await _streamService.flipCamera();
    } catch (e) {
      _error = e.toString();
      debugPrint('Flip camera error: $e');
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _streamService.dispose();
    super.dispose();
  }
}
