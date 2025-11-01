import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  String? _apiKey;
  String? _systemPrompt;
  String? _e2bApiKey;

  String? get apiKey => _apiKey;
  String? get systemPrompt => _systemPrompt;
  String? get e2bApiKey => _e2bApiKey;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _apiKey = _prefs?.getString('xibe_api_key');
    _systemPrompt = _prefs?.getString('system_prompt');
    _e2bApiKey = _prefs?.getString('e2b_api_key');
    notifyListeners();
  }

  Future<void> setApiKey(String? key) async {
    _apiKey = key;
    if (key != null && key.isNotEmpty) {
      await _prefs?.setString('xibe_api_key', key);
    } else {
      await _prefs?.remove('xibe_api_key');
    }
    notifyListeners();
  }

  Future<void> setSystemPrompt(String? prompt) async {
    _systemPrompt = prompt;
    if (prompt != null && prompt.isNotEmpty) {
      await _prefs?.setString('system_prompt', prompt);
    } else {
      await _prefs?.remove('system_prompt');
    }
    notifyListeners();
  }

  Future<void> setE2bApiKey(String? key) async {
    _e2bApiKey = key;
    if (key != null && key.isNotEmpty) {
      await _prefs?.setString('e2b_api_key', key);
    } else {
      await _prefs?.remove('e2b_api_key');
    }
    notifyListeners();
  }
}
