import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _flutterTts.setLanguage('zh-CN');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.2);
    _initialized = true;
  }

  Future<void> speakGreeting(String childName, String storyTitle) async {
    final text = '$childName小朋友，现在我们来听《$storyTitle》的故事！';
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
