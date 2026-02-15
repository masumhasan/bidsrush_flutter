import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import '../../providers/video_stream_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/chat/chat_overlay.dart';

/// Broadcast Screen with Stream SDK-style video controls
/// Mobile-first 9:16 aspect ratio layout
class BroadcastScreen extends StatefulWidget {
  final String callId;
  final String title;

  const BroadcastScreen({super.key, required this.callId, required this.title});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final token = await AuthService().getToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  Future<void> _handleEndStream() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.videocam_off_rounded,
                  color: Color(0xFFDC2626),
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'End Stream?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1a1a1a),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your viewers will be disconnected',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFE5E5E5)),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'End Stream',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      final streamProvider = context.read<VideoStreamProvider>();
      final chatProvider = context.read<ChatProvider>();
      await streamProvider.endStream();
      await chatProvider.leaveChat();
      await _apiService.endStream(widget.callId);

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalMargin = screenWidth * 0.05;
    final verticalMargin = screenHeight * 0.05;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalMargin,
            vertical: verticalMargin,
          ),
          child: Stack(
            children: [
              // Video container - Stream SDK Video Renderer
              Consumer<VideoStreamProvider>(
                builder: (context, streamProvider, _) {
                  final call = streamProvider.activeCall;
                  
                  if (call == null) {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color(0xFF0a0a0a),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }

                  return StreamBuilder<CallState>(
                    stream: call.state.asStream(),
                    builder: (context, snapshot) {
                      final callState = snapshot.data ?? call.state.value;
                      final localParticipant = callState.localParticipant;
                      
                      if (localParticipant == null) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: const Color(0xFF0a0a0a),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  'Connecting...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Render local participant video
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: const Color(0xFF0a0a0a),
                        child: StreamVideoRenderer(
                          call: call,
                          participant: localParticipant,
                          videoTrackType: SfuTrackType.video,
                        ),
                      );
                    },
                  );
                },
              ),

              // Top bar overlay with gradient
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
                    // Viewer count - dynamic from call state
                    Consumer<VideoStreamProvider>(
                      builder: (context, streamProvider, _) {
                        final call = streamProvider.activeCall;
                        if (call == null) {
                          return _buildViewerCountBadge(0);
                        }
                        return StreamBuilder<CallState>(
                          stream: call.state.asStream(),
                          builder: (context, snapshot) {
                            final participantCount = 
                                snapshot.data?.callParticipants.length ?? 0;
                            // Subtract 1 for the host
                            final viewerCount = participantCount > 0 
                                ? participantCount - 1 
                                : 0;
                            return _buildViewerCountBadge(viewerCount);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              ),

              // Chat overlay (above controls)
              Positioned(
                left: 0,
                right: 0,
                bottom: 100,
                height: 280,
                child: ChatOverlay(callId: widget.callId),
              ),

              // Stream SDK-style Bottom Control Bar
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
                  child: Consumer<VideoStreamProvider>(
                    builder: (context, stream, _) {
                      return _buildStreamControls(stream);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildViewerCountBadge(int count) {
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
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Stream SDK-style control buttons in a pill-shaped container
  Widget _buildStreamControls(VideoStreamProvider stream) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Flip camera
          _StreamControlButton(
            icon: Icons.flip_camera_ios_rounded,
            onPressed: () => stream.flipCamera(),
            tooltip: 'Flip camera',
          ),
          // Toggle microphone
          _StreamControlButton(
            icon: stream.isMicEnabled
                ? Icons.mic_rounded
                : Icons.mic_off_rounded,
            onPressed: () => stream.toggleMicrophone(),
            isActive: stream.isMicEnabled,
            activeColor: Colors.white,
            inactiveColor: const Color(0xFFFF6B6B),
            tooltip: stream.isMicEnabled ? 'Mute' : 'Unmute',
          ),
          // End stream button (red, larger)
          _StreamEndCallButton(
            onPressed: _handleEndStream,
          ),
          // Toggle camera
          _StreamControlButton(
            icon: stream.isCameraEnabled
                ? Icons.videocam_rounded
                : Icons.videocam_off_rounded,
            onPressed: () => stream.toggleCamera(),
            isActive: stream.isCameraEnabled,
            activeColor: Colors.white,
            inactiveColor: const Color(0xFFFF6B6B),
            tooltip: stream.isCameraEnabled ? 'Camera off' : 'Camera on',
          ),
          // More options
          _StreamControlButton(
            icon: Icons.more_horiz_rounded,
            onPressed: () => _showMoreOptions(),
            tooltip: 'More',
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionItem(
              icon: Icons.share_outlined,
              label: 'Share Stream',
              onTap: () => Navigator.pop(context),
            ),
            _buildOptionItem(
              icon: Icons.shopping_bag_outlined,
              label: 'Manage Products',
              onTap: () => Navigator.pop(context),
            ),
            _buildOptionItem(
              icon: Icons.settings_outlined,
              label: 'Stream Settings',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1a1a1a)),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1a1a1a),
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

/// Stream SDK-style circular control button
class _StreamControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final String tooltip;

  const _StreamControlButton({
    required this.icon,
    required this.onPressed,
    this.isActive = true,
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.white,
    this.tooltip = '',
  });

  @override
  Widget build(BuildContext context) {
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
              color: isActive
                  ? Colors.white.withOpacity(0.1)
                  : const Color(0xFF2a2a2a),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

/// Stream SDK-style red end call button
class _StreamEndCallButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StreamEndCallButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
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
