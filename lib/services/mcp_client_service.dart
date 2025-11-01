import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mcp_config.dart';
import '../services/mcp_config_service.dart';

/// MCP Tool definition
class McpTool {
  final String name;
  final String description;
  final Map<String, dynamic>? inputSchema;

  McpTool({
    required this.name,
    required this.description,
    this.inputSchema,
  });

  factory McpTool.fromJson(Map<String, dynamic> json) {
    return McpTool(
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      inputSchema: json['inputSchema'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      if (inputSchema != null) 'inputSchema': inputSchema,
    };
  }
}

/// MCP Resource definition
class McpResource {
  final String uri;
  final String name;
  final String? description;
  final String? mimeType;

  McpResource({
    required this.uri,
    required this.name,
    this.description,
    this.mimeType,
  });

  factory McpResource.fromJson(Map<String, dynamic> json) {
    return McpResource(
      uri: json['uri'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      mimeType: json['mimeType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uri': uri,
      'name': name,
      if (description != null) 'description': description,
      if (mimeType != null) 'mimeType': mimeType,
    };
  }
}

/// MCP Server connection info
class McpServerConnection {
  final String name;
  final McpServerConfig config;
  final List<McpTool> tools;
  final List<McpResource> resources;
  bool isConnected;

  McpServerConnection({
    required this.name,
    required this.config,
    this.tools = const [],
    this.resources = const [],
    this.isConnected = false,
  });
}

/// MCP Client Service for connecting to MCP servers
class McpClientService {
  final McpConfigService _configService = McpConfigService();
  final Map<String, McpServerConnection> _connections = {};
  bool _initialized = false;

  /// Initialize and connect to enabled MCP servers
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final config = await _configService.loadConfiguration();
      
      // Connect to enabled servers
      for (var entry in config.mcpServers.entries) {
        final serverName = entry.key;
        final serverConfig = entry.value;

        if (serverConfig.isEnabled) {
          await _connectToServer(serverName, serverConfig);
        }
      }

      _initialized = true;
    } catch (e) {
      print('Error initializing MCP clients: $e');
    }
  }

  /// Connect to a single MCP server
  Future<void> _connectToServer(String serverName, McpServerConfig config) async {
    try {
      if (config.url != null && config.url!.isNotEmpty) {
        // URL-based MCP server
        await _connectToUrlServer(serverName, config);
      } else if (config.command.isNotEmpty) {
        // Command-based MCP server (would require process spawning)
        // For now, we'll skip these or show a message
        print('Command-based MCP servers require process spawning, not yet implemented for: $serverName');
        return;
      }
    } catch (e) {
      print('Error connecting to MCP server $serverName: $e');
    }
  }

  /// Connect to a URL-based MCP server
  Future<void> _connectToUrlServer(String serverName, McpServerConfig config) async {
    try {
      final url = config.url!;
      
      // Try to initialize MCP connection
      // For URL-based servers, we typically need to:
      // 1. Send initialize request
      // 2. Get capabilities (tools, resources)
      
      final connection = McpServerConnection(
        name: serverName,
        config: config,
        tools: [],
        resources: [],
        isConnected: false,
      );

      // Try to fetch tools and resources from the MCP server
      // This depends on the MCP server implementation
      // Many URL-based servers expose tools via HTTP endpoints
      
      try {
        // Attempt to get server info (this is server-specific)
        final headers = <String, String>{
          'Content-Type': 'application/json',
          ...?config.headers,
        };

        // Some MCP servers expose /tools endpoint
        try {
          final toolsUrl = url.endsWith('/') ? '${url}tools' : '$url/tools';
          final toolsResponse = await http.get(
            Uri.parse(toolsUrl),
            headers: headers,
          ).timeout(const Duration(seconds: 5));

          if (toolsResponse.statusCode == 200) {
            final toolsData = jsonDecode(toolsResponse.body);
            if (toolsData is List) {
              final tools = toolsData
                  .map((item) => McpTool.fromJson(item as Map<String, dynamic>))
                  .toList();
              connection.tools.addAll(tools);
            } else if (toolsData is Map && toolsData['tools'] != null) {
              final toolsList = toolsData['tools'] as List;
              final tools = toolsList
                  .map((item) => McpTool.fromJson(item as Map<String, dynamic>))
                  .toList();
              connection.tools.addAll(tools);
            }
          }
        } catch (e) {
          // Tools endpoint might not exist, that's okay
          print('Could not fetch tools from $serverName: $e');
        }

        // Some MCP servers expose /resources endpoint
        try {
          final resourcesUrl = url.endsWith('/') ? '${url}resources' : '$url/resources';
          final resourcesResponse = await http.get(
            Uri.parse(resourcesUrl),
            headers: headers,
          ).timeout(const Duration(seconds: 5));

          if (resourcesResponse.statusCode == 200) {
            final resourcesData = jsonDecode(resourcesResponse.body);
            if (resourcesData is List) {
              final resources = resourcesData
                  .map((item) => McpResource.fromJson(item as Map<String, dynamic>))
                  .toList();
              connection.resources.addAll(resources);
            } else if (resourcesData is Map && resourcesData['resources'] != null) {
              final resourcesList = resourcesData['resources'] as List;
              final resources = resourcesList
                  .map((item) => McpResource.fromJson(item as Map<String, dynamic>))
                  .toList();
              connection.resources.addAll(resources);
            }
          }
        } catch (e) {
          // Resources endpoint might not exist, that's okay
          print('Could not fetch resources from $serverName: $e');
        }

        connection.isConnected = true;
        _connections[serverName] = connection;
        print('Connected to MCP server: $serverName (${connection.tools.length} tools, ${connection.resources.length} resources)');
      } catch (e) {
        print('Error fetching MCP server info for $serverName: $e');
        // Still mark as connected if the URL is valid (some servers might not expose these endpoints)
        connection.isConnected = true;
        _connections[serverName] = connection;
      }
    } catch (e) {
      print('Error connecting to URL-based MCP server $serverName: $e');
    }
  }

