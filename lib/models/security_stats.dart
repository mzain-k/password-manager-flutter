import 'package:flutter/material.dart';

class SecurityStats {
  final int total;          // total number of saved passwords
  final int weakCount;      // passwords scored Weak or Very Weak
  final int breachedCount;  // passwords found in breach databases
  final int reusedCount;    // passwords used on more than one site
  final int score;          // overall security score 0-100
  final List<String> actionItems;    // list of things the user should fix

  const SecurityStats({
    required this.total,
    required this.weakCount,
    required this.breachedCount,
    required this.reusedCount,
    required this.score,
    required this.actionItems,
  });

  // Returns the text label for the score
  // Called like: stats.scoreLabel 
  String get scoreLabel {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Poor';
    return 'Critical';
  }

  // Returns the display colour for the score ring and label
  Color get scoreColor {
    if (score >= 80) return const Color(0xFF2E7D32); 
    if (score >= 60) return const Color(0xFF388E3C); 
    if (score >= 40) return const Color(0xFFF57F17); 
    if (score >= 20) return const Color(0xFFE64A19);
    return const Color(0xFFC62828);
  }

  // Convenience: returns true if there are no problems at all
  bool get isHealthy =>
      weakCount == 0 && breachedCount == 0 && reusedCount == 0;
}