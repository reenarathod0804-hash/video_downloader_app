import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:video_dloader/configue/constant/AppColors.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final String? title;

  const VideoPlayerScreen({
    Key? key,
    required this.videoPath,
    this.title,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Controls UI state
  bool _showControls = true;
  Timer? _hideTimer;
  bool _isLocked = false;
  bool _isFullscreen = false;
  BoxFit _videoFit = BoxFit.contain;
  double _playbackSpeed = 1.0;
  bool _isLooping = false;
  bool _isDragging = false;
  double _dragValue = 0.0;
  bool _isMuted = false;
  double _volumeBeforeMute = 1.0;

  // Double-tap ripple indicators
  bool _showLeftRipple = false;
  bool _showRightRipple = false;
  Timer? _leftRippleTimer;
  Timer? _rightRippleTimer;

  // Gesture adjustments (Volume & Brightness simulation)
  double _volume = 1.0;
  bool _showVolumeIndicator = false;
  Timer? _volumeIndicatorTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final file = File(widget.videoPath);
    if (!await file.exists()) {
      setState(() {
        _hasError = true;
        _errorMessage = 'File not found on device.';
      });
      return;
    }

    try {
      _controller = VideoPlayerController.file(file);
      await _controller.initialize();

      _controller.addListener(_videoPlayerListener);

      setState(() {
        _isInitialized = true;
      });

      await _controller.play();
      _startHideControlsTimer();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load video: $e';
      });
    }
  }

  void _videoPlayerListener() {
    if (!mounted) return;
    if (_controller.value.hasError) {
      setState(() {
        _hasError = true;
        _errorMessage = _controller.value.errorDescription ?? 'Unknown playback error.';
      });
    } else {
      setState(() {});
    }
  }

  void _toggleControls() {
    if (_isLocked) {
      setState(() {
        _showControls = !_showControls;
      });
      if (_showControls) {
        _startHideControlsTimer();
      }
      return;
    }

    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls && _controller.value.isPlaying) {
      _startHideControlsTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _startHideControlsTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _controller.value.isPlaying && !_isDragging) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _resetHideTimer() {
    if (_showControls && _controller.value.isPlaying) {
      _startHideControlsTimer();
    }
  }

  // Quick Seek Forward / Backward (YouTube style 10s)
  void _seekRelative(int seconds) {
    if (!_isInitialized) return;
    final currentPos = _controller.value.position;
    final totalDuration = _controller.value.duration;
    final targetPos = currentPos + Duration(seconds: seconds);

    if (targetPos < Duration.zero) {
      _controller.seekTo(Duration.zero);
    } else if (targetPos > totalDuration) {
      _controller.seekTo(totalDuration);
    } else {
      _controller.seekTo(targetPos);
    }
    _resetHideTimer();
  }

  // Double-tap left: Rewind 10s
  void _onDoubleTapLeft() {
    if (_isLocked) return;
    _seekRelative(-10);
    setState(() {
      _showLeftRipple = true;
    });
    _leftRippleTimer?.cancel();
    _leftRippleTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showLeftRipple = false);
    });
  }

  // Double-tap right: Fast Forward 10s
  void _onDoubleTapRight() {
    if (_isLocked) return;
    _seekRelative(10);
    setState(() {
      _showRightRipple = true;
    });
    _rightRippleTimer?.cancel();
    _rightRippleTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showRightRipple = false);
    });
  }

  // Toggle Fullscreen & Screen Orientation
  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _resetHideTimer();
  }

  // Format Duration helper
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  // Mute toggle
  void _toggleMute() {
    if (_isMuted) {
      _controller.setVolume(_volumeBeforeMute);
      setState(() {
        _isMuted = false;
        _volume = _volumeBeforeMute;
      });
    } else {
      _volumeBeforeMute = _volume;
      _controller.setVolume(0.0);
      setState(() {
        _isMuted = true;
        _volume = 0.0;
      });
    }
    _resetHideTimer();
  }

  // Playback speed picker modal (YouTube Style)
  void _showSettingsModal() {
    _hideTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F1F),
      barrierColor: Colors.black.withOpacity(0.6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Playback Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Niramit Bold',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white12, height: 1),

                    // Playback Speed option
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.speed_rounded, color: Colors.white70),
                      title: const Text('Playback speed', style: TextStyle(color: Colors.white, fontSize: 15)),
                      trailing: Text(
                        _playbackSpeed == 1.0 ? 'Normal' : '${_playbackSpeed}x',
                        style: const TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showSpeedPicker();
                      },
                    ),

                    // Fit Aspect Ratio option
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.aspect_ratio_rounded, color: Colors.white70),
                      title: const Text('Video Fit Mode', style: TextStyle(color: Colors.white, fontSize: 15)),
                      trailing: Text(
                        _videoFit == BoxFit.contain
                            ? 'Fit (Default)'
                            : _videoFit == BoxFit.cover
                                ? 'Zoom to Fill'
                                : 'Stretch',
                        style: const TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                      onTap: () {
                        setState(() {
                          if (_videoFit == BoxFit.contain) {
                            _videoFit = BoxFit.cover;
                          } else if (_videoFit == BoxFit.cover) {
                            _videoFit = BoxFit.fill;
                          } else {
                            _videoFit = BoxFit.contain;
                          }
                        });
                        setModalState(() {});
                      },
                    ),

                    // Loop option
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.loop_rounded, color: Colors.white70),
                      title: const Text('Loop video', style: TextStyle(color: Colors.white, fontSize: 15)),
                      trailing: Switch(
                        value: _isLooping,
                        activeColor: const Color(0xFFFF0000),
                        onChanged: (val) {
                          setState(() {
                            _isLooping = val;
                            _controller.setLooping(_isLooping);
                          });
                          setModalState(() {});
                        },
                      ),
                    ),

                    // File info summary
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.info_outline_rounded, color: Colors.white70),
                      title: const Text('Video Details', style: TextStyle(color: Colors.white, fontSize: 15)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white60),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showVideoDetailsDialog();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => _resetHideTimer());
  }

  // Playback speed selection dialog
  void _showSpeedPicker() {
    final speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Playback speed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Niramit Bold',
                ),
              ),
              const SizedBox(height: 8),
              ...speeds.map((speed) {
                final isSelected = _playbackSpeed == speed;
                return ListTile(
                  title: Text(
                    speed == 1.0 ? 'Normal' : '${speed}x',
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFFF0000) : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFFF0000)) : null,
                  onTap: () {
                    setState(() {
                      _playbackSpeed = speed;
                      _controller.setPlaybackSpeed(speed);
                    });
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    ).then((_) => _resetHideTimer());
  }

  // Video details modal
  void _showVideoDetailsDialog() {
    final file = File(widget.videoPath);
    final sizeInMb = file.existsSync() ? (file.lengthSync() / (1024 * 1024)).toStringAsFixed(1) : '--';
    final resolution = _isInitialized
        ? '${_controller.value.size.width.toInt()} x ${_controller.value.size.height.toInt()}'
        : '--';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Video Information', style: TextStyle(color: Colors.white, fontFamily: 'Niramit Bold')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('File Name', widget.videoPath.split('/').last),
            const SizedBox(height: 8),
            _detailRow('Resolution', resolution),
            const SizedBox(height: 8),
            _detailRow('Duration', _isInitialized ? _formatDuration(_controller.value.duration) : '--'),
            const SizedBox(height: 8),
            _detailRow('Size', '$sizeInMb MB'),
            const SizedBox(height: 8),
            _detailRow('Path', widget.videoPath),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Color(0xFFFF0000))),
          )
        ],
      ),
    ).then((_) => _resetHideTimer());
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  // Volume slider gesture adjustment
  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isLocked) return;
    // Right side volume adjustment
    final delta = -details.primaryDelta! / 200.0;
    final newVol = (_volume + delta).clamp(0.0, 1.0);
    setState(() {
      _volume = newVol;
      _isMuted = newVol == 0.0;
      _showVolumeIndicator = true;
    });
    _controller.setVolume(newVol);

    _volumeIndicatorTimer?.cancel();
    _volumeIndicatorTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showVolumeIndicator = false);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _leftRippleTimer?.cancel();
    _rightRippleTimer?.cancel();
    _volumeIndicatorTimer?.cancel();
    _controller.removeListener(_videoPlayerListener);
    _controller.dispose();

    // Restore orientation and system overlays
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.title ?? widget.videoPath.split('/').last.replaceAll('.mp4', '');

    return PopScope(
      canPop: !_isFullscreen,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isFullscreen) {
          _toggleFullscreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          top: !_isFullscreen,
          bottom: !_isFullscreen,
          child: Center(
            child: _hasError
                ? _buildErrorView()
                : !_isInitialized
                    ? _buildLoadingView()
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. VIDEO LAYER
                          SizedBox.expand(
                            child: FittedBox(
                              fit: _videoFit,
                              child: SizedBox(
                                width: _controller.value.size.width > 0 ? _controller.value.size.width : 16,
                                height: _controller.value.size.height > 0 ? _controller.value.size.height : 9,
                                child: VideoPlayer(_controller),
                              ),
                            ),
                          ),

                          // 2. GESTURE DETECTOR LAYER (Double Tap Seeking & Tap)
                          Positioned.fill(
                            child: Row(
                              children: [
                                // Left Double Tap Area (Rewind 10s)
                                Expanded(
                                  flex: 4,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _toggleControls,
                                    onDoubleTap: _onDoubleTapLeft,
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),
                                // Center Area (Toggle Controls)
                                Expanded(
                                  flex: 3,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _toggleControls,
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),
                                // Right Double Tap Area (Forward 10s) + Volume Drag
                                Expanded(
                                  flex: 4,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _toggleControls,
                                    onDoubleTap: _onDoubleTapRight,
                                    onVerticalDragUpdate: _onVerticalDragUpdate,
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 3. DOUBLE-TAP RIPPLE ANIMATION (LEFT & RIGHT)
                          if (_showLeftRipple) _buildRippleFeedback(isLeft: true),
                          if (_showRightRipple) _buildRippleFeedback(isLeft: false),

                          // 4. FLOATING VOLUME INDICATOR (SWIPE GESTURE)
                          if (_showVolumeIndicator) _buildVolumeOverlay(),

                          // 5. LOCKED MODE OVERLAY BUTTON
                          if (_isLocked && _showControls)
                            Positioned(
                              top: 24,
                              left: 20,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _isLocked = false);
                                  _resetHideTimer();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white30),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.lock_open_rounded, color: Colors.white, size: 18),
                                      SizedBox(width: 6),
                                      Text('Tap to Unlock', style: TextStyle(color: Colors.white, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // 6. FULL CONTROLS OVERLAY (TOP, CENTER, BOTTOM)
                          if (!_isLocked)
                            AnimatedOpacity(
                              opacity: _showControls ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              child: IgnorePointer(
                                ignoring: !_showControls,
                                child: Stack(
                                  children: [
                                    // Gradient Backdrops
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      height: 90,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.8),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      height: 110,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.85),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Top Bar
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      right: 10,
                                      child: _buildTopBar(fileName),
                                    ),

                                    // Center Playback Buttons
                                    Center(
                                      child: _buildCenterControls(),
                                    ),

                                    // Bottom Bar with Progress Bar & Options
                                    Positioned(
                                      bottom: 12,
                                      left: 16,
                                      right: 16,
                                      child: _buildBottomBar(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }

  // Top Bar: Back, Title, Lock, Share, Settings
  Widget _buildTopBar(String title) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
          onPressed: () {
            if (_isFullscreen) {
              _toggleFullscreen();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Niramit Bold',
              fontWeight: FontWeight.w600,
              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 22),
          tooltip: 'Lock Screen',
          onPressed: () {
            setState(() => _isLocked = true);
            _startHideControlsTimer();
          },
        ),
        IconButton(
          icon: const Icon(Icons.share_rounded, color: Colors.white, size: 22),
          tooltip: 'Share Video',
          onPressed: () {
            Share.shareXFiles([XFile(widget.videoPath)], text: widget.videoPath.split('/').last);
            _resetHideTimer();
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
          tooltip: 'Settings',
          onPressed: _showSettingsModal,
        ),
      ],
    );
  }

  // Center Playback Controls: Replay 10s, Play/Pause, Forward 10s
  Widget _buildCenterControls() {
    final isFinished = _controller.value.position >= _controller.value.duration && _controller.value.duration > Duration.zero;
    final isPlaying = _controller.value.isPlaying;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Rewind 10s Button
        IconButton(
          iconSize: 42,
          icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
          onPressed: () => _seekRelative(-10),
        ),
        const SizedBox(width: 28),

        // Main Play / Pause / Replay Button
        GestureDetector(
          onTap: () {
            if (isFinished) {
              _controller.seekTo(Duration.zero);
              _controller.play();
            } else if (isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
            _resetHideTimer();
          },
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.55),
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Center(
              child: Icon(
                isFinished
                    ? Icons.replay_rounded
                    : (isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
        const SizedBox(width: 28),

        // Forward 10s Button
        IconButton(
          iconSize: 42,
          icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
          onPressed: () => _seekRelative(10),
        ),
      ],
    );
  }

  // Bottom Bar: Time Stamps, YouTube Scrubber, Mute, Fit, Fullscreen
  Widget _buildBottomBar() {
    final currentPos = _isDragging
        ? Duration(milliseconds: (_dragValue * _controller.value.duration.inMilliseconds).toInt())
        : _controller.value.position;
    final totalDuration = _controller.value.duration;
    final progress = totalDuration.inMilliseconds > 0
        ? (currentPos.inMilliseconds / totalDuration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // YouTube Style Progress Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3.5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5, elevation: 3),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: const Color(0xFFFF0000),
            inactiveTrackColor: Colors.white24,
            thumbColor: const Color(0xFFFF0000),
            overlayColor: const Color(0xFFFF0000).withOpacity(0.2),
          ),
          child: Slider(
            value: progress,
            onChanged: (val) {
              setState(() {
                _isDragging = true;
                _dragValue = val;
              });
              _hideTimer?.cancel();
            },
            onChangeEnd: (val) {
              final targetMs = (val * totalDuration.inMilliseconds).toInt();
              _controller.seekTo(Duration(milliseconds: targetMs));
              setState(() {
                _isDragging = false;
              });
              _resetHideTimer();
            },
          ),
        ),

        // Timestamps and Action Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              // Current / Total Time
              Text(
                '${_formatDuration(currentPos)} / ${_formatDuration(totalDuration)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'Niramit Bold',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),

              // Quick Mute Button
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _isMuted || _volume == 0
                      ? Icons.volume_off_rounded
                      : _volume < 0.5
                          ? Icons.volume_down_rounded
                          : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _toggleMute,
              ),
              const SizedBox(width: 14),

              // Fullscreen Toggle Button
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: _toggleFullscreen,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // YouTube-style Double Tap Ripple UI (10s seek animation)
  Widget _buildRippleFeedback({required bool isLeft}) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      width: MediaQuery.of(context).size.width * 0.45,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? Radius.zero : const Radius.circular(100),
            right: isLeft ? const Radius.circular(100) : Radius.zero,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLeft ? Icons.fast_rewind_rounded : Icons.fast_forward_rounded,
                color: Colors.white,
                size: 38,
              ),
              const SizedBox(height: 6),
              Text(
                isLeft ? '10 seconds' : '10 seconds',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Floating Gesture Volume Overlay (YouTube Style)
  Widget _buildVolumeOverlay() {
    return Positioned(
      top: 30,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              height: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _volume,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF0000)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(_volume * 100).toInt()}%',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Loading View
  Widget _buildLoadingView() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: Color(0xFFFF0000),
          strokeWidth: 3,
        ),
        SizedBox(height: 16),
        Text(
          'Loading Video...',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  // Error View
  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFFF0000), size: 54),
          const SizedBox(height: 14),
          const Text(
            'Unable to Play Video',
            style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Niramit Bold'),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF0000),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              setState(() {
                _hasError = false;
                _isInitialized = false;
              });
              _initializePlayer();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

