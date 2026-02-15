import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  Channel? _activeChannel;
  bool _isLoading = false;
  String? _error;

  Channel? get activeChannel => _activeChannel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _activeChannel != null;

  // Initialize Stream Chat
  Future<void> initialize(
    String userId,
    String userName,
    String? imageUrl,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _chatService.initialize(userId, userName, imageUrl);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Chat initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Join chat channel
  Future<bool> joinChat(String callId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activeChannel = await _chatService.joinChannel(callId);
      _isLoading = false;
      notifyListeners();
      return _activeChannel != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Send message
  Future<void> sendMessage(String text) async {
    try {
      await _chatService.sendMessage(text);
    } catch (e) {
      _error = e.toString();
      debugPrint('Send message error: $e');
      notifyListeners();
    }
  }

  // Leave chat
  Future<void> leaveChat() async {
    await _chatService.leaveChannel();
    _activeChannel = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _chatService.dispose();
    super.dispose();
  }
}
