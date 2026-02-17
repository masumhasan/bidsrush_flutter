import 'package:flutter/material.dart';
import '../../models/stream_model.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/video_player_widget.dart';

class VideoPlaybackScreen extends StatelessWidget {
  final StreamModel stream;

  const VideoPlaybackScreen({super.key, required this.stream});

  @override
  Widget build(BuildContext context) {
    final videoUrl = stream.getRecordingUrl(AppConstants.apiBaseUrl);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video player
            VideoPlayerWidget(
              videoUrl: videoUrl,
              title: stream.title,
              autoPlay: true,
              onBack: () => Navigator.pop(context),
            ),

            // Action buttons
            Positioned(
              right: 12,
              bottom: 100,
              child: Column(
                children: [
                  _buildActionButton(
                    context,
                    icon: Icons.thumb_up_outlined,
                    label: '0',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Like feature coming soon')),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildActionButton(
                    context,
                    icon: Icons.comment_outlined,
                    label: '0',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Comments feature coming soon')),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildActionButton(
                    context,
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share feature coming soon')),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildActionButton(
                    context,
                    icon: Icons.bookmark_border,
                    label: 'Save',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Save feature coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
