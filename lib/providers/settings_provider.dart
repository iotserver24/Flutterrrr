import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  String? _apiKey;
  String? _systemPrompt;

  String? get apiKey => _apiKey;
  String? get systemPrompt => _systemPrompt;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _apiKey = _prefs?.getString('xibe_api_key');
    _systemPrompt = _prefs?.getString('system_prompt');
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
}
