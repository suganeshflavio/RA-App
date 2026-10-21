import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

const _speedOptions = [1.0, 1.5, 2.0, 2.5, 3.0];

String _formatSpeed(double speed) {
  return speed == speed.roundToDouble() ? '${speed.toInt()}x' : '${speed}x';
}

String _formatDuration(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$seconds' : '${d.inMinutes}:$seconds';
}

class MediaVideoPlayer extends StatefulWidget {
  const MediaVideoPlayer({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<MediaVideoPlayer> createState() => _MediaVideoPlayerState();
}

class _MediaVideoPlayerState extends State<MediaVideoPlayer> {
  late final VideoPlayerController _controller;
  Timer? _autoHideTimer;
  bool _controlsVisible = true;
  bool _hasError = false;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..addListener(_onValueChanged)
      ..initialize()
          .then((_) {
            if (mounted) setState(() {});
          })
          .catchError((Object error, StackTrace stackTrace) {
            if (mounted) setState(() => _hasError = true);
          });
    _scheduleAutoHide();
  }

  void _onValueChanged() {
    if (mounted) setState(() {});
  }

  void _scheduleAutoHide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleAutoHide();
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
      _scheduleAutoHide();
    }
  }

  Future<void> _seekRelative(Duration delta) async {
    final value = _controller.value;
    if (!value.isInitialized) return;

    final duration = value.duration;
    final current = value.position;
    final targetMs = (current.inMilliseconds + delta.inMilliseconds).clamp(
      0,
      duration.inMilliseconds,
    );
    final target = Duration(milliseconds: targetMs);
    await _controller.seekTo(target);
    _scheduleAutoHide();
  }

  Future<void> _setSpeed(double speed) async {
    await _controller.setPlaybackSpeed(speed);
    if (mounted) setState(() => _speed = speed);
    _scheduleAutoHide();
  }

  Future<void> _openFullscreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullscreenVideoPage(
          controller: _controller,
          speed: _speed,
          onSpeedChanged: _setSpeed,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _controller.removeListener(_onValueChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black87,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Unable to play this video.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (!_controller.value.isInitialized) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: Colors.black87,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: _VideoSurface(
        controller: _controller,
        controlsVisible: _controlsVisible,
        onToggleControls: _toggleControls,
        onTogglePlay: _togglePlay,
        onSeekRelative: _seekRelative,
        speed: _speed,
        onSpeedChanged: _setSpeed,
        onFullscreenToggle: _openFullscreen,
        isFullscreen: false,
      ),
    );
  }
}

class _FullscreenVideoPage extends StatefulWidget {
  const _FullscreenVideoPage({
    required this.controller,
    required this.speed,
    required this.onSpeedChanged,
  });

  final VideoPlayerController controller;
  final double speed;
  final ValueChanged<double> onSpeedChanged;

  @override
  State<_FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<_FullscreenVideoPage> {
  Timer? _autoHideTimer;
  bool _controlsVisible = true;
  late double _speed = widget.speed;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    widget.controller.addListener(_onValueChanged);
    _scheduleAutoHide();
  }

  void _onValueChanged() {
    if (mounted) setState(() {});
  }

