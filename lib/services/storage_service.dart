import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _keyChildName = 'child_name';
  static const _keyFavorites = 'favorites';
  static const _keyLastStory = 'last_story_id';
  static const _keyLastPosition = 'last_position_';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String get childName {
    return _prefs.getString(_keyChildName) ?? '小朋友';
  }

  Future<void> setChildName(String name) async {
    await _prefs.setString(_keyChildName, name);
  }

  Future<void> toggleFavorite(int storyId) async {
    final list = favorites;
    if (list.contains(storyId)) {
      list.remove(storyId);
    } else {
      list.add(storyId);
    }
    await _prefs.setStringList(
        _keyFavorites, list.map((e) => e.toString()).toList());
  }

  List<int> get favorites {
    final list = _prefs.getStringList(_keyFavorites) ?? [];
    return list.map((e) => int.parse(e)).toList();
  }

  bool isFavorite(int storyId) {
    return favorites.contains(storyId);
  }

  int get lastStoryId => _prefs.getInt(_keyLastStory) ?? 0;

  Future<void> setLastStory(int storyId) async {
    await _prefs.setInt(_keyLastStory, storyId);
  }

  Future<void> savePosition(int storyId, Duration position) async {
    await _prefs.setInt('$_keyLastPosition$storyId', position.inMilliseconds);
  }

  Duration getPosition(int storyId) {
    final ms = _prefs.getInt('$_keyLastPosition$storyId') ?? 0;
    return Duration(milliseconds: ms);
  }
}
