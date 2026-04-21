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
          // Settings / logout icon
          IconButton(
            icon: const Icon(Icons.casino_outlined),
            tooltip: 'Password Generator',
            onPressed: () => Navigator.pushNamed(context, '/generator'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),

      // ── Body ──────────────────────────────────────────────────────────
      body: Column(
        children: [

          // ── Search bar ────────────────────────────────────────────────
          Container(
            color: const Color(0xFF1E3A5F),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by site, username, or category...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 14),
                prefixIcon: Icon(
                  Icons.search, color: Colors.white.withOpacity(0.7)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              ),
            ),
          ),

          // ── StreamBuilder: live vault list ────────────────────────────
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

                // ── The actual list ───────────────────────────────────
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
                                onTap: () => _showEntryPreview(context, entries[i]),
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

      // ── FAB: navigate to Add screen ───────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        backgroundColor: const Color(0xFF1E3A5F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ── Quick preview bottom sheet (tapping a card) ───────────────────────
  // Temporary until the full detail screen is built on Day 10
  void _showEntryPreview(BuildContext context, PasswordEntry entry) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(entry.siteName,
              style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(entry.username,
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text('Category: ${entry.category}',
              style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text('Strength: ${entry.strength}',
              style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text('Added: ${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}',
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Options menu (top right) ──────────────────────────────────────────
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
