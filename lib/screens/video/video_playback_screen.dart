import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/stream_model.dart';
import '../../core/constants/app_constants.dart';

class VideoPlaybackScreen extends StatefulWidget {
  final StreamModel stream;

  const VideoPlaybackScreen({super.key, required this.stream});

  @override
  State<VideoPlaybackScreen> createState() => _VideoPlaybackScreenState();
}

class _VideoPlaybackScreenState extends State<VideoPlaybackScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isPlaying = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isDragging = false;

  // Seek animation
  String? _seekDirection; // 'left' or 'right'
  Timer? _seekAnimationTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    final videoUrl = widget.stream.getRecordingUrl(AppConstants.apiBaseUrl);
    
    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _totalDuration = _controller.value.duration;
          });
          
          // Autoplay
          _controller.play();
          setState(() {
            _isPlaying = true;
          });
          _startHideControlsTimer();
        }
      }).catchError((error) {
        debugPrint('Error initializing video player: $error');
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });

    // Listen to player state changes
    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (!mounted) return;
    
    // Don't update position from listener while dragging seekbar
    if (!_isDragging) {
      final newPosition = _controller.value.position;
      final isCurrentlyPlaying = _controller.value.isPlaying;
      
      // Only setState if values actually changed (with threshold for position)
      final positionChanged = (newPosition.inMilliseconds - _currentPosition.inMilliseconds).abs() > 50;
      final playStateChanged = isCurrentlyPlaying != _isPlaying;
      
      if (positionChanged || playStateChanged) {
        setState(() {
          _currentPosition = newPosition;
          _isPlaying = isCurrentlyPlaying;
        });
      }
    }

    // Check if video ended (with small buffer)
    final duration = _controller.value.duration;
    final position = _controller.value.position;
    if (duration.inMilliseconds > 0 && 
        position.inMilliseconds >= duration.inMilliseconds - 500) {
      if (_isPlaying || !_showControls) {
        setState(() {
          _isPlaying = false;
          _showControls = true;
        });
        _hideControlsTimer?.cancel();
      }
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (_isPlaying && mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _controller.pause();
      _hideControlsTimer?.cancel();
    } else {
      _controller.play();
      _startHideControlsTimer();
    }
    setState(() {
      _showControls = true;
      _isPlaying = !_isPlaying;
    });
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    if (_isPlaying) {
      _startHideControlsTimer();
    }
  }

  void _seekBackward() {
    final newPosition = _currentPosition - const Duration(seconds: 10);
    _controller.seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
    
    setState(() {
      _seekDirection = 'left';
    });
    
    _seekAnimationTimer?.cancel();
    _seekAnimationTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _seekDirection = null;
        });
      }
    });
  }

  void _seekForward() {
    final newPosition = _currentPosition + const Duration(seconds: 10);
    _controller.seekTo(newPosition > _totalDuration ? _totalDuration : newPosition);
    
    setState(() {
      _seekDirection = 'right';
    });
    
    _seekAnimationTimer?.cancel();
    _seekAnimationTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _seekDirection = null;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${twoDigits(seconds)}';
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _seekAnimationTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _hasError
            ? _buildErrorState()
            : !_isInitialized
                ? _buildLoadingState()
                : _buildVideoPlayer(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Failed to load video',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.cyan),
          SizedBox(height: 16),
          Text(
            'Loading video...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
      children: [
        // Video player
        Center(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),

        // Tap areas for seek and play/pause - Must fill entire screen
        Positioned.fill(
          child: Row(
            children: [
              // Left tap area (seek backward)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _showControlsTemporarily,
                  onDoubleTap: _seekBackward,
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: _seekDirection == 'left'
                        ? Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.fast_rewind, color: Colors.white, size: 32),
                                SizedBox(height: 4),
                                Text(
                                  '10',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
              
              // Center tap area (play/pause)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _togglePlayPause,
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _showControls && !_isPlaying ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Right tap area (seek forward)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _showControlsTemporarily,
                  onDoubleTap: _seekForward,
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: _seekDirection == 'right'
                        ? Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.fast_forward, color: Colors.white, size: 32),
                                SizedBox(height: 4),
                                Text(
                                  '10',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Top control bar (back button, title)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          top: _showControls ? 0 : -100,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.stream.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom control bar (time, seekbar)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          bottom: _showControls ? 0 : -100,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Seekbar
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: const Color(0xFF00BCD4),
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                    thumbColor: const Color(0xFF00BCD4),
                    overlayColor: const Color(0xFF00BCD4).withOpacity(0.3),
                  ),
                  child: Slider(
                    value: _currentPosition.inMilliseconds.toDouble().clamp(
                      0.0,
                      _totalDuration.inMilliseconds > 0 
                          ? _totalDuration.inMilliseconds.toDouble()
                          : 1.0,
                    ),
                    min: 0.0,
                    max: _totalDuration.inMilliseconds > 0 
                        ? _totalDuration.inMilliseconds.toDouble()
                        : 1.0,
                    onChangeStart: (value) {
                      setState(() {
                        _isDragging = true;
                      });
                      _hideControlsTimer?.cancel();
                    },
                    onChanged: (value) {
                      setState(() {
                        _currentPosition = Duration(milliseconds: value.toInt());
                      });
                    },
                    onChangeEnd: (value) {
                      setState(() {
                        _isDragging = false;
                      });
                      _controller.seekTo(Duration(milliseconds: value.toInt()));
                      if (_isPlaying) {
                        _startHideControlsTimer();
                      }
                    },
                  ),
                ),
                // Time display
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right side action buttons
        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            children: [
              _buildActionButton(
                icon: Icons.thumb_up_outlined,
                label: '0',
                onTap: () {
                  // TODO: Implement like functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Like feature coming soon')),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.comment_outlined,
                label: '0',
                onTap: () {
                  // TODO: Implement comment functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comments feature coming soon')),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: () {
                  // TODO: Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon')),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.bookmark_border,
                label: 'Save',
                onTap: () {
                  // TODO: Implement save functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Save feature coming soon')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
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
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
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