  void _scheduleAutoHide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleAutoHide();
  }

  void _togglePlay() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
      _scheduleAutoHide();
    }
  }

  Future<void> _seekRelative(Duration delta) async {
    final value = widget.controller.value;
    if (!value.isInitialized) return;

    final duration = value.duration;
    final current = value.position;
    final targetMs = (current.inMilliseconds + delta.inMilliseconds).clamp(
      0,
      duration.inMilliseconds,
    );
    final target = Duration(milliseconds: targetMs);
    await widget.controller.seekTo(target);
    _scheduleAutoHide();
  }

  Future<void> _setSpeed(double speed) async {
    await widget.controller.setPlaybackSpeed(speed);
    widget.onSpeedChanged(speed);
    if (mounted) setState(() => _speed = speed);
    _scheduleAutoHide();
  }

  Future<void> _exitFullscreen() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onValueChanged);
    _autoHideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _exitFullscreen();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio,
            child: _VideoSurface(
              controller: widget.controller,
              controlsVisible: _controlsVisible,
              onToggleControls: _toggleControls,
              onTogglePlay: _togglePlay,
              onSeekRelative: _seekRelative,
              speed: _speed,
              onSpeedChanged: _setSpeed,
              onFullscreenToggle: _exitFullscreen,
              isFullscreen: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoSurface extends StatefulWidget {
  const _VideoSurface({
    required this.controller,
    required this.controlsVisible,
    required this.onToggleControls,
    required this.onTogglePlay,
    required this.onSeekRelative,
    required this.speed,
    required this.onSpeedChanged,
    required this.onFullscreenToggle,
    required this.isFullscreen,
  });

  final VideoPlayerController controller;
  final bool controlsVisible;
  final VoidCallback onToggleControls;
  final VoidCallback onTogglePlay;
  final Future<void> Function(Duration delta) onSeekRelative;
  final double speed;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onFullscreenToggle;
  final bool isFullscreen;

  @override
  State<_VideoSurface> createState() => _VideoSurfaceState();
}

class _VideoSurfaceState extends State<_VideoSurface> {
  Timer? _seekIndicatorTimer;
  _SeekDirection? _seekDirection;

  @override
  void dispose() {
    _seekIndicatorTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleDoubleTap(_SeekDirection direction) async {
    _seekIndicatorTimer?.cancel();
    setState(() => _seekDirection = direction);

    await widget.onSeekRelative(
      direction == _SeekDirection.left
          ? const Duration(seconds: -10)
          : const Duration(seconds: 10),
    );

    _seekIndicatorTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _seekDirection = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;
    final position = value.position;
    final duration = value.duration;
    final sliderMax = duration.inMilliseconds > 0
        ? duration.inMilliseconds.toDouble()
        : 1.0;
    final sliderValue = position.inMilliseconds.toDouble().clamp(
      0.0,
      sliderMax,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onToggleControls,
      child: Stack(
        fit: StackFit.expand,
        children: [
          VideoPlayer(widget.controller),
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onDoubleTap: () => _handleDoubleTap(_SeekDirection.left),
                    child: const SizedBox.expand(),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onDoubleTap: () => _handleDoubleTap(_SeekDirection.right),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
          if (_seekDirection != null)
            Align(
              alignment: _seekDirection == _SeekDirection.left
                  ? const Alignment(-0.45, 0)
                  : const Alignment(0.45, 0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _seekDirection == _SeekDirection.left
                            ? Icons.replay_10_rounded
                            : Icons.forward_10_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _seekDirection == _SeekDirection.left ? '-10s' : '+10s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (widget.controlsVisible)
            Align(
              alignment: const Alignment(0, -0.25),
              child: IconButton(
                iconSize: 56,
                color: Colors.white,
                icon: Icon(
                  value.isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                ),
                onPressed: widget.onTogglePlay,
              ),
            ),
          if (widget.controlsVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 6,
                  bottom: 4,
                  top: 14,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _formatDuration(position),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 10,
                          ),
                          activeTrackColor: const Color(0xFFF97316),
                          thumbColor: const Color(0xFFF97316),
                          inactiveTrackColor: Colors.white30,
                        ),
                        child: Slider(
                          min: 0,
                          max: sliderMax,
                          value: sliderValue,
                          onChanged: (v) => widget.controller.seekTo(
                            Duration(milliseconds: v.round()),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    PopupMenuButton<double>(
                      initialValue: widget.speed,
                      onSelected: widget.onSpeedChanged,
                      color: const Color(0xFF2A180E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => _speedOptions
                          .map(
                            (s) => PopupMenuItem<double>(
                              value: s,
                              child: Text(
                                _formatSpeed(s),
                                style: TextStyle(
                                  color: s == widget.speed
                                      ? const Color(0xFFF97316)
                                      : Colors.white,
                                  fontWeight: s == widget.speed
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.speed_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _formatSpeed(widget.speed),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      color: Colors.white,
                      iconSize: 20,
                      icon: Icon(
                        widget.isFullscreen
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                      ),
                      onPressed: widget.onFullscreenToggle,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _SeekDirection { left, right }
