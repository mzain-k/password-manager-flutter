import 'package:flutter/material.dart';
import '../services/breach_service.dart';

class BreachCheckScreen extends StatefulWidget {
  const BreachCheckScreen({super.key});
  @override
  State<BreachCheckScreen> createState() => _BreachCheckScreenState();
}

class _BreachCheckScreenState extends State<BreachCheckScreen> {
  final _passCtrl = TextEditingController();
  bool         _isLoading = false;
  bool         _showPassword = false;
  BreachResult? _result;  // null means no check has been run yet

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkBreach() async {
    final password = _passCtrl.text.trim();
    if (password.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = null; // clear previous result
    });

    // Call the service 
    final result = await BreachService.checkPassword(password);

    if (mounted) {
      setState(() {
        _result    = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Breach Check'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard on tap outside
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Explanation card 
              Container(
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
                        Icon(Icons.shield_outlined,
                          color: Color(0xFF1565C0), size: 20),
                        SizedBox(width: 8),
                        Text('How this works',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your password is never sent to any server. '
                      'Only the first 5 characters of a one-way hash '
                      'are sent. This protects your privacy completely.',
                      style: TextStyle(
                        fontSize: 12, color: Color(0xFF1565C0)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Password input field 
              TextFormField(
                controller: _passCtrl,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Enter password to check',
                  prefixIcon: const Icon(
                    Icons.lock_outline, color: Color(0xFF1E3A5F)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF1E3A5F), width: 2)),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey),
                    onPressed: () => setState(
                      () => _showPassword = !_showPassword),
                  ),
                ),
                onFieldSubmitted: (_) => _checkBreach(),
              ),
              const SizedBox(height: 16),

              // ── Check button 
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _checkBreach,
                icon: _isLoading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.search),
                label: Text(
                  _isLoading ? 'Checking...' : 'Check for Breaches'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),

              // ── Result display 
              // Only shown after a check has been run
              if (_result != null) _buildResultCard(_result!),
            ],
          ),
        ),
      )
    );
  }

  // Builds the result card — green for safe, red for breached
  Widget _buildResultCard(BreachResult result) {
    final isBreached = result.isBreached;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isBreached
            ? const Color(0xFFFDEDEC)  // light red background
            : const Color(0xFFEAF5EA), // light green background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBreached
              ? const Color(0xFFF1948A) // red border
              : const Color(0xFF81C784), // green border
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Icon + headline row
          Row(
            children: [
              Icon(
                isBreached
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                color: isBreached
                    ? const Color(0xFFC0392B)
                    : const Color(0xFF2E7D32),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isBreached ? 'Password Breached!' : 'Password Safe',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isBreached
                        ? const Color(0xFFC0392B)
                        : const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Message text
          Text(
            result.message,
            style: TextStyle(
              fontSize: 13,
              color: isBreached
                  ? const Color(0xFF922B21)
                  : const Color(0xFF1B5E20),
              height: 1.5,
            ),
          ),

          // Breach count badge — only shown when breached
          if (isBreached && result.breachCount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFC0392B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Found ${result.breachCount.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (m) => '${m[1]},') } times in breach databases',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          // Action tip
          const SizedBox(height: 12),
          Text(
            isBreached
                ? 'Tip: Use the Password Generator to create a strong replacement.'
                : 'Tip: Even safe passwords should be unique for every website.',
            style: TextStyle(
              fontSize: 12,
              color: isBreached
                  ? const Color(0xFF922B21)
                  : const Color(0xFF2E7D32),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}