import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/ai_model.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../services/mcp_client_service.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  late ApiService _apiService;
  final McpClientService _mcpClientService = McpClientService();

  List<Chat> _chats = [];
  Chat? _currentChat;
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isStreaming = false;
  String? _error;
  String _streamingContent = '';
  List<AiModel> _availableModels = [];
  String _selectedModel = 'gemini'; // Default model
  String? _systemPrompt;

  List<Chat> get chats => _chats;
  Chat? get currentChat => _currentChat;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isStreaming => _isStreaming;
  String? get error => _error;
  String get streamingContent => _streamingContent;
  List<AiModel> get availableModels => _availableModels;
  String get selectedModel => _selectedModel;
  String? get systemPrompt => _systemPrompt;
  
  bool get selectedModelSupportsVision {
    final model = _availableModels.firstWhere(
      (m) => m.name == _selectedModel,
      orElse: () => AiModel(
        name: '',
        description: '',
        inputModalities: [],
        outputModalities: [],
        aliases: [],
      ),
    );
    return model.vision == true || 
           model.inputModalities.contains('image');
  }

  ChatProvider({String? apiKey, String? systemPrompt}) {
    _systemPrompt = systemPrompt;
    _initializeApiService(apiKey);
    _loadChats();
    _loadModels();
    _initializeMcp();
  }

  Future<void> _initializeMcp() async {
    try {
      await _mcpClientService.initialize();
    } catch (e) {
      // Silently fail MCP initialization, don't block app startup
      print('Failed to initialize MCP: $e');
    }
  }

  /// Reload MCP configuration and reconnect to servers
  Future<void> reloadMcpServers() async {
    try {
      await _mcpClientService.reload();
      notifyListeners();
    } catch (e) {
      print('Failed to reload MCP servers: $e');
    }
  }

  void _initializeApiService(String? providedApiKey) {
    // Use provided API key from settings, or fallback to hardcoded test API key
    // Note: This test key is hardcoded for development/testing purposes
    String? apiKey = providedApiKey ?? 'XAI_t2o3pFT7JpV026x6vszxpIH55SFcVgjS';
    _apiService = ApiService(apiKey: apiKey);
  }

  void updateApiKey(String? apiKey) {
    _initializeApiService(apiKey);
    _loadModels(); // Reload models with new API key
  }

  void updateSystemPrompt(String? systemPrompt) {
    _systemPrompt = systemPrompt;
    notifyListeners();
  }

  Future<void> _loadModels() async {
    try {
      _availableModels = await _apiService.fetchModels();
      
      // Add custom Claude 4.5 Haiku model
      final claudeModel = AiModel(
        name: 'claudyclaude', // Model ID used in API calls
        description: 'Claude 4.5 Haiku',
        inputModalities: ['text', 'image'],
        outputModalities: ['text'],
        aliases: ['claude-4.5-haiku', 'claude-haiku'],
        vision: true,
        tools: false,
      );
      
      // Check if model already exists to avoid duplicates
      if (!_availableModels.any((m) => m.name == 'claudyclaude')) {
        _availableModels.add(claudeModel);
      }
      
      notifyListeners();
    } catch (e) {
      // Silently fail, use default model
      _availableModels = [];
      
      // Add custom Claude model even if API fetch fails
      final claudeModel = AiModel(
        name: 'claudyclaude',
        description: 'Claude 4.5 Haiku - Fast and efficient model with vision support',
        inputModalities: ['text', 'image'],
        outputModalities: ['text'],
        aliases: ['claude 4.5 haiku', 'claude-haiku', 'claude-4.5-haiku'],
        vision: true,
        tools: false,
      );
      _availableModels.add(claudeModel);
      notifyListeners();
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
    final chats = await _databaseService.getAllChats();
    _chats = chats;
    // Only auto-select first chat if no current chat is selected
    // This helps on initial load, but won't interfere with newly created chats
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
    
    // Set state immediately before async operations
    _currentChat = Chat(
      id: id,
      title: chat.title,
      createdAt: chat.createdAt,
      updatedAt: chat.updatedAt,
    );
    _messages = [];
    _error = null;
    _isLoading = false;
    _isStreaming = false;
    _streamingContent = '';
    
    // Notify immediately so UI updates right away
    notifyListeners();
    
    // Then reload chats list in background
    final chats = await _databaseService.getAllChats();
    _chats = chats;
    // Notify again after chats list is updated
    notifyListeners();
  }

  Future<void> selectChat(Chat chat) async {
    _currentChat = chat;
    _messages = await _databaseService.getMessagesForChat(chat.id!);
    _error = null;
    notifyListeners();
  }

  Future<void> sendMessage(String content, {String? imageBase64, String? imagePath, bool webSearch = false, bool reasoning = false}) async {
    if (_currentChat == null) {
      await createNewChat();
    }

    _error = null;
    final userMessage = Message(
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
      chatId: _currentChat!.id!,
      imageBase64: imageBase64,
      imagePath: imagePath,
      webSearchUsed: webSearch,
    );

    final insertedId = await _databaseService.insertMessage(userMessage);
    final messageWithId = Message(
      id: insertedId,
      role: userMessage.role,
      content: userMessage.content,
      timestamp: userMessage.timestamp,
      webSearchUsed: userMessage.webSearchUsed,
      chatId: userMessage.chatId,
      imageBase64: userMessage.imageBase64,
      imagePath: userMessage.imagePath,
    );
    _messages.add(messageWithId);
    
    // Immediately notify listeners to show the user message in UI
    notifyListeners();
    
    final isFirstMessage = _messages.length == 1;

    _isLoading = true;
    _isStreaming = true;
    _streamingContent = '';
    notifyListeners();

    try {
      // Get all messages except the user message we just added (last one in the list)
      final history = _messages.where((m) => m.role != 'system').toList();
      final historyForApi = history.length > 1 ? history.sublist(0, history.length - 1) : <Message>[];
      
      // Get MCP context (available tools and resources)
      String? mcpContext;
      try {
        final context = _mcpClientService.getMcpContext();
        if (context.isNotEmpty) {
          mcpContext = context;
        }
      } catch (e) {
        // Silently fail, continue without MCP context
        print('Error getting MCP context: $e');
      }

      // Combine system prompt with MCP context if available
      String? enhancedSystemPrompt = _systemPrompt;
      if (mcpContext != null && mcpContext.isNotEmpty) {
        if (enhancedSystemPrompt != null && enhancedSystemPrompt.isNotEmpty) {
          enhancedSystemPrompt = '$_systemPrompt\n\n$mcpContext';
        } else {
          enhancedSystemPrompt = mcpContext;
        }
      }
      
      // For first message, append instruction to generate chat name
      if (isFirstMessage && enhancedSystemPrompt != null && enhancedSystemPrompt.isNotEmpty) {
        enhancedSystemPrompt = '$enhancedSystemPrompt\n\nIMPORTANT: At the end of your response, append a JSON object with a chat name suggestion. Format: {"chat_name": "suggested name"}. The chat name should be a short, descriptive title based on the conversation. Do not include this instruction or the JSON in your actual response text.';
      } else if (isFirstMessage) {
        enhancedSystemPrompt = 'IMPORTANT: At the end of your response, append a JSON object with a chat name suggestion. Format: {"chat_name": "suggested name"}. The chat name should be a short, descriptive title based on the conversation. Do not include this instruction or the JSON in your actual response text.';
      }
      
      // Stream the response
      String fullResponseContent = '';
      String streamingDisplayContent = '';
      await for (final chunk in _apiService.sendMessageStream(
        message: content,
        history: historyForApi,
        model: _selectedModel,
        systemPrompt: enhancedSystemPrompt,
        reasoning: reasoning,
        mcpTools: _mcpClientService.getAllTools(),
      )) {
        fullResponseContent += chunk;
        
        // For first message, try to filter out chat name JSON from display
        if (isFirstMessage) {
          // Check if we've started receiving JSON pattern
          final jsonPattern = RegExp(r'\{"chat_name"', caseSensitive: false);
          if (jsonPattern.hasMatch(fullResponseContent)) {
            // Remove JSON part from display
            final jsonMatch = jsonPattern.firstMatch(fullResponseContent);
            if (jsonMatch != null) {
              streamingDisplayContent = fullResponseContent.substring(0, jsonMatch.start).trim();
            } else {
              streamingDisplayContent = fullResponseContent;
            }
          } else {
            streamingDisplayContent = fullResponseContent;
          }
        } else {
          streamingDisplayContent = fullResponseContent;
        }
        
        // Update streaming content for display (without chat name JSON)
        _streamingContent = streamingDisplayContent;
        notifyListeners();
      }

      // Extract chat name from full response if it's the first message
      String displayContent = fullResponseContent;
      String? extractedChatName;
      
      if (isFirstMessage) {
        // Try to find JSON object with chat_name at the end
        final jsonPattern = RegExp(r'\{"chat_name"\s*:\s*"([^"]+)"\}', caseSensitive: false);
        final match = jsonPattern.firstMatch(fullResponseContent);
        
        if (match != null) {
          extractedChatName = match.group(1);
          // Remove the JSON part from the display content
          final jsonStart = match.start;
          displayContent = fullResponseContent.substring(0, jsonStart).trim();
          
          // Also try to remove any leading/trailing whitespace or extra content
          displayContent = displayContent.replaceAll(RegExp(r'\{"chat_name"[^\}]*\}', caseSensitive: false), '').trim();
        } else {
          // Fallback: try to find it in different formats
          // Try double quotes first
          RegExp? altPattern = RegExp(r'chat_name"?\s*:\s*"([^"]+)"', caseSensitive: false);
          Match? altMatch = altPattern.firstMatch(fullResponseContent);
          
          // If not found, try single quotes
          if (altMatch == null) {
            altPattern = RegExp(r"chat_name'?\s*:\s*'([^']+)'", caseSensitive: false);
            altMatch = altPattern.firstMatch(fullResponseContent);
          }
          
          if (altMatch != null) {
            extractedChatName = altMatch.group(1);
            displayContent = fullResponseContent.substring(0, altMatch.start).trim();
          }
        }
        
        // If no chat name found, use a fallback
        if (extractedChatName == null || extractedChatName.isEmpty) {
          extractedChatName = content.length > 30 ? '${content.substring(0, 30)}...' : content;
        }
        
        // Update chat title with extracted name
        _currentChat = Chat(
          id: _currentChat!.id,
          title: extractedChatName,
          createdAt: _currentChat!.createdAt,
          updatedAt: DateTime.now(),
        );
        await _databaseService.updateChat(_currentChat!);
        await _loadChats();
      }

      // Save the response with cleaned content (without chat name JSON)
      final assistantMessage = Message(
        role: 'assistant',
        content: displayContent,
        timestamp: DateTime.now(),
        webSearchUsed: webSearch,
        chatId: _currentChat!.id!,
      );

      final assistantInsertedId = await _databaseService.insertMessage(assistantMessage);
      final assistantMessageWithId = Message(
        id: assistantInsertedId,
        role: assistantMessage.role,
        content: assistantMessage.content,
        timestamp: assistantMessage.timestamp,
        webSearchUsed: assistantMessage.webSearchUsed,
        chatId: assistantMessage.chatId,
      );
      _messages.add(assistantMessageWithId);

      // Update chat's updatedAt timestamp if not already updated
      if (!isFirstMessage) {
        _currentChat = Chat(
          id: _currentChat!.id,
          title: _currentChat!.title,
          createdAt: _currentChat!.createdAt,
          updatedAt: DateTime.now(),
        );
        await _databaseService.updateChat(_currentChat!);
        await _loadChats();
      }
      
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
