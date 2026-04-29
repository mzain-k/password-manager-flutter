import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/password_entry.dart';
import '../services/firestore_service.dart';
import '../services/encryption_service.dart';

class PasswordDetailScreen extends StatefulWidget {
  const PasswordDetailScreen({super.key});
  @override
  State<PasswordDetailScreen> createState() =>
      _PasswordDetailScreenState();
}

class _PasswordDetailScreenState extends State<PasswordDetailScreen> {
  bool _showPassword = false;
  bool _isDeleting   = false;

  // Copy text to clipboard and show a snackbar
  Future<void> _copy(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copied to clipboard'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    }
  }

  // Show a confirmation dialog before deleting
  Future<void> _confirmDelete(PasswordEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Password'),
        content: Text(
          'Are you sure you want to delete '
          '"${entry.siteName}"? '
          'This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _isDeleting = true);
      await FirestoreService.deletePassword(entry.id);
      if (mounted) Navigator.pop(context); // go back to vault
    }
  }

  // Strength badge colour — same logic as PasswordCard
  Color _strengthColor(String s) {
    switch (s) {
      case 'Very Strong': return const Color(0xFF1B5E20);
      case 'Strong': return const Color(0xFF2E7D32);
      case 'Fair': return const Color(0xFFF57F17);
      case 'Weak': return const Color(0xFFE65100);
      default: return const Color(0xFFB71C1C);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read the PasswordEntry passed from HomeScreen
    final entry = ModalRoute.of(context)!.settings.arguments
        as PasswordEntry;

    // Decrypt the password for display
    final plainPassword =
        EncryptionService.decrypt(entry.encryptedPassword);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(entry.siteName),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () {
              Navigator.pushNamed(
                context, '/add',
                arguments: entry, // pass entry for pre-filling
              );
            },
          ),
          // Delete button
          if (_isDeleting)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: () => _confirmDelete(entry),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Site header card 
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      entry.siteName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(entry.siteName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                        if (entry.siteUrl.isNotEmpty)
                          Text(entry.siteUrl,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Details card 
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                children: [

                  // Username row
                  _buildDetailRow(
                    icon: Icons.person_outline,
                    label: 'Username / Email',
                    value: entry.username,
                    onCopy: () => _copy(
                        entry.username, 'Username'),
                  ),
                  const Divider(height: 1),

                  // Password row with show/hide
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline,
                            color: Color(0xFF1E3A5F),
                            size: 22),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Password',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey)),
                              const SizedBox(height: 3),
                              Text(
                                _showPassword
                                    ? plainPassword
                                    : '•' * plainPassword
                                        .length
                                        .clamp(8, 20),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: _showPassword
                                      ? null
                                      : 'monospace',
                                  fontWeight:
                                      FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        // Show/hide toggle
                        IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons
                                    .visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                            size: 20),
                          onPressed: () => setState(() =>
                              _showPassword =
                                  !_showPassword),
                        ),
                        // Copy password
                        IconButton(
                          icon: const Icon(Icons.copy,
                              color: Color(0xFF1E3A5F),
                              size: 20),
                          onPressed: () =>
                              _copy(plainPassword,
                                  'Password'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Category row
                  _buildDetailRow(
                    icon: Icons.folder_outlined,
                    label: 'Category',
                    value: entry.category,
                    onCopy: null, // no copy for category
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Status card 
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text('Security Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1E3A5F))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Strength badge
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5),
                        decoration: BoxDecoration(
                          color: _strengthColor(entry.strength).withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(20),
                          border: Border.all(
                            color: _strengthColor(
                                entry.strength)),
                        ),
                        child: Text(entry.strength,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _strengthColor(
                                entry.strength))),
                      ),
                      const SizedBox(width: 10),
                      // Breach badge
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5),
                        decoration: BoxDecoration(
                          color: entry.isBreached
                              ? const Color(0xFFFFEBEE)
                              : const Color(0xFFE8F5E9),
                          borderRadius:
                              BorderRadius.circular(20),
                          border: Border.all(
                            color: entry.isBreached
                                ? const Color(
                                    0xFFC62828)
                                : const Color(
                                    0xFF2E7D32)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              entry.isBreached
                                  ? Icons
                                      .warning_amber_rounded
                                  : Icons
                                      .check_circle_outline,
                              size: 14,
                              color: entry.isBreached
                                  ? const Color(
                                      0xFFC62828)
                                  : const Color(
                                      0xFF2E7D32)),
                            const SizedBox(width: 4),
                            Text(
                              entry.isBreached
                                  ? 'Breached'
                                  : 'Safe',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.w600,
                                color: entry.isBreached
                                    ? const Color(
                                        0xFFC62828)
                                    : const Color(
                                        0xFF2E7D32))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Added: ${entry.createdAt.day}'
                    '/${entry.createdAt.month}'
                    '/${entry.createdAt.year}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable detail row builder
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon,
              color: const Color(0xFF1E3A5F), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey)),
                const SizedBox(height: 3),
                Text(value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy,
                  color: Color(0xFF1E3A5F), size: 20),
              onPressed: onCopy,
            ),
        ],
      ),
    );
  }
}