import 'package:flutter/material.dart';
import '../models/mcp_server.dart';

class McpServersScreen extends StatefulWidget {
  const McpServersScreen({super.key});

  @override
  State<McpServersScreen> createState() => _McpServersScreenState();
}

class _McpServersScreenState extends State<McpServersScreen> {
  final List<McpServer> _servers = [];

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _loadServers() async {
    // TODO: Load from database
    setState(() {
      // Example servers
    });
  }

  void _showAddServerDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final apiKeyController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add MCP Server'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Server Name',
                  hintText: 'e.g., My MCP Server',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'e.g., https://mcp.example.com',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key (Optional)',
                  hintText: 'Enter API key if required',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief description of the server',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  urlController.text.isNotEmpty) {
                final server = McpServer(
                  name: nameController.text,
                  url: urlController.text,
                  apiKey: apiKeyController.text.isEmpty
                      ? null
                      : apiKeyController.text,
                  description: descriptionController.text,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                // TODO: Save to database
                setState(() {
                  _servers.add(server);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP Servers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddServerDialog,
            tooltip: 'Add MCP Server',
          ),
        ],
      ),
      body: _servers.isEmpty
          ? Center(
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
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'MCP (Model Context Protocol) servers provide additional context and tools for AI models',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddServerDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Server'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _servers.length,
              itemBuilder: (context, index) {
                final server = _servers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: server.isEnabled
                          ? Colors.green
                          : Colors.grey,
                      child: Icon(
                        server.isEnabled ? Icons.check : Icons.close,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(server.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(server.url),
                        if (server.description.isNotEmpty)
                          Text(
                            server.description,
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: ListTile(
                            leading: Icon(
                              server.isEnabled
                                  ? Icons.toggle_on
                                  : Icons.toggle_off,
                            ),
                            title: Text(
                              server.isEnabled ? 'Disable' : 'Enable',
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _servers[index] = server.copyWith(
                                isEnabled: !server.isEnabled,
                              );
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: const ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                          ),
                          onTap: () {
                            // TODO: Implement edit
                          },
                        ),
                        PopupMenuItem(
                          child: const ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _servers.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
