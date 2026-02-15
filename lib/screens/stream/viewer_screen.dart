import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import '../../providers/video_stream_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/chat/chat_overlay.dart';

/// Viewer Screen for watching livestreams
/// Uses Stream SDK's LivestreamPlayer for one-to-many viewing
class ViewerScreen extends StatefulWidget {
  final String callId;
  final String title;

  const ViewerScreen({
    super.key,
    required this.callId,
    required this.title,
  });

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  bool _isLoading = true;
  String? _error;
  bool _showChat = true;

  @override
  void initState() {
    super.initState();
    _joinStream();
  }

  Future<void> _joinStream() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final streamProvider = context.read<VideoStreamProvider>();
      final chatProvider = context.read<ChatProvider>();

      // Initialize Stream.io if not already
      if (streamProvider.activeCall == null) {
        await streamProvider.initialize(authProvider.user!.id);
      }

      // Join the livestream as viewer
      final success = await streamProvider.joinStream(widget.callId);

      if (success) {
        // Initialize and join chat
        if (!chatProvider.isConnected) {
          await chatProvider.initialize(
            authProvider.user!.id,
            authProvider.user!.displayName,
            authProvider.user!.imageUrl,
          );
        }
        await chatProvider.joinChat(widget.callId);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = success ? null : 'Failed to join stream';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _handleLeaveStream() async {
    final streamProvider = context.read<VideoStreamProvider>();
    final chatProvider = context.read<ChatProvider>();

    await streamProvider.leaveStream();
    await chatProvider.leaveChat();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : _error != null
                ? _buildErrorState()
                : _buildStreamContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Joining stream...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Error joining stream',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamContent() {
    return Consumer<VideoStreamProvider>(
      builder: (context, streamProvider, _) {
        final call = streamProvider.activeCall;

        if (call == null) {
          return _buildErrorState();
        }

        return Stack(
          children: [
            // Stream Video - Full screen LivestreamPlayer
            Positioned.fill(
              child: StreamBuilder<CallState>(
                stream: call.state.asStream(),
                builder: (context, snapshot) {
                  final callState = snapshot.data ?? call.state.value;
                  final participants = callState.callParticipants;
                  
                  // Find the host (first participant that's not local)
                  final hostParticipant = participants.firstWhere(
                    (p) => !p.isLocal,
                    orElse: () => participants.isNotEmpty 
                        ? participants.first 
                        : callState.localParticipant!,
                  );

                  if (callState.status != CallStatus.connected()) {
                    return Container(
                      color: const Color(0xFF0a0a0a),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Connecting to stream...',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Check if stream is live
                  if (!callState.isBackstage) {
                    return StreamVideoRenderer(
                      call: call,
                      participant: hostParticipant,
                      videoTrackType: SfuTrackType.video,
                    );
                  } else {
                    return Container(
                      color: const Color(0xFF0a0a0a),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pause_circle_outline,
                              size: 64,
                              color: Colors.white54,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Stream will start soon...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            // Top bar overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xCC000000),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _handleLeaveStream,
                    ),
                    const SizedBox(width: 8),
                    // Live badge
                    _buildLiveBadge(),
                    const SizedBox(width: 12),
                    // Stream title
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Viewer count
                    _buildViewerCount(call),
                  ],
                ),
              ),
            ),

            // Chat overlay
            if (_showChat)
              Positioned(
                left: 0,
                right: 0,
                bottom: 80,
                height: 280,
                child: ChatOverlay(callId: widget.callId),
              ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xCC000000),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Toggle chat
                    _buildControlButton(
                      icon: _showChat ? Icons.chat_bubble : Icons.chat_bubble_outline,
                      onPressed: () {
                        setState(() => _showChat = !_showChat);
                      },
                      tooltip: _showChat ? 'Hide chat' : 'Show chat',
                    ),
                    const SizedBox(width: 16),
                    // Leave stream button
                    _buildLeaveButton(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fiber_manual_record,
            size: 8,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            'LIVE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewerCount(Call call) {
    return StreamBuilder<CallState>(
      stream: call.state.asStream(),
      builder: (context, snapshot) {
        final participantCount = snapshot.data?.callParticipants.length ?? 0;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.visibility_outlined,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                '$participantCount',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleLeaveStream,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDC2626).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.call_end_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
