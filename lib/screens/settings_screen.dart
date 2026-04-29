import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // no back arrow in tab
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ── User profile card 
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: const Color(0xFF1E3A5F),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person,
                        size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.email ?? 'Not logged in',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  const Text('VaultGuard Account',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Security section 
            _buildSectionHeader('Security'),
            _buildTile(
              icon: Icons.lock_outline,
              title: 'Password Vault',
              subtitle: 'AES-256 encrypted storage',
              onTap: () => Navigator.pushNamed(
                  context, '/home'),
            ),
            _buildTile(
              icon: Icons.security_outlined,
              title: 'Breach Check',
              subtitle: 'Check passwords against known breaches',
              onTap: () => Navigator.pushNamed(
                  context, '/breach'),
            ),
            _buildTile(
              icon: Icons.dashboard_outlined,
              title: 'Security Dashboard',
              subtitle: 'View your overall security score',
              onTap: () => Navigator.pushNamed(
                  context, '/dashboard'),
            ),

            const SizedBox(height: 8),

            // ── About section 
            _buildSectionHeader('About'),
            _buildTile(
              icon: Icons.info_outline,
              title: 'VaultGuard',
              subtitle: 'Version 1.0.0 — BSCS Semester Project',
              onTap: () => _showAboutDialog(context),
            ),
            _buildTile(
              icon: Icons.shield_outlined,
              title: 'Privacy',
              subtitle:
                  'Your passwords never leave your device unencrypted',
              onTap: null,
            ),

            const SizedBox(height: 8),

            // ── Account section 
            _buildSectionHeader('Account'),
            _buildTile(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              iconColor: Colors.red,
              titleColor: Colors.red,
              onTap: () => _confirmLogout(context),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Section header label
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 0.8)),
      ),
    );
  }

  // Reusable settings tile
  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    Color? titleColor,
    required VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: iconColor ?? const Color(0xFF1E3A5F)),
        title: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: titleColor ?? const Color(0xFF1A1A1A))),
        subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 12, color: Colors.grey)),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right,
                color: Colors.grey)
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Logout confirmation dialog
  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
            'Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await AuthService().logout();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  // About dialog
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'VaultGuard',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
          Icons.shield_rounded,
          size: 48,
          color: Color(0xFF1E3A5F)),
      children: [
        const Text(
          'A secure password manager with AES-256 encryption, real-time breach detection, and password strength analysis.'
          '\n\nBuilt with Flutter and Firebase.\n'
          'MAD Semester Project.',
        ),
      ],
    );
  }
}

