import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:story_app/data/api/story_api.dart';
import 'package:story_app/data/model/response_post_model.dart';
import 'package:story_app/data/model/story_detail_model.dart';
import 'package:story_app/data/model/story_list_model.dart';

enum StoryState { initial, loading, loaded, error }

class ListStoryProvider extends ChangeNotifier {
  final StoryApi storyApi;

  ListStoryProvider({required this.storyApi});

  late ListStoryModel _listStoryModel;
  StoryState _state = StoryState.initial;
  String _message = '';

  ListStoryModel get listStoryModel => _listStoryModel;
  StoryState get state => _state;
  String get message => _message;

  int? pageItems = 1;

  changeState(StoryState s) {
    _state = s;
    notifyListeners();
  }

  Future getListStory(String token) async {
    try {
      if (pageItems == 1) {
        changeState(StoryState.loading);
      }
      final response = await storyApi.getListStory(token, pageItems!);
      print('page itemnya :$pageItems');

      if (response.listStory.isEmpty) {
        changeState(StoryState.initial);
        return _message = 'empty data';
      } else {
        if (pageItems! > 1) {
          if (response.listStory.length < 10) {
            pageItems = null;
          } else {
            pageItems = pageItems! + 1;
          }
          changeState(StoryState.loaded);
          _listStoryModel.listStory.addAll(response.listStory);
          return _listStoryModel;
        }

        pageItems = pageItems! + 1;
        changeState(StoryState.loaded);
        return _listStoryModel = response;
      }
    } catch (e) {
      changeState(StoryState.error);
      return _message = 'Error $e';
    }
  }
}

class DetailStoryProvider extends ChangeNotifier {
  final StoryApi storyApi;

  DetailStoryProvider({required this.storyApi});

  late DetailStoryModel _detailStoryModel;
  StoryState _state = StoryState.initial;
  String _message = '';

  DetailStoryModel get detailStoryModel => _detailStoryModel;
  StoryState get state => _state;
  String get message => _message;

  changeState(StoryState s) {
    _state = s;
    notifyListeners();
  }

  Future getDetailStory(String token, String id) async {
    try {
      changeState(StoryState.loading);
      final response = await storyApi.getDetailStory(token, id);
      changeState(StoryState.loaded);
      return _detailStoryModel = response;
    } catch (e) {
      changeState(StoryState.error);
      return _message = 'Error $e';
    }
  }
}

class NewStoryProvider extends ChangeNotifier {
  final StoryApi storyApi;
  XFile? imageFile;
  String? imagePath;
  bool isUploading = false;
  String message = "";
  ResponsePostModel? response;

  NewStoryProvider({required this.storyApi});

  void setImageFile(XFile? value) {
    imageFile = value;
    notifyListeners();
  }

  void setImagePath(String? value) {
    imagePath = value;
    notifyListeners();
  }

  Future<void> upload(
    List<int> bytes,
    String fileName,
    String description,
    String token,
    double lat,
    double lon,
  ) async {
    try {
      message = '';
      response = null;
      isUploading = true;
      notifyListeners();
      response = await storyApi.addNewStory(bytes, fileName, description, token, lat, lon);
      message = response?.message ?? 'success';
      isUploading = false;
      notifyListeners();
    } catch (e) {
      isUploading = false;
      message = e.toString();
      notifyListeners();
    }
  }
}
