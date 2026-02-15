import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:logging/logging.dart';
import '../core/constants/app_constants.dart';
import '../services/api_service.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final ApiService _apiService = ApiService();
  StreamChatClient? _client;
  Channel? _activeChannel;

  StreamChatClient? get client => _client;
  Channel? get activeChannel => _activeChannel;

  // Initialize Stream Chat client
  Future<void> initialize(
    String userId,
    String userName,
    String? imageUrl,
  ) async {
    try {
      _client = StreamChatClient(
        AppConstants.streamApiKey,
        logLevel: Level.SEVERE,
      );

      // Get token from backend
      final tokenData = await _apiService.getStreamToken();
      final token = tokenData['token']!;

      final user = User(id: userId, name: userName, image: imageUrl);

      await _client!.connectUser(user, token);
      debugPrint('Stream Chat client initialized');
    } catch (e) {
      debugPrint('Error initializing Stream Chat: $e');
      rethrow;
    }
  }

  // Join a channel (stream chat)
  Future<Channel?> joinChannel(String callId) async {
    if (_client == null) {
      debugPrint('Stream Chat client not initialized');
      return null;
    }

    try {
      _activeChannel = _client!.channel('livestream', id: callId);

      await _activeChannel!.watch();
      debugPrint('Chat channel joined: $callId');
      return _activeChannel;
    } catch (e) {
      debugPrint('Error joining chat channel: $e');
      rethrow;
    }
  }

  // Send a message
  Future<void> sendMessage(String text) async {
    if (_activeChannel == null) return;

    try {
      await _activeChannel!.sendMessage(Message(text: text));
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  // Leave channel
  Future<void> leaveChannel() async {
    _activeChannel = null;
  }

  // Dispose
  Future<void> dispose() async {
    await _client?.disconnectUser();
    _client = null;
  }
}
