import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'providers/chat_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/mcp_servers_screen.dart';
import 'screens/splash_screen.dart';
import 'services/mcp_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize MCP configuration with defaults
  final mcpConfigService = McpConfigService();
  await mcpConfigService.initializeDefaultConfig();
  
  // Configure window for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    
    const windowOptions = WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Color(0xFF0D0D0D),
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Xibe Chat',
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  
  runApp(const XibeChatApp());
}

class XibeChatApp extends StatelessWidget {
  const XibeChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<SettingsProvider, ChatProvider>(
          create: (_) => ChatProvider(apiKey: null, systemPrompt: null),
          update: (_, settings, previous) {
            if (previous != null) {
              previous.updateApiKey(settings.apiKey);
              previous.updateSystemPrompt(settings.systemPrompt);
              return previous;
            }
            return ChatProvider(
              apiKey: settings.apiKey,
              systemPrompt: settings.systemPrompt,
            );
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Xibe Chat',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const SplashWrapper(),
            routes: {
              '/settings': (context) => const SettingsScreen(),
              '/mcp-servers': (context) => const McpServersScreen(),
            },
          );
        },
      ),
    );
  }
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onAnimationComplete: () {
          setState(() {
            _showSplash = false;
          });
        },
      );
    }
    return const ChatScreen();
  }
}
