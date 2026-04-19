import 'package:flutter/material.dart';
import '../models/password_entry.dart';

class PasswordCard extends StatelessWidget {
  final PasswordEntry entry;
  final VoidCallback onTap;

  const PasswordCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  // Returns a color based on the strength label
  Color _strengthColor(String strength) {
    switch (strength) {
      case 'Very Strong': return const Color(0xFF1B5E20);
      case 'Strong':      return const Color(0xFF2E7D32);
      case 'Fair':        return const Color(0xFFF57F17);
      case 'Weak':        return const Color(0xFFE65100);
      case 'Very Weak':   return const Color(0xFFB71C1C);
      default:            return Colors.grey;
    }
  }

  Color _strengthBgColor(String strength) {
    switch (strength) {
      case 'Very Strong':
      case 'Strong':      return const Color(0xFFE8F5E9);
      case 'Fair':        return const Color(0xFFFFFDE7);
      case 'Weak':
      case 'Very Weak':   return const Color(0xFFFFEBEE);
      default:            return const Color(0xFFF5F5F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
          ),
        ),
        child: Row(
          children: [

            // Leading avatar — first letter of site name
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF1E3A5F),
              child: Text(
                entry.siteName.isNotEmpty
                    ? entry.siteName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Site name + username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.siteName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.username,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right side: strength badge + breach warning
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Strength badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _strengthBgColor(entry.strength),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.strength,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _strengthColor(entry.strength),
                    ),
                  ),
                ),

                // Breach warning (only shown if breached)
                if (entry.isBreached) ...[
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                        size: 12, color: Color(0xFFB71C1C)),
                      SizedBox(width: 2),
                      Text('Breached',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB71C1C),
                          fontWeight: FontWeight.w500,
                        )),
                    ],
                  ),
                ],
              ],
            ),

            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
              color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
