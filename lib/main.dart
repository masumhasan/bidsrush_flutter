import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/video_stream_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Disable Google Fonts file caching on web to avoid path_provider issues
  if (kIsWeb) {
    GoogleFonts.config.allowRuntimeFetching = true;
  }
  
  // Set up error handling
  FlutterError.onError = (details) {
    debugPrint('Flutter error: ${details.exception}');
  };
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => VideoStreamProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'BidsRush Live',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: auth.isLoading
                ? const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  )
                : auth.isAuthenticated
                ? const HomeScreen()
                : const SignInScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/sign-in': (context) => const SignInScreen(),
            },
          );
        },
      ),
    );
  }
}
