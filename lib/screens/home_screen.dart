import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/password_entry.dart';
import '../widgets/password_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  // Filters entries in memory based on search query
  // Checks site name, username, and category
  List<PasswordEntry> _filterEntries(List<PasswordEntry> all) {
    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    return all.where((e) {
      return e.siteName.toLowerCase().contains(q) ||
             e.username.toLowerCase().contains(q) ||
             e.category.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'VaultGuard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),

      // ── Body 
      body: Column(
        children: [

          // ── Search bar 
          Container(
            color: const Color(0xFF1E3A5F),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by site, username, or category...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                prefixIcon: Icon(
                  Icons.search, color: Colors.white.withValues(alpha: 0.7)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              ),
            ),
          ),

          // ── StreamBuilder: live vault list 
          Expanded(
            child: StreamBuilder<List<PasswordEntry>>(
              stream: FirestoreService.getPasswordsStream(),
              builder: (context, snapshot) {

                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1E3A5F)));
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text('Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  );
                }

                final allEntries = snapshot.data ?? [];
                final entries = _filterEntries(allEntries);

                // Empty state — no passwords saved yet
                if (allEntries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline,
                          size: 72,
                          color: Colors.grey.shade300),
                        const SizedBox(height: 20),
                        Text(
                          'Your vault is empty',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first password',
                          style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  );
                }

                // Search returned no results
                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                          size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('No results for "$_searchQuery"',
                          style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }

                // ── The actual list 
                return Column(
                  children: [
                    // Entry count header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Text(
                            '${entries.length} password${entries.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (ctx, i) {
                            return Dismissible(
                              key: Key(entries[i].id), // unique key required by Dismissible
                              direction: DismissDirection.endToStart, // swipe left to delete

                              // Red background shown while swiping
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: const Color(0xFFB71C1C),
                                child: const Icon(Icons.delete_outline,
                                  color: Colors.white, size: 28),
                              ),

                              // Called when the swipe is complete
                              onDismissed: (direction) async {
                                final deletedEntry = entries[i];
                                await FirestoreService.deletePassword(deletedEntry.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${deletedEntry.siteName} deleted'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },

                              // The actual card
                              child: PasswordCard(
                                entry: entries[i],
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/detail',
                                  arguments: entries[i], // pass the full entry object
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      // ── FAB: navigate to Add screen 
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        backgroundColor: const Color(0xFF1E3A5F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }


  // ── Options menu (top right) 
  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout',
              style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(ctx);
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
