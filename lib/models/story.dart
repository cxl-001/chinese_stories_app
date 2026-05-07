import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class Story {
  final int id;
  final String title;
  final String category;
  final int estimatedMinutes;
  final String ageRange;
  final String file;
  final String audioFile;
  final String coverColor;
  String? content;
  List<String>? knowledgePoints;

  Story({
    required this.id,
    required this.title,
    required this.category,
    required this.estimatedMinutes,
    required this.ageRange,
    required this.file,
    required this.audioFile,
    required this.coverColor,
    this.content,
    this.knowledgePoints,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      estimatedMinutes: json['estimated_minutes'] ?? 10,
      ageRange: json['age_range'] ?? '5-10岁',
      file: json['file'] ?? '',
      audioFile: json['audio_file'] ?? '',
      coverColor: json['cover_color'] ?? '#FF6B6B',
    );
  }

  String get durationText {
    return '${estimatedMinutes}分钟';
  }

  static Future<List<Story>> loadAll() async {
    final jsonStr = await rootBundle.loadString('stories/story_list.json');
    final data = json.decode(jsonStr);
    final list = (data['stories'] as List)
        .map((e) => Story.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<void> loadContent() async {
    if (content != null) return;
    try {
      final jsonStr = await rootBundle.loadString('stories/$file');
      final data = json.decode(jsonStr);
      content = data['content'] ?? '';
      knowledgePoints = (data['knowledge_points'] as List?)
          ?.map((e) => e.toString())
          .toList();
    } catch (_) {
      content = '';
      knowledgePoints = [];
    }
  }

  Future<bool> isFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('fav_$id') ?? false;
  }

  Future<void> toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getBool('fav_$id') ?? false;
    await prefs.setBool('fav_$id', !current);
  }
}
