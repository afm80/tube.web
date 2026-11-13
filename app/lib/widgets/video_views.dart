import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../config.dart';
import '../utils.dart';

class YoutubeView extends StatefulWidget {
  final String videoId;
  final bool autoPlay;
  final bool mute;

  const YoutubeView({
    super.key,
    required this.videoId,
    this.autoPlay = false,
    this.mute = true,
  });

  @override
  State<YoutubeView> createState() => _YoutubeViewState();
}

class _YoutubeViewState extends State<YoutubeView> {
  late final YoutubePlayerController _c;

  @override
  void initState() {
    super.initState();
    _c = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: widget.autoPlay,
      params: YoutubePlayerParams(
        showFullscreenButton: true,
        mute: widget.autoPlay && widget.mute,
        strictRelatedVideos: true,
      ),
    );
  }

  @override
  void dispose() {
    _c.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(controller: _c, aspectRatio: 16 / 9);
  }
}

/// تشغيل الروابط المباشرة (mp4 / m3u8 / mpd ...).
class DirectVideoView extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool mute;

  const DirectVideoView({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.mute = true,
  });

  @override
  State<DirectVideoView> createState() => _DirectVideoViewState();
}

class _DirectVideoViewState extends State<DirectVideoView> {
  VideoPlayerController? _vc;
  ChewieController? _cc;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      VideoFormat? format;
      if (isHlsUrl(widget.url)) {
        format = VideoFormat.hls;
      } else if (isDashUrl(widget.url)) {
        format = VideoFormat.dash;
      }
      final vc = VideoPlayerController.networkUrl(
        Uri.parse(widget.url.trim()),
        formatHint: format,
      );
      _vc = vc;
      await vc.initialize();
      if (widget.autoPlay && widget.mute) await vc.setVolume(0);
      if (!mounted) return;
      final ratio = vc.value.aspectRatio;
      setState(() {
        _cc = ChewieController(
          videoPlayerController: vc,
          autoPlay: widget.autoPlay,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          aspectRatio: ratio > 0 ? ratio : 16 / 9,
        );
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _cc?.dispose();
    _vc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'تعذر تشغيل رابط الفيديو داخل التطبيق.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFFF7A7A), fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => openExternal(widget.url),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: const Color(0xFF111111)),
                child: const Text('فتح الرابط'),
              ),
            ],
          ),
        ),
      );
    }
    if (_cc == null) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: Colors.black,
          child: Center(child: CircularProgressIndicator(color: AppColors.red)),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: _cc!.aspectRatio ?? 16 / 9,
      child: Chewie(controller: _cc!),
    );
  }
}
