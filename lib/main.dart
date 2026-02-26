import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/call_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/social_provider.dart';
import 'providers/random_match_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/call/call_screen.dart';
import 'core/socket/socket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request notification permission once at startup (Android 13+)
  // Once granted, it's stored permanently by the OS
  await Permission.notification.request();

  // Shared socket instance used by both ChatProvider and CallProvider
  final socketService = SocketService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (_) => ChatProvider(socketService),
          update: (_, auth, chat) {
            if (auth.isAuthenticated && auth.user != null) {
              chat!.init(auth.token!, auth.user!.id);
            }
            return chat!;
          },
        ),
        ChangeNotifierProvider(create: (_) => CallProvider(socketService)),
        ChangeNotifierProvider(create: (_) => SocialProvider(socketService)),
        ChangeNotifierProxyProvider<CallProvider, RandomMatchProvider>(
          create: (context) => RandomMatchProvider(socketService, Provider.of<CallProvider>(context, listen: false)),
          update: (_, call, random) => random!..init(),
        ),
      ],
      child: const ChatApp(),
    ),
  );
}

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App resumed — reconnecting socket');
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated && auth.user != null) {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.init(auth.token!, auth.user!.id);
        chatProvider.refreshFromServer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Ping Crood',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData.copyWith(
            textTheme: GoogleFonts.poppinsTextTheme(
              themeProvider.isDarkMode ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
            ),
          ),
          builder: (context, child) {
            // CallOverlay wraps the entire app so it's always visible
            return Stack(
              children: [
                child ?? const SizedBox.shrink(),
                const CallOverlay(),
              ],
            );
          },
          home: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.isAuthenticated) {
                // Initialize matchmaking when authenticated
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Provider.of<CallProvider>(context, listen: false).init();
                  Provider.of<RandomMatchProvider>(context, listen: false).init();
                });
                return const MainScreen();
              }
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}
