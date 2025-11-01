import 'dart:convert';
import 'package:http/http.dart' as http;

class E2bService {
  static const String baseUrl = 'https://api.e2b.dev';
  final String? apiKey;

  E2bService({this.apiKey});

  /// Create a new sandbox for code execution
  Future<Map<String, dynamic>> createSandbox({String template = 'base'}) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('E2B API key not configured');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sandboxes'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey!,
        },
        body: jsonEncode({
          'template': template,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create sandbox: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create sandbox: $e');
    }
  }

  /// Execute Python code in a sandbox
  Future<Map<String, dynamic>> executePythonCode({
    required String sandboxId,
    required String code,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('E2B API key not configured');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sandboxes/$sandboxId/code/execute'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey!,
        },
        body: jsonEncode({
          'code': code,
          'language': 'python',
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to execute code: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to execute code: $e');
    }
  }

  /// Close a sandbox
  Future<void> closeSandbox(String sandboxId) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('E2B API key not configured');
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/sandboxes/$sandboxId'),
        headers: {
          'X-API-Key': apiKey!,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to close sandbox: ${response.statusCode}');
      }
    } catch (e) {
      // Silently fail on close errors
    }
  }

  /// Upload a file to the sandbox
  Future<void> uploadFile({
    required String sandboxId,
    required String path,
    required String content,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('E2B API key not configured');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sandboxes/$sandboxId/filesystem/write'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey!,
        },
        body: jsonEncode({
          'path': path,
          'content': content,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to upload file: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Read a file from the sandbox
  Future<String> readFile({
    required String sandboxId,
    required String path,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('E2B API key not configured');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sandboxes/$sandboxId/filesystem/read?path=$path'),
        headers: {
          'X-API-Key': apiKey!,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'] as String;
      } else {
        throw Exception('Failed to read file: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }

  /// List files in a directory
  Future<List<String>> listFiles({
    required String sandboxId,
    required String path,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('E2B API key not configured');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sandboxes/$sandboxId/filesystem/list?path=$path'),
        headers: {
          'X-API-Key': apiKey!,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['files'] ?? []);
      } else {
        throw Exception('Failed to list files: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  /// Install a package in the sandbox
  Future<Map<String, dynamic>> installPackage({
    required String sandboxId,
    required String packageName,
    String packageManager = 'pip',
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('E2B API key not configured');
    }

    String command;
    if (packageManager == 'pip') {
      command = 'pip install $packageName';
    } else if (packageManager == 'npm') {
      command = 'npm install $packageName';
    } else {
      command = '$packageManager install $packageName';
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sandboxes/$sandboxId/commands/run'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey!,
        },
        body: jsonEncode({
          'command': command,
        }),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to install package: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to install package: $e');
    }
  }
}
