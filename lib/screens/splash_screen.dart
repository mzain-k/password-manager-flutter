import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait 2 seconds then decide where to navigate
    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Already logged in — go straight to vault
      Navigator.pushReplacementNamed(context, '/scaffold');
    } else {
      // Not logged in — show login screen
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon inside a rounded box
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.shield_rounded,
                size: 56, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text('VaultGuard',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold,
                color: Colors.white, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Text('Secure Password Manager',
              style: TextStyle(fontSize: 14,
                color: Colors.white.withOpacity(0.7))),
            const SizedBox(height: 48),
            SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}