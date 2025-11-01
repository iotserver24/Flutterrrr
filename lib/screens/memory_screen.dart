import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/memory.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final TextEditingController _memoryController = TextEditingController();

  @override
  void dispose() {
    _memoryController.dispose();
    super.dispose();
  }

  void _showAddMemoryDialog() {
    _memoryController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Memory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add a memory point about yourself for the AI to remember:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _memoryController,
              maxLines: 3,
              maxLength: SettingsProvider.maxSingleMemoryCharacters,
              decoration: const InputDecoration(
                hintText: 'e.g., I prefer Python for backend development',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Consumer<SettingsProvider>(
              builder: (context, settings, child) {
                final totalChars = settings.getTotalMemoryCharacters();
                final remaining = SettingsProvider.maxTotalMemoryCharacters - totalChars;
                return Text(
                  'Total memory: $totalChars/${SettingsProvider.maxTotalMemoryCharacters} characters (${remaining} remaining)',
                  style: TextStyle(
                    fontSize: 12,
                    color: totalChars > (SettingsProvider.maxTotalMemoryCharacters * 0.9).toInt() ? Colors.red : Colors.grey,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final content = _memoryController.text.trim();
              if (content.isEmpty) return;

              final settingsProvider =
                  Provider.of<SettingsProvider>(context, listen: false);
              
              // Check if adding this memory would exceed the limit
              final currentTotal = settingsProvider.getTotalMemoryCharacters();
              if (currentTotal + content.length > SettingsProvider.maxTotalMemoryCharacters) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Memory limit exceeded. Delete some memories first.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              await settingsProvider.addMemory(content);
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Image.asset(
                          'logo-nobg.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text('Memory saved successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditMemoryDialog(Memory memory) {
    _memoryController.text = memory.content;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Memory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _memoryController,
              maxLines: 3,
              maxLength: SettingsProvider.maxSingleMemoryCharacters,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Consumer<SettingsProvider>(
              builder: (context, settings, child) {
                final totalChars = settings.getTotalMemoryCharacters() - memory.content.length;
                final remaining = SettingsProvider.maxTotalMemoryCharacters - totalChars;
                return Text(
                  'Total memory: $totalChars/${SettingsProvider.maxTotalMemoryCharacters} characters (${remaining} remaining)',
                  style: TextStyle(
                    fontSize: 12,
                    color: totalChars > (SettingsProvider.maxTotalMemoryCharacters * 0.9).toInt() ? Colors.red : Colors.grey,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final content = _memoryController.text.trim();
              if (content.isEmpty) return;

              final settingsProvider =
                  Provider.of<SettingsProvider>(context, listen: false);
              
              // Check if editing this memory would exceed the limit
              final currentTotal = settingsProvider.getTotalMemoryCharacters() - memory.content.length;
              if (currentTotal + content.length > SettingsProvider.maxTotalMemoryCharacters) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Memory limit exceeded.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              await settingsProvider.updateMemoryContent(memory.id!, content);
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Memory updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Memory'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          final memories = settingsProvider.memories;
          final totalChars = settingsProvider.getTotalMemoryCharacters();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Long-Term Memory',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'These memory points are automatically sent with every chat to help the AI remember important information about you.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: totalChars / SettingsProvider.maxTotalMemoryCharacters,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        totalChars > (SettingsProvider.maxTotalMemoryCharacters * 0.9).toInt() ? Colors.red : Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalChars / SettingsProvider.maxTotalMemoryCharacters characters used',
                      style: TextStyle(
                        fontSize: 12,
                        color: totalChars > (SettingsProvider.maxTotalMemoryCharacters * 0.9).toInt() ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: memories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.psychology_outlined,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No memories saved yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add memory points for the AI to remember',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: memories.length,
                        itemBuilder: (context, index) {
                          final memory = memories[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(Icons.circle, size: 8),
                              title: Text(memory.content),
                              subtitle: Text(
                                '${memory.content.length} characters • Updated ${_formatDate(memory.updatedAt)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _showEditMemoryDialog(memory),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Memory'),
                                          content: const Text(
                                            'Are you sure you want to delete this memory?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                await settingsProvider.deleteMemory(memory.id!);
                                                if (context.mounted) {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Memory deleted'),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text(
                                                'Delete',
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
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final settingsProvider =
              Provider.of<SettingsProvider>(context, listen: false);
          if (settingsProvider.getTotalMemoryCharacters() >= SettingsProvider.maxTotalMemoryCharacters) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Memory limit reached. Delete some memories first.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          _showAddMemoryDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Memory'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
