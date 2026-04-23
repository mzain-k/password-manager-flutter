import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Importing all screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_password_screen.dart';
import 'screens/generator_screeen.dart';
import 'screens/breach_check_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // must be first line
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaultGuard',
      debugShowCheckedModeBanner: false, // removes the red DEBUG banner

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A5F)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // App always starts at splash screen
      initialRoute: '/splash',

      // Named routes — add every new screen here as you build them
      routes: {
        '/splash': (ctx) => const SplashScreen(),
        '/login': (ctx) => const LoginScreen(),
        '/signup': (ctx) => const SignupScreen(),
        '/home': (ctx) => const HomeScreen(),
        '/add': (ctx) => const AddPasswordScreen(),
        '/generator': (ctx) => const GeneratorScreen(),
        '/breach': (ctx) => const BreachCheckScreen(),
      },
    );
  }
}