import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String audioPath;
  final String title;

  const AudioPlayerScreen({
    super.key,
    required this.audioPath,
    required this.title,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  Future<void> _setupAudioPlayer() async {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    // Set the source but don't auto-play
    await _audioPlayer.setSourceDeviceFile(widget.audioPath);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.music_note,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 48),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Slider(
              min: 0,
              max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1,
              value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1),
              activeColor: Theme.of(context).primaryColor,
              onChanged: (value) async {
                final position = Duration(seconds: value.toInt());
                await _audioPlayer.seek(position);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_position)),
                  Text(_formatDuration(_duration)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 48,
                  icon: const Icon(CupertinoIcons.backward_fill),
                  onPressed: () async {
                    final newPos = _position - const Duration(seconds: 10);
                    await _audioPlayer.seek(newPos.isNegative ? Duration.zero : newPos);
                  },
                ),
                const SizedBox(width: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    iconSize: 64,
                    color: Colors.white,
                    icon: Icon(_isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill),
                    onPressed: () async {
                      if (_isPlaying) {
                        await _audioPlayer.pause();
                      } else {
                        await _audioPlayer.resume();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  iconSize: 48,
                  icon: const Icon(CupertinoIcons.forward_fill),
                  onPressed: () async {
                    final newPos = _position + const Duration(seconds: 10);
                    if (newPos < _duration) {
                      await _audioPlayer.seek(newPos);
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
