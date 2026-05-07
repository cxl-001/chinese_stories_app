import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../models/story.dart';
import '../providers/app_provider.dart';
import '../services/audio_service.dart';

class StoryPlayerScreen extends StatefulWidget {
  final Story story;

  const StoryPlayerScreen({super.key, required this.story});

  @override
  State<StoryPlayerScreen> createState() => _StoryPlayerScreenState();
}

class _StoryPlayerScreenState extends State<StoryPlayerScreen> {
  final AudioService _audio = AudioService();
  final TtsService _tts = TtsService();
  final ScrollController _scrollCtrl = ScrollController();

  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasGreeted = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _initPlayback();
  }

  Future<void> _initPlayback() async {
    await _audio.init();
    await widget.story.loadContent();
    await _tts.init();

    _audio.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _isPlaying = false;
          }
        });
      }
    });

    _audio.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });

    _audio.durationStream.listen((dur) {
      if (mounted && dur != null) setState(() {
        _duration = dur;
        _isLoading = false;
      });
    });

    if (!_hasGreeted) {
      _hasGreeted = true;
      final provider = context.read<AppProvider>();
      await _tts.speakGreeting(provider.childName, widget.story.title);
      await Future.delayed(const Duration(seconds: 3));
    }

    try {
      await _audio.playAsset('audio/${widget.story.audioFile}');
      setState(() { _isPlaying = true; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('音频加载失败: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _audio.dispose();
    _tts.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes.toString().padLeft(2, '0');
    final sec = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  Color get _storyColor {
    try {
      return Color(int.parse(
          widget.story.coverColor.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_storyColor.withOpacity(0.15), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                                color: Color(0xFFFF9800)),
                            SizedBox(height: 16),
                            Text('正在加载故事...'),
                          ],
                        ),
                      )
                    : _buildContent(),
              ),
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.story.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.story.category} · ${widget.story.durationText}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
          Consumer<AppProvider>(
            builder: (ctx, provider, _) => IconButton(
              icon: Icon(
                provider.isFavorite(widget.story.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: provider.isFavorite(widget.story.id)
                    ? Colors.red
                    : Colors.grey,
              ),
              onPressed: () =>
                  provider.toggleFavorite(widget.story.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final content = widget.story.content ?? '';
    final progressPercent = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return SingleChildScrollView(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: progressPercent,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_storyColor),
            minHeight: 3,
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 18,
              height: 1.8,
              color: Color(0xFF444444),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.story.knowledgePoints != null &&
              widget.story.knowledgePoints!.isNotEmpty)
            _buildKnowledgePoints(),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildKnowledgePoints() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _storyColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _storyColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: _storyColor, size: 20),
              const SizedBox(width: 6),
              Text(
                '小知识',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _storyColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...widget.story.knowledgePoints!.map((kp) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('· ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(kp,
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF666666))),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(_formatDuration(_position),
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8),
                    activeTrackColor: _storyColor,
                    inactiveTrackColor: Colors.grey[200],
                    thumbColor: _storyColor,
                  ),
                  child: Slider(
                    value: _duration.inMilliseconds > 0
                        ? _position.inMilliseconds
                            .clamp(0, _duration.inMilliseconds)
                            .toDouble()
                        : 0,
                    max: _duration.inMilliseconds > 0
                        ? _duration.inMilliseconds.toDouble()
                        : 1,
                    onChanged: (v) {
                      final pos = Duration(milliseconds: v.toInt());
                      _audio.seek(pos);
                      setState(() => _position = pos);
                    },
                  ),
                ),
              ),
              Text(_formatDuration(_duration),
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _volume == 0 ? Icons.volume_off : Icons.volume_up,
                  color: Colors.grey,
                ),
                onPressed: () {
                  final newVol = _volume == 0 ? 1.0 : 0.0;
                  _audio.setVolume(newVol);
                  setState(() => _volume = newVol);
                },
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6),
                    activeTrackColor: _storyColor,
                    inactiveTrackColor: Colors.grey[200],
                    thumbColor: _storyColor,
                  ),
                  child: Slider(
                    value: _volume,
                    onChanged: (v) {
                      _audio.setVolume(v);
                      setState(() => _volume = v);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.replay_10_rounded),
                iconSize: 32,
                color: Colors.grey[600],
                onPressed: () {
                  final newPos = _position - const Duration(seconds: 10);
                  _audio.seek(newPos < Duration.zero ? Duration.zero : newPos);
                },
              ),
              const SizedBox(width: 8),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _storyColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _storyColor.withOpacity(0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 36,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (_isPlaying) {
                      _audio.pause();
                    } else {
                      _audio.play();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.forward_10_rounded),
                iconSize: 32,
                color: Colors.grey[600],
                onPressed: () {
                  final newPos = _position + const Duration(seconds: 10);
                  if (newPos < _duration) _audio.seek(newPos);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