  /// Get all available tools from all connected MCP servers
  List<McpTool> getAllTools() {
    final allTools = <McpTool>[];
    for (var connection in _connections.values) {
      if (connection.isConnected) {
        allTools.addAll(connection.tools);
      }
    }
    return allTools;
  }

  /// Get all available resources from all connected MCP servers
  List<McpResource> getAllResources() {
    final allResources = <McpResource>[];
    for (var connection in _connections.values) {
      if (connection.isConnected) {
        allResources.addAll(connection.resources);
      }
    }
    return allResources;
  }

  /// Call an MCP tool
  Future<Map<String, dynamic>> callTool(String toolName, Map<String, dynamic>? arguments) async {
    // Find which server has this tool
    for (var connection in _connections.values) {
      final tool = connection.tools.firstWhere(
        (t) => t.name == toolName,
        orElse: () => McpTool(name: '', description: ''),
      );

      if (tool.name.isNotEmpty) {
        return await _executeToolOnServer(connection, tool, arguments);
      }
    }

    throw Exception('Tool $toolName not found in any connected MCP server');
  }

  /// Execute a tool on a specific server
  Future<Map<String, dynamic>> _executeToolOnServer(
    McpServerConnection connection,
    McpTool tool,
    Map<String, dynamic>? arguments,
  ) async {
    try {
      if (connection.config.url != null && connection.config.url!.isNotEmpty) {
        // URL-based tool execution
        final url = connection.config.url!;
        final toolUrl = url.endsWith('/') 
            ? '${url}call/${tool.name}' 
            : '$url/call/${tool.name}';

        final headers = <String, String>{
          'Content-Type': 'application/json',
          ...?connection.config.headers,
        };

        final response = await http.post(
          Uri.parse(toolUrl),
          headers: headers,
          body: jsonEncode({
            'arguments': arguments ?? {},
          }),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } else {
          throw Exception('Tool execution failed: ${response.statusCode}');
        }
      } else {
        throw Exception('Command-based tool execution not yet implemented');
      }
    } catch (e) {
      throw Exception('Error executing tool ${tool.name}: $e');
    }
  }

  /// Get MCP context to include in API requests
  /// Returns a formatted string describing available tools and resources
  String getMcpContext() {
    final tools = getAllTools();
    final resources = getAllResources();

    if (tools.isEmpty && resources.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    buffer.writeln('Available MCP Tools and Resources:');

    if (tools.isNotEmpty) {
      buffer.writeln('\nTools:');
      for (var tool in tools) {
        buffer.writeln('- ${tool.name}: ${tool.description}');
      }
    }

    if (resources.isNotEmpty) {
      buffer.writeln('\nResources:');
      for (var resource in resources) {
        buffer.writeln('- ${resource.name} (${resource.uri})');
        if (resource.description != null) {
          buffer.writeln('  ${resource.description}');
        }
      }
    }

    return buffer.toString();
  }

  /// Reload MCP configuration and reconnect
  Future<void> reload() async {
    _connections.clear();
    _initialized = false;
    await initialize();
  }

  /// Get connection status for all servers
  Map<String, bool> getConnectionStatus() {
    return {
      for (var entry in _connections.entries)
        entry.key: entry.value.isConnected,
    };
  }

  /// Get tools count by server
  Map<String, int> getToolsCount() {
    return {
      for (var entry in _connections.entries)
        entry.key: entry.value.tools.length,
    };
  }
}

