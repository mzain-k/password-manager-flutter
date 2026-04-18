import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/password_entry.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Saves a dummy entry — lets you test that Firestore is wired up correctly
  Future<void> _saveTestEntry(BuildContext context) async {
    final entry = PasswordEntry(
      id:                '',     // empty — Firestore will assign this
      siteName:          'Test Site',
      username:          'testuser@example.com',
      encryptedPassword: 'PLACEHOLDER_ENCRYPTED_TEXT',
      strength:          'Strong',
      isBreached:        false,
      createdAt:         DateTime.now(),
      updatedAt:         DateTime.now(),
    );
    try {
      await FirestoreService.addPassword(entry);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test entry saved! Check Firestore Console.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault — Day 3 Test'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: const Color(0xFFE8F4FD),
            child: Text(
              'Logged in as: ${user?.email}\nTap the button below to test Firestore.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF1A5276)),
            ),
          ),

          // Test button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => _saveTestEntry(context),
              icon: const Icon(Icons.add),
              label: const Text('Save Test Entry to Firestore'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
                foregroundColor: Colors.white,
              ),
            ),
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Saved entries (live from Firestore):',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),

          // Live stream of Firestore data
          Expanded(
            child: StreamBuilder<List<PasswordEntry>>(
              stream: FirestoreService.getPasswordsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final entries = snapshot.data ?? [];
                if (entries.isEmpty) {
                  return const Center(
                    child: Text('No entries yet. Tap the button above.',
                      style: TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (ctx, i) {
                    final e = entries[i];
                    return ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: Text(e.siteName),
                      subtitle: Text(e.username),
                      trailing: Text(e.strength,
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}