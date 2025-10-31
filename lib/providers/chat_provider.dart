import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final ApiService _apiService = ApiService();

  List<Chat> _chats = [];
  Chat? _currentChat;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Chat> get chats => _chats;
  Chat? get currentChat => _currentChat;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ChatProvider() {
    _loadChats();
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

  Future<void> sendMessage(String content, {bool enableWebSearch = true}) async {
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
    notifyListeners();

    try {
      final history = _messages.where((m) => m.role != 'system').toList();
      final historyForApi = history.length > 1 ? history.sublist(0, history.length - 1) : <Message>[];
      final response = await _apiService.sendMessage(
        message: content,
        history: historyForApi,
        enableWebSearch: enableWebSearch,
      );

      final assistantMessage = Message(
        role: 'assistant',
        content: response['response'] ?? '',
        timestamp: DateTime.now(),
        webSearchUsed: response['web_search_used'] ?? false,
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
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
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
