import 'package:flutter/material.dart';
import '../models/story.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Story> _allStories = [];
  List<Story> _filteredStories = [];
  String _selectedCategory = '全部';
  String _childName = '小朋友';
  bool _loading = true;
  final Set<int> _favorites = {};

  String get childName => _childName;
  List<Story> get stories => _filteredStories;
  List<Story> get allStories => _allStories;
  String get selectedCategory => _selectedCategory;
  bool get loading => _loading;
  Set<int> get favorites => _favorites;

  List<String> get categories {
    final cats = <String>{'全部'};
    for (var s in _allStories) {
      cats.add(s.category);
    }
    return cats.toList();
  }

  Future<void> init() async {
    await _storage.init();
    _childName = _storage.childName;
    _allStories = await Story.loadAll();
    _favorites.addAll(_storage.favorites);
    _filteredStories = _allStories;
    _loading = false;
    notifyListeners();
  }

  Future<void> setChildName(String name) async {
    _childName = name.isEmpty ? '小朋友' : name;
    await _storage.setChildName(_childName);
    notifyListeners();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    if (category == '全部') {
      _filteredStories = _allStories;
    } else {
      _filteredStories =
          _allStories.where((s) => s.category == category).toList();
    }
    notifyListeners();
  }

  void searchStories(String query) {
    if (query.isEmpty) {
      filterByCategory(_selectedCategory);
      return;
    }
    _filteredStories = _allStories
        .where((s) => s.title.contains(query))
        .toList();
    notifyListeners();
  }

  List<Story> get favoritesList {
    return _allStories.where((s) => _favorites.contains(s.id)).toList();
  }

  Future<void> toggleFavorite(int storyId) async {
    await _storage.toggleFavorite(storyId);
    if (_favorites.contains(storyId)) {
      _favorites.remove(storyId);
    } else {
      _favorites.add(storyId);
    }
    notifyListeners();
  }

  bool isFavorite(int storyId) => _favorites.contains(storyId);

  Future<void> setLastStory(int storyId) async {
    await _storage.setLastStory(storyId);
  }
}
