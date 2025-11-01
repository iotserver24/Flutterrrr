import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ChatInput extends StatefulWidget {
  final Function(String, {String? imageBase64, String? imagePath, bool webSearch}) onSendMessage;
  final bool isLoading;
  final bool supportsVision;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    this.isLoading = false,
    this.supportsVision = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  XFile? _selectedImage;
  String? _imageBase64;
  bool _webSearchEnabled = false;
  
  bool get _isDesktop {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        // Read the image file and convert to base64
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        // Read the image file and convert to base64
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to take photo: $e')),
        );
      }
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            if (widget.supportsVision) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Image Options',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              const Divider(),
            ],
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'MCP Connections',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Manage MCP Servers'),
              subtitle: const Text('Configure Model Context Protocol servers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageBase64 = null;
    });
  }

  void _sendMessage() {
    if ((_hasText || _selectedImage != null) && !widget.isLoading) {
      widget.onSendMessage(
        _controller.text.trim(),
        imageBase64: _imageBase64,
        imagePath: _selectedImage?.path,
        webSearch: _webSearchEnabled,
      );
      _controller.clear();
      setState(() {
        _selectedImage = null;
        _imageBase64 = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image preview
            if (_selectedImage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_selectedImage!.path),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Image attached',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: _removeImage,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            // Input row
            Row(
              children: [
                // Plus button for attachments and MCP connections
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white70),
                    onPressed: widget.isLoading ? null : _showAttachmentOptions,
                    tooltip: 'Attachments & Options',
                  ),
                ),
                // Web search toggle button - commented out as per requirement
                // Container(
                //   margin: const EdgeInsets.only(right: 8),
                //   decoration: BoxDecoration(
                //     color: _webSearchEnabled 
                //         ? const Color(0xFF3B82F6).withOpacity(0.3)
                //         : const Color(0xFF1A1A1A),
                //     shape: BoxShape.circle,
                //   ),
                //   child: IconButton(
                //     icon: Icon(
                //       Icons.search,
                //       color: _webSearchEnabled 
                //           ? const Color(0xFF3B82F6)
                //           : Colors.white70,
                //     ),
                //     onPressed: widget.isLoading ? null : () {
                //       setState(() {
                //         _webSearchEnabled = !_webSearchEnabled;
                //       });
                //     },
                //     tooltip: _webSearchEnabled 
                //         ? 'Web search enabled' 
                //         : 'Enable web search',
                //   ),
                // ),
                Expanded(
                  child: RawKeyboardListener(
                    focusNode: FocusNode(), // Temporary focus node for keyboard listener
                    onKey: (RawKeyEvent event) {
                      // On desktop: Enter sends, Ctrl+Enter adds new line
                      if (_isDesktop && event is RawKeyDownEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.enter) {
                          if (!event.isControlPressed) {
                            // Enter without Ctrl: send message
                            _sendMessage();
                          }
                          // Ctrl+Enter: allow default behavior (new line)
                        }
                      }
                    },
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: !widget.isLoading,
                      maxLines: null,
                      textInputAction: _isDesktop ? TextInputAction.newline : TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: 'Type something',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) {
                        if (!_isDesktop) {
                          _sendMessage();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: (_hasText || _selectedImage != null) && !widget.isLoading
                        ? const Color(0xFF3B82F6)
                        : Colors.grey.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: (_hasText || _selectedImage != null) && !widget.isLoading ? _sendMessage : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
