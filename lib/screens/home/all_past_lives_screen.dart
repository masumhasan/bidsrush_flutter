import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/widgets/loading_widgets.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/stream_model.dart';
import '../../services/api_service.dart';
import '../video/video_playback_screen.dart';

class AllPastLivesScreen extends StatefulWidget {
  const AllPastLivesScreen({super.key});

  @override
  State<AllPastLivesScreen> createState() => _AllPastLivesScreenState();
}

class _AllPastLivesScreenState extends State<AllPastLivesScreen> {
  final ApiService _apiService = ApiService();
  List<StreamModel> _recordedStreams = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecordedStreams();
  }

  Future<void> _loadRecordedStreams() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final streams = await _apiService.getRecordedStreams();
      setState(() {
        _recordedStreams = streams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Live Streams'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecordedStreams,
        color: AppTheme.primaryBlue,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Loading past live streams...');
    }

    if (_error != null) {
      return EmptyState(
        message: 'Failed to load past live streams',
        icon: Icons.error_outline,
        action: CustomButton(text: 'Retry', onPressed: _loadRecordedStreams),
      );
    }

    if (_recordedStreams.isEmpty) {
      return const EmptyState(
        message: 'No past live streams found',
        icon: Icons.history,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _recordedStreams.length,
      itemBuilder: (context, index) {
        return _PastLiveStreamCard(stream: _recordedStreams[index]);
      },
    );
  }
}

class _PastLiveStreamCard extends StatelessWidget {
  final StreamModel stream;

  const _PastLiveStreamCard({required this.stream});

  @override
  Widget build(BuildContext context) {
    final hasRecording = stream.hasRecording;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (!hasRecording) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recording not available'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }

          // Navigate to full-screen video player
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VideoPlaybackScreen(stream: stream),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: hasRecording ? null : AppTheme.cardGradient,
                  color: hasRecording ? Colors.black : null,
                ),
                child: Stack(
                  children: [
                    if (!hasRecording)
                      Center(
                        child: Icon(
                          Icons.videocam_off,
                          size: 48,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      )
                    else
                      Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 48,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    // Duration badge
                    if (hasRecording && stream.recording != null)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            stream.recording!.formattedDuration,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    // Recorded badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[800]!.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'RECORDED',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stream.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasRecording
                        ? "Women's Category"
                        : 'Recording not available',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (stream.recording != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Saved ${_formatDate(stream.recording!.recordedAt)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }
}
