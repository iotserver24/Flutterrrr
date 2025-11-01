import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:intl/intl.dart';
import '../models/message.dart';
import 'code_block.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isStreaming;

  const MessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == 'user';
    final timeFormat = DateFormat('HH:mm');

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF2563EB) : const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isUser ? '👤 ' : '🤖 ',
                  style: const TextStyle(fontSize: 16),
                ),
                if (widget.message.webSearchUsed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '🌐 Web Search',
                      style: TextStyle(fontSize: 10, color: Colors.green),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            if (isUser) ...[
              // Show image if present
              if (widget.message.imagePath != null && widget.message.imagePath!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(widget.message.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.black26,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.broken_image, color: Colors.white70, size: 16),
                              SizedBox(width: 4),
                              Text('Image unavailable', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              Text(
                widget.message.content,
                style: const TextStyle(color: Colors.white),
              ),
            ]
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: MarkdownBody(
                      data: widget.message.content,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(color: Colors.white),
                        h1: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        h2: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        h3: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        listBullet: const TextStyle(color: Colors.white),
                        tableBody: const TextStyle(color: Colors.white),
                        code: TextStyle(
                          backgroundColor: Colors.black.withOpacity(0.3),
                          color: Colors.green,
                          fontFamily: 'monospace',
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      builders: {
                        'code': CodeBlockBuilder(),
                      },
                      extensionSet: md.ExtensionSet.gitHubFlavored,
                    ),
                  ),
                  // Add blinking cursor for streaming messages
                  if (widget.isStreaming)
                    AnimatedBuilder(
                      animation: _cursorController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _cursorController.value,
                          child: Container(
                            margin: const EdgeInsets.only(left: 2, top: 2),
                            width: 8,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isStreaming)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    ),
                  )
                else
                  Text(
                    timeFormat.format(widget.message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                if (!widget.isStreaming) const SizedBox(width: 8),
                if (!widget.isStreaming)
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.message.content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message copied to clipboard'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy,
                      size: 14,
                      color: Colors.white.withOpacity(0.6),
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

// Custom markdown builder for code blocks
class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String textContent = element.textContent;
    
    // Extract language from info string if available
    String? language;
    if (element.attributes['class'] != null) {
      final classes = element.attributes['class']!.split(' ');
      for (var cls in classes) {
        if (cls.startsWith('language-')) {
          language = cls.substring(9); // Remove 'language-' prefix
          break;
        }
      }
    }

    return CodeBlock(
      code: textContent,
      language: language,
    );
  }
}
