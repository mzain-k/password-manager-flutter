import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../models/security_stats.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Future that loads the stats — reassigned when user refreshes
  late Future<SecurityStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    // Load stats as soon as the screen opens
    _statsFuture = DashboardService.computeStats();
  }

  // Called when user taps the refresh button
  void _refresh() {
    setState(() {
      // Reassigning _statsFuture causes FutureBuilder to restart
      _statsFuture = DashboardService.computeStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Security Dashboard'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<SecurityStats>(
        future: _statsFuture,
        builder: (context, snapshot) {

          // Loading state — shown while Firestore fetch is in progress
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1E3A5F)),
                  SizedBox(height: 16),
                  Text('Analysing your vault...',
                    style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
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
                    style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          // Data loaded — build the full dashboard
          final stats = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ── Score ring section 
                  _buildScoreSection(stats),
                  const SizedBox(height: 20),

                  // ── Stat cards row 
                  _buildStatCards(stats),
                  const SizedBox(height: 20),

                  // ── Action items section 
                  _buildActionItems(stats),
                  const SizedBox(height: 20),

                  // ── Tips section 
                  _buildTipsSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Score ring section 
  Widget _buildScoreSection(SecurityStats stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          const Text('Overall Security Score',
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A5F))),
          const SizedBox(height: 20),

          // Score ring — a Stack with a background circle and
          // a coloured arc showing the score percentage
          SizedBox(
            width: 160, height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background grey ring
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 14,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFEEEEEE)),
                  ),
                ),
                // Coloured score arc
                SizedBox.expand(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0,
                      end: stats.score / 100.0),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, _) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 14,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          stats.scoreColor),
                        strokeCap: StrokeCap.round,
                      );
                    },
                  ),
                ),
                // Score number and label in the centre
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${stats.score}',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: stats.scoreColor)),
                    Text(stats.scoreLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: stats.scoreColor)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            stats.isHealthy
                ? 'Your vault is secure. Great work!'
                : 'Your vault needs attention. See action items below.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: stats.isHealthy
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFF57F17)),
          ),
        ],
      ),
    );
  }

  // ── 4 Stat cards in a 2x2 grid 
  Widget _buildStatCards(SecurityStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          label: 'Total',
          value: stats.total,
          icon: Icons.lock_outline,
          color: const Color(0xFF1E3A5F),
          bgColor: const Color(0xFFE8EAF6),
        ),
        _buildStatCard(
          label: 'Weak',
          value: stats.weakCount,
          icon: Icons.warning_amber_outlined,
          color: stats.weakCount > 0
              ? const Color(0xFFE65100)
              : const Color(0xFF2E7D32),
          bgColor: stats.weakCount > 0
              ? const Color(0xFFFFF3E0)
              : const Color(0xFFE8F5E9),
        ),
        _buildStatCard(
          label: 'Breached',
          value: stats.breachedCount,
          icon: Icons.gpp_bad_outlined,
          color: stats.breachedCount > 0
              ? const Color(0xFFC62828)
              : const Color(0xFF2E7D32),
          bgColor: stats.breachedCount > 0
              ? const Color(0xFFFFEBEE)
              : const Color(0xFFE8F5E9),
        ),
        _buildStatCard(
          label: 'Reused',
          value: stats.reusedCount,
          icon: Icons.copy_outlined,
          color: stats.reusedCount > 0
              ? const Color(0xFF6A1B9A)
              : const Color(0xFF2E7D32),
          bgColor: stats.reusedCount > 0
              ? const Color(0xFFF3E5F5)
              : const Color(0xFFE8F5E9),
        ),
      ],
    );
  }

  // Single stat card widget
  Widget _buildStatCard({
    required String label,
    required int    value,
    required IconData icon,
    required Color  color,
    required Color  bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text('$value',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color)),
          Text(label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  // ── Action items section 
  Widget _buildActionItems(SecurityStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.checklist_rtl,
                color: Color(0xFF1E3A5F), size: 20),
              SizedBox(width: 8),
              Text('Action Items',
                style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F))),
            ],
          ),
          const SizedBox(height: 12),
          ...stats.actionItems.map((item) =>
            _buildActionItem(item, stats)),
        ],
      ),
    );
  }

  // Single action item row
  Widget _buildActionItem(String item, SecurityStats stats) {
    // Determine icon and colour based on content of the message
    final isGood = item.contains('good') || item.contains('Add passwords');
    final isBreach = item.contains('breach');
    final isWeak = item.contains('weak');

    Color itemColor;
    IconData itemIcon;
    if (isGood) {
      itemColor = const Color(0xFF2E7D32);
      itemIcon  = Icons.check_circle_outline;
    } else if (isBreach) {
      itemColor = const Color(0xFFC62828);
      itemIcon  = Icons.gpp_bad_outlined;
    } else if (isWeak) {
      itemColor = const Color(0xFFE65100);
      itemIcon  = Icons.warning_amber_outlined;
    } else {
      itemColor = const Color(0xFF6A1B9A);
      itemIcon  = Icons.copy_outlined;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(itemIcon, color: itemColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(item,
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF333333),
                height: 1.5)),
          ),
        ],
      ),
    );
  }

  // ── General tips section 
  Widget _buildTipsSection() {
    final tips = [
      'Use a unique password for every single website.',
      'Passwords with 16+ characters are extremely hard to crack.',
      'Use the built-in generator to create strong passwords instantly.',
      'Check your passwords for breaches regularly.',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline,
                color: Color(0xFF1565C0), size: 20),
              SizedBox(width: 8),
              Text('Security Tips',
                style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0))),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ',
                  style: TextStyle(
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(tip,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1565C0),
                      height: 1.5))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}