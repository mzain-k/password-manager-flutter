import 'package:flutter/material.dart';
import '../utils/password_strength.dart';

class StrengthMeter extends StatelessWidget {
  final String password;

  const StrengthMeter({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    // Analyze the password every time the widget rebuilds
    final result = analyzePassword(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Password strength',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              result.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: result.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // ── Animated progress bar 
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: result.fraction),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: const Color(0xFFE0E0E0),
                valueColor: AlwaysStoppedAnimation<Color>(result.color),
              );
            },
          ),
        ),

        // ── Suggestions list
        if (result.suggestions.isNotEmpty && password.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...result.suggestions.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.arrow_right,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}