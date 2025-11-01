import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_drawer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  bool get _isDesktop {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  @override
  Widget build(BuildContext context) {
    // On desktop, use a side-by-side layout if screen is wide enough
    final screenWidth = MediaQuery.of(context).size.width;
    final useDesktopLayout = _isDesktop && screenWidth > 800;

    if (useDesktopLayout) {
      return _buildDesktopLayout(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Xibe Chat'),
                if (chatProvider.selectedModel.isNotEmpty)
                  Text(
                    'Model: ${chatProvider.selectedModel}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ),
                  ),
              ],
            );
          },
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.smart_toy),
                tooltip: 'Select AI Model',
                onSelected: (String model) {
                  chatProvider.setSelectedModel(model);
                },
                itemBuilder: (BuildContext context) {
                  if (chatProvider.availableModels.isEmpty) {
                    return const [
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Text('Loading models...'),
                      ),
                    ];
                  }
                  return chatProvider.availableModels.map((model) {
                    final isSelected = chatProvider.selectedModel == model.name;
                    return PopupMenuItem<String>(
                      value: model.name,
                      child: Row(
                        children: [
                          if (isSelected)
                            const Icon(Icons.check, size: 16, color: Colors.green),
                          if (isSelected) const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  model.description,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
              );
            },
          ),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (chatProvider.currentChat == null) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    chatProvider.createNewChat();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      drawer: const ChatDrawer(),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.currentChat == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No chat selected',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            chatProvider.createNewChat();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                          ),
                          child: const Text(
                            'Start New Chat',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                // Show greeting for new chats (no messages yet)
                final showGreeting = chatProvider.messages.isEmpty;

                return Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: (showGreeting ? 1 : 0) +
                          chatProvider.messages.length +
                          (chatProvider.isStreaming ? 1 : 0) +
                          (chatProvider.isLoading && !chatProvider.isStreaming ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show greeting at the top for new chats
                        if (showGreeting && index == 0) {
                          return TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 500),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            builder: (context, double value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chatProvider.getGreeting(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'How\'s your day going?',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final messageIndex = showGreeting ? index - 1 : index;
                        
                        // Show streaming message
                        if (chatProvider.isStreaming &&
                            messageIndex == chatProvider.messages.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: MessageBubble(
                              message: Message(
                                role: 'assistant',
                                content: chatProvider.streamingContent,
                                timestamp: DateTime.now(),
                                chatId: chatProvider.currentChat!.id!,
                              ),
                              isStreaming: true,
                            ),
                          );
                        }

                        // Show typing indicator
                        if (chatProvider.isLoading &&
                            !chatProvider.isStreaming &&
                            messageIndex == chatProvider.messages.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: TypingIndicator(),
                          );
                        }

                        // Show normal message
                        return TweenAnimationBuilder(
                          key: ValueKey(chatProvider.messages[messageIndex].id),
                          duration: const Duration(milliseconds: 300),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 10 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: MessageBubble(
                            message: chatProvider.messages[messageIndex],
                          ),
                        );
                      },
                    ),
                    if (chatProvider.error != null)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Error',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      chatProvider.error!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  chatProvider.clearError();
                                },
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return ChatInput(
                onSendMessage: (message) {
                  chatProvider.sendMessage(message);
                },
                isLoading: chatProvider.isLoading,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar with chat list - always visible on desktop
          Container(
            width: 280,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: const ChatDrawer(),
          ),
          // Main chat area
          Expanded(
            child: Column(
              children: [
                // AppBar-like header
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: Consumer<ChatProvider>(
                          builder: (context, chatProvider, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Xibe Chat',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                if (chatProvider.selectedModel.isNotEmpty)
                                  Text(
                                    'Model: ${chatProvider.selectedModel}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      // Model selection
                      Consumer<ChatProvider>(
                        builder: (context, chatProvider, child) {
                          return PopupMenuButton<String>(
                            icon: const Icon(Icons.smart_toy, color: Colors.white),
                            tooltip: 'Select AI Model',
                            onSelected: (String model) {
                              chatProvider.setSelectedModel(model);
                            },
                            itemBuilder: (BuildContext context) {
                              if (chatProvider.availableModels.isEmpty) {
                                return [
                                  const PopupMenuItem<String>(
                                    enabled: false,
                                    child: Text('Loading models...'),
                                  ),
                                ];
                              }
                              return chatProvider.availableModels.map((model) {
                                final isSelected = model.id == chatProvider.selectedModel;
                                return PopupMenuItem<String>(
                                  value: model.id,
                                  child: Row(
                                    children: [
                                      if (isSelected)
                                        const Icon(Icons.check, size: 16)
                                      else
                                        const SizedBox(width: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              model.name,
                                              style: TextStyle(
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                            Text(
                                              model.description,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList();
                            },
                          );
                        },
                      ),
                      // New chat button
                      Consumer<ChatProvider>(
                        builder: (context, chatProvider, child) {
                          if (chatProvider.currentChat == null) {
                            return IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: () {
                                chatProvider.createNewChat();
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      // Settings
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                // Chat messages
                Expanded(
                  child: Consumer<ChatProvider>(
                    builder: (context, chatProvider, child) {
                      if (chatProvider.currentChat == null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No chat selected',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  chatProvider.createNewChat();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                ),
                                child: const Text(
                                  'Start New Chat',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });

                      final showGreeting = chatProvider.messages.isEmpty && !chatProvider.isLoading;
                      final itemCount = chatProvider.messages.length +
                          (showGreeting ? 1 : 0) +
                          (chatProvider.isStreaming ? 1 : 0) +
                          (chatProvider.isLoading && !chatProvider.isStreaming ? 1 : 0);

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          if (showGreeting && index == 0) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).primaryColor,
                                      Theme.of(context).primaryColor.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chatProvider.getGreeting(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'How\'s your day going?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final messageIndex = showGreeting ? index - 1 : index;

                          if (chatProvider.isStreaming &&
                              messageIndex == chatProvider.messages.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: MessageBubble(
                                message: Message(
                                  role: 'assistant',
                                  content: chatProvider.streamingContent,
                                  timestamp: DateTime.now(),
                                  webSearchUsed: false,
                                ),
                              ),
                            );
                          }

                          if (chatProvider.isLoading &&
                              !chatProvider.isStreaming &&
                              messageIndex == chatProvider.messages.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: TypingIndicator(),
                            );
                          }

                          final message = chatProvider.messages[messageIndex];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: MessageBubble(message: message),
                          );
                        },
                      );
                    },
                  ),
                ),
                // Input area
                Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    return ChatInput(
                      onSendMessage: (message) {
                        chatProvider.sendMessage(message);
                      },
                      isLoading: chatProvider.isLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
