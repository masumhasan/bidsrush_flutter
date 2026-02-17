import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String title;
  final bool autoPlay;
  final VoidCallback? onBack;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.title,
    this.autoPlay = true,
    this.onBack,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isPlaying = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  Timer? _progressTimer;
  
  double _currentPosition = 0.0;
  double _totalDuration = 1.0;
  bool _isDragging = false;
  
  // Store position before pause (workaround for video_player_web bug)
  double _positionBeforePause = 0.0;

  // Seek animation
  String? _seekDirection;
  Timer? _seekAnimationTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      
      await _controller.initialize();
      
      if (!mounted) return;
      
      // Wait additional time for metadata to fully load (especially on web)
      await Future.delayed(const Duration(milliseconds: 200));
      
      if (!mounted) return;
      
      final durationMs = _controller.value.duration.inMilliseconds.toDouble();
      debugPrint('Video initialized - Duration: ${durationMs}ms (${_formatDuration(durationMs)})');
      
      setState(() {
        _isInitialized = true;
        _totalDuration = durationMs > 0 ? durationMs : 1.0;
        debugPrint('Duration set to: $_totalDuration ms');
      });

      // Set up listener for play state changes
      _controller.addListener(_onControllerUpdate);

      // Start progress timer
      _startProgressTimer();

      // Auto-play if enabled
      if (widget.autoPlay) {
        await _controller.play();
        _startHideControlsTimer();
      }
    } catch (error) {
      debugPrint('Error initializing video: $error');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _onControllerUpdate() {
    if (!mounted || !_controller.value.isInitialized) return;

    final isPlaying = _controller.value.isPlaying;
    if (isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || !_controller.value.isInitialized || _isDragging) return;

      final position = _controller.value.position.inMilliseconds.toDouble().clamp(0.0, double.infinity);
      final durationMs = _controller.value.duration.inMilliseconds.toDouble();
      final duration = durationMs > 0 ? durationMs : _totalDuration;
      
      // Always update duration if it changed (remove threshold to catch late metadata loading)
      bool shouldUpdate = false;
      
      if ((duration - _totalDuration).abs() > 1.0) {
        debugPrint('Duration changed from $_totalDuration to $duration ms');
        shouldUpdate = true;
      }
      
      if ((position - _currentPosition).abs() > 50) {
        shouldUpdate = true;
      }
      
      if (shouldUpdate) {
        setState(() {
          _currentPosition = position.clamp(0.0, duration > 1.0 ? duration : _totalDuration);
          if (duration > 1.0) {
            _totalDuration = duration;
          }
        });
        
        // Continuously save valid position for pause/resume workaround
        if (_isPlaying && position > 0) {
          _positionBeforePause = position;
        }
      }

      // Check if video ended
      if (_currentPosition >= _totalDuration * 0.99 && _totalDuration > 1.0) {
        if (_isPlaying) {
          setState(() {
            _isPlaying = false;
            _showControls = true;
          });
          _hideControlsTimer?.cancel();
        }
      }
    });
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

  Future<void> _togglePlayPause() async {
    if (!_controller.value.isInitialized) return;

    try {
      if (_isPlaying) {
        // Save current position before pausing
        final currentMs = _controller.value.position.inMilliseconds.toDouble();
        _positionBeforePause = currentMs > 0 ? currentMs : _currentPosition;
        
        debugPrint('Pausing at position: $_positionBeforePause ms');
        await _controller.pause();
        
        _hideControlsTimer?.cancel();
        setState(() {
          _showControls = true;
        });
      } else {
        // Resume playback
        debugPrint('Resuming from position: $_positionBeforePause ms (current UI: $_currentPosition ms)');
        
        // Don't seek on web to avoid negative position bug - just play from wherever it is
        if (!kIsWeb && _positionBeforePause > 0) {
          // On native platforms, we can safely seek before playing
          await _controller.seekTo(Duration(milliseconds: _positionBeforePause.toInt()));
          await Future.delayed(const Duration(milliseconds: 50));
        }
        
        await _controller.play();
        
        setState(() {
          _showControls = true;
        });
        _startHideControlsTimer();
      }
    } catch (error) {
      debugPrint('Error toggling play/pause: $error');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kIsWeb 
              ? 'Web video has known issues. For best experience, use Android/iOS app.'
              : 'Playback error occurred'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  Future<void> _recreateController() async {
    try {
      final savedPosition = _positionBeforePause > 0 ? _positionBeforePause : _currentPosition;
      
      // Dispose old controller
      _progressTimer?.cancel();
      _controller.removeListener(_onControllerUpdate);
      await _controller.dispose();
      
      // Create new controller
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller.initialize();
      
      if (!mounted) return;
      
      _controller.addListener(_onControllerUpdate);
      _startProgressTimer();
      
      // Seek to saved position
      final targetMs = savedPosition.clamp(0.0, _totalDuration).toInt();
      await _controller.seekTo(Duration(milliseconds: targetMs));
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Play
      await _controller.play();
      
      setState(() {
        _currentPosition = savedPosition;
        _showControls = true;
      });
      
      _startHideControlsTimer();
      
      debugPrint('Controller recreated successfully at position: $targetMs ms');
    } catch (error) {
      debugPrint('Error recreating controller: $error');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
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
    if (!_controller.value.isInitialized) return;

    final currentPos = Duration(milliseconds: _currentPosition.toInt());
    final newPosition = currentPos - const Duration(seconds: 10);
    final targetPosition = newPosition < Duration.zero ? Duration.zero : newPosition;
    
    try {
      _controller.seekTo(targetPosition);
      
      setState(() {
        _seekDirection = 'left';
        _currentPosition = targetPosition.inMilliseconds.toDouble();
      });
    } catch (error) {
      debugPrint('Seek backward failed: $error');
    }
    
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
    if (!_controller.value.isInitialized) return;

    final currentPos = Duration(milliseconds: _currentPosition.toInt());
    final newPosition = currentPos + const Duration(seconds: 10);
    final totalDur = Duration(milliseconds: _totalDuration.toInt());
    final targetPosition = newPosition > totalDur ? totalDur : newPosition;
    
    try {
      _controller.seekTo(targetPosition);
      
      setState(() {
        _seekDirection = 'right';
        _currentPosition = targetPosition.inMilliseconds.toDouble();
      });
    } catch (error) {
      debugPrint('Seek forward failed: $error');
    }
    
    _seekAnimationTimer?.cancel();
    _seekAnimationTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _seekDirection = null;
        });
      }
    });
  }

  void _onSeekStart(double value) {
    setState(() {
      _isDragging = true;
    });
    _hideControlsTimer?.cancel();
  }

  void _onSeekChange(double value) {
    setState(() {
      _currentPosition = value.clamp(0.0, _totalDuration);
    });
  }

  void _onSeekEnd(double value) {
    final clampedValue = value.clamp(0.0, _totalDuration);
    
    try {
      _controller.seekTo(Duration(milliseconds: clampedValue.toInt()));
    } catch (error) {
      debugPrint('Seek failed: $error');
    }
    
    setState(() {
      _isDragging = false;
    });
    
    if (_isPlaying) {
      _startHideControlsTimer();
    }
  }

  String _formatDuration(double milliseconds) {
    final duration = Duration(milliseconds: milliseconds.toInt());
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _seekAnimationTimer?.cancel();
    _progressTimer?.cancel();
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorState();
    }

    if (!_isInitialized) {
      return _buildLoadingState();
    }

    return _buildPlayer();
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.black,
      child: Center(
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
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.black,
      child: const Center(
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
      ),
    );
  }

  Widget _buildPlayer() {
    return Stack(
      children: [
        // Video
        Center(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),

        // Tap zones
        Positioned.fill(
          child: Row(
            children: [
              // Left - seek back
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _showControlsTemporarily,
                  onDoubleTap: _seekBackward,
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: _seekDirection == 'left'
                          ? _buildSeekAnimation(Icons.fast_rewind)
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),

              // Center - play/pause
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _togglePlayPause,
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _showControls && !_isPlaying ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: _buildPlayButton(),
                      ),
                    ),
                  ),
                ),
              ),

              // Right - seek forward
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _showControlsTemporarily,
                  onDoubleTap: _seekForward,
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: _seekDirection == 'right'
                          ? _buildSeekAnimation(Icons.fast_forward)
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Top bar
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          top: _showControls ? 0 : -100,
          left: 0,
          right: 0,
          child: _buildTopBar(),
        ),

        // Bottom controls
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          bottom: _showControls ? 0 : -100,
          left: 0,
          right: 0,
          child: _buildBottomControls(),
        ),
      ],
    );
  }

  Widget _buildSeekAnimation(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 4),
          const Text(
            '10',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
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
    );
  }

  Widget _buildTopBar() {
    return Container(
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
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: widget.onBack,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: const Color(0xFF00BCD4),
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: const Color(0xFF00BCD4),
              overlayColor: const Color(0xFF00BCD4).withOpacity(0.3),
            ),
            child: Slider(
              value: _currentPosition.clamp(0.0, _totalDuration.clamp(1.0, double.infinity)),
              min: 0.0,
              max: _totalDuration.clamp(1.0, double.infinity),
              onChangeStart: _onSeekStart,
              onChanged: _onSeekChange,
              onChangeEnd: _onSeekEnd,
            ),
          ),
          const SizedBox(height: 4),
          // Time
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
