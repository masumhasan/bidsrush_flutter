import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import '../core/constants/app_constants.dart';
import '../services/api_service.dart';

class StreamService {
  static final StreamService _instance = StreamService._internal();
  factory StreamService() => _instance;
  StreamService._internal();

  final ApiService _apiService = ApiService();
  StreamVideo? _client;
  Call? _activeCall;
  bool _isHost = false;

  StreamVideo? get client => _client;
  Call? get activeCall => _activeCall;
  bool get isHost => _isHost;

  // Initialize Stream Video client
  Future<void> initialize(String userId) async {
    try {
      // Get token from backend
      final tokenData = await _apiService.getStreamToken();
      final token = tokenData['token']!;

      _client = StreamVideo(
        AppConstants.streamApiKey,
        user: User.regular(userId: userId, name: userId),
        userToken: token,
      );

      debugPrint('Stream Video client initialized');
    } catch (e) {
      debugPrint('Error initializing Stream Video: $e');
      rethrow;
    }
  }

  // Create and join a livestream call (host)
  Future<Call?> createLivestream(String callId) async {
    if (_client == null) {
      debugPrint('Stream Video client not initialized');
      return null;
    }

    try {
      _isHost = true;
      _activeCall = _client!.makeCall(
        callType: StreamCallType.liveStream(),
        id: callId,
      );

      // Create or get the call, then join
      await _activeCall!.getOrCreate().timeout(const Duration(seconds: 15));
      await _activeCall!.join().timeout(const Duration(seconds: 15));

      debugPrint('Livestream created and joined: $callId');
      
      // Wait a significant moment for the call state to stabilize and camera hardware to be ready
      await Future.delayed(const Duration(milliseconds: 1500));

      // Enable camera and microphone for host - wrap in individual try-catches with longer delays
      try {
        debugPrint('Attempting to enable camera...');
        await _activeCall!.setCameraEnabled(enabled: true);
        debugPrint('Camera enabled successfully');
      } catch (e) {
        debugPrint('Warning: Could not enable camera: $e');
      }

      await Future.delayed(const Duration(milliseconds: 500));

      try {
        debugPrint('Attempting to enable microphone...');
        await _activeCall!.setMicrophoneEnabled(enabled: true);
        debugPrint('Microphone enabled successfully');
      } catch (e) {
        debugPrint('Warning: Could not enable microphone: $e');
      }

      return _activeCall;
    } catch (e) {
      debugPrint('Error creating livestream: $e');
      _isHost = false;
      rethrow;
    }
  }

  // Go live - start broadcasting to viewers
  Future<void> goLive() async {
    if (_activeCall == null || !_isHost) {
      debugPrint('Cannot go live: no active call or not host');
      return;
    }

    try {
      await _activeCall!.goLive();
      debugPrint('Stream is now LIVE');
    } catch (e) {
      debugPrint('Error going live: $e');
      rethrow;
    }
  }

  // Stop live - stop broadcasting but keep call active
  Future<void> stopLive() async {
    if (_activeCall == null || !_isHost) return;

    try {
      await _activeCall!.stopLive();
      debugPrint('Stream stopped live');
    } catch (e) {
      debugPrint('Error stopping live: $e');
      rethrow;
    }
  }

  // Join an existing livestream (viewer)
  Future<Call?> joinLivestream(String callId) async {
    if (_client == null) {
      debugPrint('Stream Video client not initialized');
      return null;
    }

    try {
      _isHost = false;
      _activeCall = _client!.makeCall(
        callType: StreamCallType.liveStream(),
        id: callId,
      );

      // Join as viewer (won't be able to publish)
      await _activeCall!.join();

      debugPrint('Joined livestream: $callId');
      
      // Wait a moment before disabling camera/mic
      await Future.delayed(const Duration(milliseconds: 300));

      // Disable camera and microphone for viewers
      try {
        await _activeCall!.setCameraEnabled(enabled: false);
        await _activeCall!.setMicrophoneEnabled(enabled: false);
        debugPrint('Camera and mic disabled for viewer');
      } catch (e) {
        debugPrint('Warning: Could not disable camera/mic: $e');
      }

      return _activeCall;
    } catch (e) {
      debugPrint('Error joining livestream: $e');
      rethrow;
    }
  }

  // Legacy methods for compatibility
  Future<Call?> createCall(String callId) => createLivestream(callId);
  Future<Call?> joinCall(String callId) => joinLivestream(callId);

  // Leave call
  Future<void> leaveCall() async {
    if (_activeCall == null) return;

    try {
      await _activeCall!.leave();
      _activeCall = null;
      _isHost = false;
      debugPrint('Call left');
    } catch (e) {
      debugPrint('Error leaving call: $e');
      rethrow;
    }
  }

  // End call (host only)
  Future<void> endCall() async {
    if (_activeCall == null) return;

    try {
      if (_isHost) {
        await stopLive();
      }
      await _activeCall!.end();
      _activeCall = null;
      _isHost = false;
      debugPrint('Call ended');
    } catch (e) {
      debugPrint('Error ending call: $e');
      rethrow;
    }
  }

  // Toggle camera
  Future<void> toggleCamera() async {
    if (_activeCall == null) return;

    try {
      final isEnabled =
          _activeCall!.state.value.localParticipant?.isVideoEnabled ?? false;
      await _activeCall!.setCameraEnabled(enabled: !isEnabled);
    } catch (e) {
      debugPrint('Error toggling camera: $e');
      rethrow;
    }
  }

  // Toggle microphone
  Future<void> toggleMicrophone() async {
    if (_activeCall == null) return;

    try {
      final isEnabled =
          _activeCall!.state.value.localParticipant?.isAudioEnabled ?? false;
      await _activeCall!.setMicrophoneEnabled(enabled: !isEnabled);
    } catch (e) {
      debugPrint('Error toggling microphone: $e');
      rethrow;
    }
  }

  // Flip camera
  Future<void> flipCamera() async {
    if (_activeCall == null) return;

    try {
      await _activeCall!.flipCamera();
    } catch (e) {
      debugPrint('Error flipping camera: $e');
      rethrow;
    }
  }

  // Start recording
  Future<void> startRecording() async {
    if (_activeCall == null) return;

    try {
      await _activeCall!.startRecording();
      debugPrint('Recording started');
    } catch (e) {
      debugPrint('Error starting recording: $e');
      rethrow;
    }
  }

  // Stop recording
  Future<void> stopRecording() async {
    if (_activeCall == null) return;

    try {
      await _activeCall!.stopRecording();
      debugPrint('Recording stopped');
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      rethrow;
    }
  }

  // Dispose
  Future<void> dispose() async {
    await leaveCall();
    await _client?.dispose();
    _client = null;
  }
}
