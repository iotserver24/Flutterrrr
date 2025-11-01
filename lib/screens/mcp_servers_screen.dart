import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mcp_config.dart';
import '../services/mcp_config_service.dart';

class McpServersScreen extends StatefulWidget {
  const McpServersScreen({super.key});

  @override
  State<McpServersScreen> createState() => _McpServersScreenState();
}

class _McpServersScreenState extends State<McpServersScreen> {
  final McpConfigService _configService = McpConfigService();
  Map<String, McpServerConfig> _servers = {};
  Map<String, bool> _serverStates = {}; // Track on/off state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _loadServers() async {
    setState(() {
      _isLoading = true;
    });
    
    final config = await _configService.loadConfiguration();
    setState(() {
      _servers = config.mcpServers;
      // Initialize all servers as enabled by default
      _serverStates = {for (var key in _servers.keys) key: true};
      _isLoading = false;
    });
  }

  void _showAddServerDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final commandController = TextEditingController();
    final argsController = TextEditingController();
    bool useUrl = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Add MCP Server',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Server Name',
                    hintText: 'e.g., my-mcp-server',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Use URL-based server'),
                  value: useUrl,
                  onChanged: (value) {
                    setDialogState(() {
                      useUrl = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                if (useUrl) ...[
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      labelText: 'Server URL',
                      hintText: 'e.g., https://mcp.example.com',
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: commandController,
                    decoration: const InputDecoration(
                      labelText: 'Command',
                      hintText: 'e.g., npx',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: argsController,
                    decoration: const InputDecoration(
                      labelText: 'Arguments (comma-separated)',
                      hintText: 'e.g., -y, @browsermcp/mcp@latest',
                    ),
                    maxLines: 3,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final config = useUrl
                      ? McpServerConfig(
                          url: urlController.text,
                          headers: {},
                        )
                      : McpServerConfig(
                          command: commandController.text,
                          args: argsController.text
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList(),
                        );
                  
                  await _configService.addOrUpdateServer(nameController.text, config);
                  await _loadServers();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Server added successfully')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportConfiguration() async {
    try {
      final jsonString = await _configService.exportConfiguration();
      await Clipboard.setData(ClipboardData(text: jsonString));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration copied to clipboard')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting configuration: $e')),
        );
      }
    }
  }

  Future<void> _showConfigFileLocation() async {
    final filePath = await _configService.getConfigFilePath();
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Configuration File Location'),
          content: SelectableText(
            filePath,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: filePath));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Path copied to clipboard')),
                  );
                }
              },
              child: const Text('Copy Path'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP Servers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _showConfigFileLocation,
            tooltip: 'Show Config File Location',
          ),
          IconButton(
            icon: const Icon(Icons.file_copy),
            onPressed: _exportConfiguration,
            tooltip: 'Export Configuration',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddServerDialog,
            tooltip: 'Add MCP Server',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _servers.isEmpty
          ? Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.dns_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No MCP Servers configured',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'MCP (Model Context Protocol) servers provide additional context and tools for AI models',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _showAddServerDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Server'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          : ListView.builder(
              itemCount: _servers.length,
              itemBuilder: (context, index) {
                final entry = _servers.entries.elementAt(index);
                final serverName = entry.key;
                final serverConfig = entry.value;
                final isEnabled = _serverStates[serverName] ?? true;
                
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: isEnabled
                          ? Colors.green
                          : Colors.grey,
                      child: Icon(
                        isEnabled ? Icons.check_circle : Icons.cancel,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      serverName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      serverConfig.url?.isNotEmpty == true 
                          ? 'URL: ${serverConfig.url}'
                          : 'Command: ${serverConfig.command}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Switch(
                      value: isEnabled,
                      onChanged: (value) {
                        setState(() {
                          _serverStates[serverName] = value;
                        });
                      },
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (serverConfig.url?.isNotEmpty == true) ...[
                              _buildDetailRow('URL', serverConfig.url!),
                              if (serverConfig.headers?.isNotEmpty == true)
                                _buildDetailRow('Headers', serverConfig.headers.toString()),
                            ] else ...[
                              _buildDetailRow('Command', serverConfig.command),
                              if (serverConfig.args.isNotEmpty)
                                _buildDetailRow('Arguments', serverConfig.args.join(', ')),
                              if (serverConfig.env?.isNotEmpty == true)
                                _buildDetailRow('Environment', 
                                    serverConfig.env!.keys.join(', ')),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Server'),
                                        content: Text(
                                          'Are you sure you want to delete "$serverName"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    
                                    if (confirm == true) {
                                      await _configService.removeServer(serverName);
                                      await _loadServers();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Server deleted successfully'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
