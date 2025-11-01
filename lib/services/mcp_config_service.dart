import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/mcp_config.dart';

class McpConfigService {
  static const String _configFileName = 'mcp_config.json';
  
  Future<String> get _configFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, _configFileName);
  }

  // Load configuration from file
  Future<McpConfiguration> loadConfiguration() async {
    try {
      final filePath = await _configFilePath;
      final file = File(filePath);
      
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        return McpConfiguration.fromJsonString(jsonString);
      }
    } catch (e) {
      developer.log('Error loading MCP configuration: $e', name: 'McpConfigService');
    }
    
    // Return default configuration if file doesn't exist or error occurs
    return McpConfiguration.defaultConfig();
  }

  // Save configuration to file
  Future<bool> saveConfiguration(McpConfiguration config) async {
    try {
      final filePath = await _configFilePath;
      final file = File(filePath);
      
      // Pretty print JSON for readability
      const encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(config.toJson());
      
      await file.writeAsString(prettyJson);
      return true;
    } catch (e) {
      developer.log('Error saving MCP configuration: $e', name: 'McpConfigService');
      return false;
    }
  }

  // Add or update a server in the configuration
  Future<bool> addOrUpdateServer(String name, McpServerConfig config) async {
    try {
      final currentConfig = await loadConfiguration();
      currentConfig.mcpServers[name] = config;
      return await saveConfiguration(currentConfig);
    } catch (e) {
      developer.log('Error adding/updating MCP server: $e', name: 'McpConfigService');
      return false;
    }
  }

  // Remove a server from the configuration
  Future<bool> removeServer(String name) async {
    try {
      final currentConfig = await loadConfiguration();
      currentConfig.mcpServers.remove(name);
      return await saveConfiguration(currentConfig);
    } catch (e) {
      developer.log('Error removing MCP server: $e', name: 'McpConfigService');
      return false;
    }
  }

  // Get configuration file path for direct access
  Future<String> getConfigFilePath() async {
    return await _configFilePath;
  }

  // Export configuration as JSON string
  Future<String> exportConfiguration() async {
    final config = await loadConfiguration();
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(config.toJson());
  }

  // Import configuration from JSON string
  Future<bool> importConfiguration(String jsonString) async {
    try {
      final config = McpConfiguration.fromJsonString(jsonString);
      return await saveConfiguration(config);
    } catch (e) {
      developer.log('Error importing MCP configuration: $e', name: 'McpConfigService');
      return false;
    }
  }

  // Initialize with default configuration if none exists
  Future<void> initializeDefaultConfig() async {
    try {
      final filePath = await _configFilePath;
      final file = File(filePath);
      
      if (!await file.exists()) {
        final defaultConfig = McpConfiguration.defaultConfig();
        await saveConfiguration(defaultConfig);
      }
    } catch (e) {
      developer.log('Error initializing default MCP configuration: $e', name: 'McpConfigService');
    }
  }
}
