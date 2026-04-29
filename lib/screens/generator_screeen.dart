import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/password_service.dart';
import '../widgets/strength_meter.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});
  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  GeneratorConfig _config = const GeneratorConfig();
  String _generated = '';

  @override
  void initState() {
    super.initState();
    // Auto-generate a password when the screen opens
    _generatePassword();
  }

  void _generatePassword() {
    setState(() {
      _generated = PasswordService.generate(_config);
    });
  }

  Future<void> _copyToClipboard() async {
    if (_generated.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _generated));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password copied to clipboard!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Reusable toggle row builder
  Widget _buildToggle({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFF1E3A5F),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final crackTime = PasswordService.crackTimeEstimate(_generated);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Password Generator'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Generated password display box 
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                children: [
                  // The generated password text
                  SelectableText(
                    _generated.isEmpty ? 'Generating...' : _generated,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _generated.length > 20 ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 1.5,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Crack time estimate
                  if (crackTime.isNotEmpty)
                    Text(
                      'Estimated crack time: $crackTime',
                      style: const TextStyle(
                        fontSize: 11, color: Colors.grey),
                    ),
                  const SizedBox(height: 16),

                  // Action buttons row
                  Row(
                    children: [
                      // Refresh — generates a new password
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _generatePassword,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Refresh'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1E3A5F),
                            side: const BorderSide(
                              color: Color(0xFF1E3A5F)),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Copy — copies to clipboard
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _copyToClipboard,
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('Copy'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A5F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Strength meter 
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: StrengthMeter(password: _generated),
            ),
            const SizedBox(height: 20),

            // ── Settings panel 
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Settings',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Length slider
                  Row(
                    children: [
                      const Text('Length',
                        style: TextStyle(fontSize: 14)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A5F),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _config.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _config.length.toDouble(),
                    min: 8, max: 32, divisions: 24,
                    activeColor: const Color(0xFF1E3A5F),
                    label: _config.length.toString(),
                    onChanged: (val) {
                      setState(() {
                        _config = _config.copyWith(length: val.round());
                      });
                      _generatePassword();
                    },
                  ),
                  const Divider(),

                  // Character type toggles
                  _buildToggle(
                    label: 'Lowercase letters',
                    subtitle: 'a b c d e f ...',
                    value: _config.useLowercase,
                    onChanged: (v) {
                      setState(() {
                        _config = _config.copyWith(useLowercase: v);
                      });
                      _generatePassword();
                    },
                  ),
                  _buildToggle(
                    label: 'Uppercase letters',
                    subtitle: 'A B C D E F ...',
                    value: _config.useUppercase,
                    onChanged: (v) {
                      setState(() {
                        _config = _config.copyWith(useUppercase: v);
                      });
                      _generatePassword();
                    },
                  ),
                  _buildToggle(
                    label: 'Numbers',
                    subtitle: '0 1 2 3 4 5 ...',
                    value: _config.useNumbers,
                    onChanged: (v) {
                      setState(() {
                        _config = _config.copyWith(useNumbers: v);
                      });
                      _generatePassword();
                    },
                  ),
                  _buildToggle(
                    label: 'Special characters',
                    subtitle: '! @ # \$ % ^ & *',
                    value: _config.useSymbols,
                    onChanged: (v) {
                      setState(() {
                        _config = _config.copyWith(useSymbols: v);
                      });
                      _generatePassword();
                    },
                  ),
                  _buildToggle(
                    label: 'Avoid ambiguous characters',
                    subtitle: 'Removes 0, O, l, 1, I — easy to confuse',
                    value: _config.avoidAmbiguous,
                    onChanged: (v) {
                      setState(() {
                        _config = _config.copyWith(avoidAmbiguous: v);
                      });
                      _generatePassword();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Use this password button 
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to Add Password with the generated password pre-filled
                Navigator.pushNamed(
                  context,
                  '/add',
                  arguments: _generated, // pass password as argument
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Use this Password',
                style: TextStyle(fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}