import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:story_create/models/story_model.dart';

class StoryService extends ChangeNotifier {
  final Box<StoryModel> _storyBox = Hive.box<StoryModel>('stories');

  List<StoryModel> get stories => _storyBox.values.toList();

  Future<void> addStory(StoryModel story) async {
    await _storyBox.add(story);
    notifyListeners();
  }

  Future<void> updateStory(String id, StoryModel updatedStory) async {
    final story = _storyBox.values.firstWhere((s) => s.id == id);
    final index = story.key as int;
    await _storyBox.putAt(index, updatedStory);
    notifyListeners();
  }

  Future<void> deleteStory(String id) async {
    final story = _storyBox.values.firstWhere((s) => s.id == id);
    await story.delete();
    notifyListeners();
  }

  Future<void> deleteAllStories() async {
    await _storyBox.clear();
    notifyListeners();
  }

  StoryModel? getStory(String id) {
    try {
      return _storyBox.values.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}
