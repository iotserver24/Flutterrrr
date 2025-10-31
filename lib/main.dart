import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/chat_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
          create: (_) => ChatProvider(apiKey: null),
          update: (_, settings, previous) =>
              previous ?? ChatProvider(apiKey: settings.apiKey),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Xibe Chat',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const ChatScreen(),
          );
        },
      ),
    );
  }
}
