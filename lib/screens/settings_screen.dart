import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _systemPromptController = TextEditingController();
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      _apiKeyController.text = settingsProvider.apiKey ?? '';
      _systemPromptController.text = settingsProvider.systemPrompt ?? '';
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSection(
            context,
            'API Configuration',
            [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Xibe API Key',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your Xibe API key. If left empty, the app will use the default key from environment.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _apiKeyController,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        hintText: 'Enter API key (optional)',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _isObscured ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.save, color: Colors.green),
                              onPressed: () async {
                                final apiKey = _apiKeyController.text.trim();
                                final settingsProvider =
                                    Provider.of<SettingsProvider>(context, listen: false);
                                final chatProvider =
                                    Provider.of<ChatProvider>(context, listen: false);
                                
                                await settingsProvider.setApiKey(
                                  apiKey.isEmpty ? null : apiKey,
                                );
                                chatProvider.updateApiKey(
                                  apiKey.isEmpty ? null : apiKey,
                                );
                                
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('API key saved successfully'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Custom System Prompt',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Set a custom system prompt to define AI behavior (max 1000 characters). Leave empty to use default.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _systemPromptController,
                      maxLength: 1000,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'e.g., You are a helpful assistant that...',
                        counterText: '${_systemPromptController.text.length}/1000',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.save, color: Colors.green),
                          onPressed: () async {
                            final prompt = _systemPromptController.text.trim();
                            final settingsProvider =
                                Provider.of<SettingsProvider>(context, listen: false);
                            final chatProvider =
                                Provider.of<ChatProvider>(context, listen: false);
                            
                            await settingsProvider.setSystemPrompt(
                              prompt.isEmpty ? null : prompt,
                            );
                            chatProvider.updateSystemPrompt(
                              prompt.isEmpty ? null : prompt,
                            );
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('System prompt saved successfully'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {}); // Update counter
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          _buildSection(
            context,
            'Appearance',
            [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Toggle dark/light theme'),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                    activeColor: const Color(0xFF3B82F6),
                  );
                },
              ),
            ],
          ),
          const Divider(),
          _buildSection(
            context,
            'Data',
            [
              ListTile(
                title: const Text('Clear All Chats'),
                subtitle: const Text('Delete all chat history'),
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A1A),
                      title: const Text(
                        'Clear All Chats',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Are you sure you want to delete all chats? This action cannot be undone.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Provider.of<ChatProvider>(context, listen: false)
                                .deleteAllChats();
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Delete All',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(),
          _buildSection(
            context,
            'About',
            [
              const ListTile(
                title: Text('App Version'),
                subtitle: Text('1.0.0'),
                leading: Icon(Icons.info_outline),
              ),
              const ListTile(
                title: Text('Xibe Chat'),
                subtitle: Text('AI Chat Application'),
                leading: Icon(Icons.chat_bubble_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
