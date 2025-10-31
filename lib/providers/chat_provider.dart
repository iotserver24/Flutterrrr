import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/ai_model.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ChatProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  late ApiService _apiService;

  List<Chat> _chats = [];
  Chat? _currentChat;
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isStreaming = false;
  String? _error;
  String _streamingContent = '';
  List<AiModel> _availableModels = [];
  String _selectedModel = 'gemini'; // Default model

  List<Chat> get chats => _chats;
  Chat? get currentChat => _currentChat;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isStreaming => _isStreaming;
  String? get error => _error;
  String get streamingContent => _streamingContent;
  List<AiModel> get availableModels => _availableModels;
  String get selectedModel => _selectedModel;

  ChatProvider({String? apiKey}) {
    _initializeApiService(apiKey);
    _loadChats();
    _loadModels();
  }

  void _initializeApiService(String? providedApiKey) {
    // Priority: 1. Provided API key, 2. Environment variable, 3. null
    String? apiKey = providedApiKey;
    
    if (apiKey == null && !kIsWeb) {
      try {
        apiKey = Platform.environment['XIBE_API'];
      } catch (e) {
        // Environment variables might not be available in all contexts
        apiKey = null;
      }
    }
    _apiService = ApiService(apiKey: apiKey);
  }

  void updateApiKey(String? apiKey) {
    _initializeApiService(apiKey);
    _loadModels(); // Reload models with new API key
  }

  Future<void> _loadModels() async {
    try {
      _availableModels = await _apiService.fetchModels();
      notifyListeners();
    } catch (e) {
      // Silently fail, use default model
      _availableModels = [];
    }
  }

  void setSelectedModel(String model) {
    _selectedModel = model;
    notifyListeners();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning! ☀️';
    } else if (hour < 17) {
      return 'Good afternoon! 🌤️';
    } else {
      return 'Good evening! 🌙';
    }
  }

  Future<void> _loadChats() async {
    _chats = await _databaseService.getAllChats();
    if (_chats.isNotEmpty && _currentChat == null) {
      await selectChat(_chats.first);
    }
    notifyListeners();
  }

  Future<void> createNewChat() async {
    final now = DateTime.now();
    final chat = Chat(
      title: 'New Chat',
      createdAt: now,
      updatedAt: now,
    );
    final id = await _databaseService.createChat(chat);
    _currentChat = Chat(
      id: id,
      title: chat.title,
      createdAt: chat.createdAt,
      updatedAt: chat.updatedAt,
    );
    _messages = [];
    await _loadChats();
    notifyListeners();
  }

  Future<void> selectChat(Chat chat) async {
    _currentChat = chat;
    _messages = await _databaseService.getMessagesForChat(chat.id!);
    _error = null;
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (_currentChat == null) {
      await createNewChat();
    }

    _error = null;
    final userMessage = Message(
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
      chatId: _currentChat!.id!,
    );

    await _databaseService.insertMessage(userMessage);
    _messages.add(userMessage);
    
    // Update chat title if it's the first message
    if (_messages.length == 1) {
      final title = content.length > 30 ? '${content.substring(0, 30)}...' : content;
      _currentChat = Chat(
        id: _currentChat!.id,
        title: title,
        createdAt: _currentChat!.createdAt,
        updatedAt: DateTime.now(),
      );
      await _databaseService.updateChat(_currentChat!);
      await _loadChats();
    }

    _isLoading = true;
    _isStreaming = true;
    _streamingContent = '';
    notifyListeners();

    try {
      // Get all messages except the user message we just added (last one in the list)
      final history = _messages.where((m) => m.role != 'system').toList();
      final historyForApi = history.length > 1 ? history.sublist(0, history.length - 1) : <Message>[];
      
      // Stream the response
      await for (final chunk in _apiService.sendMessageStream(
        message: content,
        history: historyForApi,
        model: _selectedModel,
      )) {
        _streamingContent += chunk;
        notifyListeners();
      }

      // Save the complete response
      final assistantMessage = Message(
        role: 'assistant',
        content: _streamingContent,
        timestamp: DateTime.now(),
        webSearchUsed: false,
        chatId: _currentChat!.id!,
      );

      await _databaseService.insertMessage(assistantMessage);
      _messages.add(assistantMessage);

      // Update chat's updatedAt timestamp
      _currentChat = Chat(
        id: _currentChat!.id,
        title: _currentChat!.title,
        createdAt: _currentChat!.createdAt,
        updatedAt: DateTime.now(),
      );
      await _databaseService.updateChat(_currentChat!);
      await _loadChats();
      
      _streamingContent = '';
    } catch (e) {
      _error = e.toString();
      _streamingContent = '';
    } finally {
      _isLoading = false;
      _isStreaming = false;
      notifyListeners();
    }
  }

  Future<void> deleteChat(int chatId) async {
    await _databaseService.deleteChat(chatId);
    if (_currentChat?.id == chatId) {
      _currentChat = null;
      _messages = [];
    }
    await _loadChats();
    notifyListeners();
  }

  Future<void> deleteAllChats() async {
    await _databaseService.deleteAllChats();
    _currentChat = null;
    _messages = [];
    await _loadChats();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
