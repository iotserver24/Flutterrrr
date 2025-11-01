import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class CodeBlock extends StatefulWidget {
  final String code;
  final String? language;

  const CodeBlock({
    super.key,
    required this.code,
    this.language,
  });

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  bool _isRunning = false;
  String? _output;
  String? _error;

  // Constants for timeouts
  static const int _sandboxCreateTimeoutSeconds = 10;
  static const int _codeExecutionTimeoutSeconds = 65;
  static const int _sandboxCleanupTimeoutSeconds = 5;
  static const int _sandboxLifetimeSeconds = 300;

  bool get _canRun {
    final lang = widget.language?.toLowerCase();
    return lang == 'python' || 
           lang == 'javascript' || 
           lang == 'js' || 
           lang == 'jsx' ||
           lang == 'typescript' ||
           lang == 'ts' ||
           lang == 'tsx' ||
           lang == 'react';
  }

  String get _displayLanguage {
    final lang = widget.language?.toLowerCase() ?? '';
    if (lang == 'jsx' || lang == 'tsx' || lang == 'react') return 'React';
    if (lang == 'js' || lang == 'javascript') return 'JavaScript';
    if (lang == 'ts' || lang == 'typescript') return 'TypeScript';
    if (lang == 'python' || lang == 'py') return 'Python';
    return widget.language ?? 'Code';
  }

  Future<void> _runCode() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final e2bApiKey = settingsProvider.e2bApiKey;

    if (e2bApiKey == null || e2bApiKey.isEmpty) {
      setState(() {
        _error = 'E2B API key not configured. Please add it in Settings.';
      });
      return;
    }

    setState(() {
      _isRunning = true;
      _output = null;
      _error = null;
    });

    try {
      // Determine the sandbox template based on language
      String template = 'base';
      final lang = widget.language?.toLowerCase() ?? '';
      
      if (lang == 'python' || lang == 'py') {
        template = 'Python3';
      } else if (lang == 'jsx' || lang == 'tsx' || lang == 'react') {
        template = 'Node';
      } else if (lang == 'javascript' || lang == 'js' || lang == 'typescript' || lang == 'ts') {
        template = 'Node';
      }

      // Create sandbox
      final createResponse = await http.post(
        Uri.parse('https://api.e2b.dev/sandboxes'),
        headers: {
          'Authorization': 'Bearer $e2bApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'template': template,
          'timeout': _sandboxLifetimeSeconds,
        }),
      ).timeout(Duration(seconds: _sandboxCreateTimeoutSeconds));

      if (createResponse.statusCode == 401) {
        throw Exception('Invalid E2B API key. Please check your settings.');
      } else if (createResponse.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else if (createResponse.statusCode != 201) {
        throw Exception('Failed to create sandbox (${createResponse.statusCode})');
      }

      final sandboxData = jsonDecode(createResponse.body);
      final sandboxId = sandboxData['sandboxID'] ?? sandboxData['id'];

      if (sandboxId == null) {
        throw Exception('No sandbox ID returned');
      }

      // Execute code - write to file and execute to avoid shell injection
      String command;
      final lang = widget.language?.toLowerCase() ?? '';
      
      if (lang == 'python' || lang == 'py') {
        // Write Python code to file and execute
        command = 'cat > /tmp/code.py << \'EOFMARKER\'\n${widget.code}\nEOFMARKER\n && python3 /tmp/code.py';
      } else {
        // Write JS/Node code to file and execute
        command = 'cat > /tmp/code.js << \'EOFMARKER\'\n${widget.code}\nEOFMARKER\n && node /tmp/code.js';
      }

      final execResponse = await http.post(
        Uri.parse('https://api.e2b.dev/sandboxes/$sandboxId/commands'),
        headers: {
          'Authorization': 'Bearer $e2bApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'command': command,
          'timeout': 60000,
        }),
      ).timeout(Duration(seconds: _codeExecutionTimeoutSeconds));

      if (execResponse.statusCode == 200) {
        final result = jsonDecode(execResponse.body);
        final stdout = result['stdout'] ?? result['output'] ?? '';
        final stderr = result['stderr'] ?? '';
        
        setState(() {
          _output = stdout.isNotEmpty ? stdout : 'Code executed successfully';
          if (stderr.isNotEmpty) {
            _error = stderr;
          }
        });
      } else if (execResponse.statusCode == 408) {
        throw Exception('Code execution timed out after 60 seconds');
      } else {
        throw Exception('Execution failed (${execResponse.statusCode})');
      }

      // Cleanup: delete sandbox
      try {
        await http.delete(
          Uri.parse('https://api.e2b.dev/sandboxes/$sandboxId'),
          headers: {
            'Authorization': 'Bearer $e2bApiKey',
          },
        ).timeout(Duration(seconds: _sandboxCleanupTimeoutSeconds));
      } catch (e) {
        // Ignore cleanup errors - sandbox will auto-expire
      }
    } on FormatException catch (e) {
      setState(() {
        _error = 'Invalid response from E2B API: ${e.message}';
      });
    } on http.ClientException catch (e) {
      setState(() {
        _error = 'Network error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with language and buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Text(
                  _displayLanguage,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (_canRun) ...[
                  IconButton(
                    icon: _isRunning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          )
                        : const Icon(Icons.play_arrow, size: 20),
                    color: Colors.blue,
                    onPressed: _isRunning ? null : _runCode,
                    tooltip: 'Run code in E2B sandbox',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  color: Colors.white70,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  tooltip: 'Copy code',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Code content with syntax highlighting
          Container(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: HighlightView(
                widget.code,
                language: widget.language ?? 'plaintext',
                theme: atomOneDarkTheme,
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
          ),
          // Output/Error display
          if (_output != null || _error != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _error != null
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                border: Border(
                  top: BorderSide(
                    color: _error != null
                        ? Colors.red.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _error != null ? Icons.error_outline : Icons.check_circle_outline,
                        size: 16,
                        color: _error != null ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _error != null ? 'Error' : 'Output',
                        style: TextStyle(
                          color: _error != null ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _error ?? _output ?? '',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
