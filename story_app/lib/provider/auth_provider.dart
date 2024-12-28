import 'package:flutter/material.dart';
import 'package:story_app/data/api/story_api.dart';
import 'package:story_app/data/model/login_model.dart';
import 'package:story_app/data/model/response_post_model.dart';

enum AuthState { initial, loading, error }

class RegisterProvider extends ChangeNotifier {
  final StoryApi storyApi;

  RegisterProvider({required this.storyApi});

  late ResponsePostModel _response;
  AuthState _state = AuthState.initial;
  String _message = '';
  bool _isLoading = false;

  ResponsePostModel get response => _response;
  AuthState get state => _state;
  String get meesage => _message;
  bool get isLoading => _isLoading;

  changeState(AuthState s) {
    _state = s;
    notifyListeners();
  }

  Future registerAccount(String username, String email, String password) async {
    try {
      _isLoading = true;
      changeState(AuthState.loading);
      final response = await storyApi.register(username, email, password);

      _isLoading = false;
      changeState(AuthState.initial);
      return _response = response;
    } catch (e) {
      _isLoading = false;
      changeState(AuthState.error);
      return _message = 'Error $e';
    }
  }
}

class LoginProvider extends ChangeNotifier {
  final StoryApi storyApi;

  LoginProvider({required this.storyApi});

  late LoginModel _response;
  AuthState _state = AuthState.initial;
  String _message = '';
  bool _isLoading = false;

  LoginModel get response => _response;
  AuthState get state => _state;
  String get meesage => _message;
  bool get isLoading => _isLoading;

  changeState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  Future loginAccount(String email, String password) async {
    try {
      _isLoading = true;
      changeState(AuthState.loading);
      final response = await storyApi.login(email, password);

      _isLoading = false;
      changeState(AuthState.initial);
      return _response = response;
    } catch (e) {
      _isLoading = false;
      changeState(AuthState.error);
      return _message = 'Error $e';
    }
  }
}
