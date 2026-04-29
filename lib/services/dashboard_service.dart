import '../models/password_entry.dart';
import '../models/security_stats.dart';
import '../services/firestore_service.dart';
import '../services/encryption_service.dart';

class DashboardService {

  //loads all passwords and computes the full stats
  static Future<SecurityStats> computeStats() async {

    // Load all password entries once (not a stream — we need a snapshot)
    final entries = await FirestoreService.getPasswordsOnce();

    // Handle empty vault — return a perfect score with no issues
    if (entries.isEmpty) {
      return const SecurityStats(
        total: 0, weakCount: 0,
        breachedCount: 0, reusedCount: 0,
        score: 100,
        actionItems: ['Add passwords to your vault to see your security score.'],
      );
    }

    final int total = entries.length;

    // ── Count weak passwords 
    final int weakCount = entries.where((e) =>
        e.strength == 'Very Weak' || e.strength == 'Weak'
    ).length;

    // ── Count breached passwords 
    // Simple — just count entries where isBreached was saved as true
    final int breachedCount =
        entries.where((e) => e.isBreached).length;

    // ── Detect reused passwords 
    final Map<String, int> passwordFrequency = {};
    for (final entry in entries) {
      // Decrypt the password — happens only in device memory, never sent anywhere
      final plain = EncryptionService.decrypt(entry.encryptedPassword);
      // If we have seen this plain text before, increment count. Else start at 1.
      passwordFrequency[plain] = (passwordFrequency[plain] ?? 0) + 1;
    }
    // Step 2: Count entries whose password appears more than once
    int reusedCount = 0;
    for (final entry in entries) {
      final plain = EncryptionService.decrypt(entry.encryptedPassword);
      if ((passwordFrequency[plain] ?? 0) > 1) reusedCount++;
    }

    // ── Calculate score 
    double score = 100.0;
    score -= ((2 * weakCount) / total) * 40; // up to -40 for all weak
    score -= ((2 * breachedCount) / total) * 40; // up to -40 for all breached
    score -= (reusedCount / total) * 20; // up to -20 for all reused
    final int finalScore = score.round().clamp(0, 100);

    // ── Build action items 
    final List<String> actionItems = [];

    if (breachedCount > 0) {
      actionItems.add(
        '$breachedCount password${breachedCount > 1 ? 's' : ''} '
        'found in data breaches — change '
        '${breachedCount > 1 ? 'them' : 'it'} immediately!');
    }
    if (weakCount > 0) {
      actionItems.add(
        '$weakCount weak password${weakCount > 1 ? 's' : ''} — '
        'replace ${weakCount > 1 ? 'them' : 'it'} with stronger ones.');
    }
    if (reusedCount > 0) {
      actionItems.add(
        '$reusedCount password${reusedCount > 1 ? 's are' : ' is'} '
        'reused across multiple sites — each site needs a unique password.');
    }
    if (actionItems.isEmpty) {
      actionItems.add('All passwords look good!');
    }

    return SecurityStats(
      total: total,
      weakCount: weakCount,
      breachedCount: breachedCount,
      reusedCount: reusedCount,
      score: finalScore,
      actionItems: actionItems,
    );
  }
}