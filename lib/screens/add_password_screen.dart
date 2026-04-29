import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/encryption_service.dart';
import '../models/password_entry.dart';
import '../widgets/strength_meter.dart';
import '../utils/password_strength.dart';
import '../services/breach_service.dart';

class AddPasswordScreen extends StatefulWidget {
  const AddPasswordScreen({super.key});
  @override
  State<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _siteCtrl     = TextEditingController();
  final _urlCtrl      = TextEditingController();
  final _userCtrl     = TextEditingController();
  final _passCtrl     = TextEditingController();

  bool    _isLoading    = false;
  bool    _showPassword = false;
  String  _category     = 'Personal';

  BreachResult? _breachResult;
  bool _isCheckingBreach = false;

  String _currentPassword = '';

  final List<String> _categories =
      ['Personal', 'Work', 'Study', 'Banking', 'Social', 'Shopping', 'Other'];

  @override
  void dispose() {
    _siteCtrl.dispose();
    _urlCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is String) {
        setState(() {
          _passCtrl.text  = args;
          _currentPassword = args;
        });
      } else if (args is PasswordEntry) {
        setState(() {
          _siteCtrl.text   = args.siteName;
          _urlCtrl.text    = args.siteUrl;
          _userCtrl.text   = args.username;
          // Decrypt the stored password so we can show it in the field
          final plain      = EncryptionService.decrypt(
              args.encryptedPassword);
          _passCtrl.text   = plain;
          _currentPassword = plain;
          _category        = args.category;
        });
      }
    });
  }

  // ─── Core save logic 
  Future<void> _handleSave() async {
    // Step 1: validate all form fields
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final encrypted = EncryptionService.encrypt(_passCtrl.text);
      final strengthResult = analyzePassword(_passCtrl.text);

      // Step 3: build the PasswordEntry object
      final entry = PasswordEntry(
        id: '',           // Firestore assigns this
        siteName: _siteCtrl.text.trim(),
        siteUrl: _urlCtrl.text.trim(),
        username: _userCtrl.text.trim(),
        encryptedPassword: encrypted,    // store ONLY the encrypted version
        strength: strengthResult.label, // strength checker added on Day 6
        isBreached: _breachResult?.isBreached ?? false,  
        breachCount: _breachResult?.breachCount ?? 0,      // breach check added on Day 8
        category: _category,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Step 4: save to Firestore
      await FirestoreService.addPassword(entry);

      // Step 5: go back to vault list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password saved securely!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context); // returns to HomeScreen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkBreach() async {
  if (_passCtrl.text.isEmpty) return;
  setState(() => _isCheckingBreach = true);
  final result = await BreachService.checkPassword(_passCtrl.text);
  if (mounted) {
    setState(() {
      _breachResult = result;
      _isCheckingBreach = false;
    });
  }
}

  // ─── Reusable input decoration 
  InputDecoration _inputDeco(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF1E3A5F)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFF1E3A5F), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Password'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Site Name 
              TextFormField(
                controller: _siteCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDeco(
                  'Site / App Name', Icons.language,
                  hint: 'e.g. Google, Facebook'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty){
                    return 'Site name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── URL (optional) 
              TextFormField(
                controller: _urlCtrl,
                keyboardType: TextInputType.url,
                decoration: _inputDeco(
                  'Website URL (optional)', Icons.link,
                  hint: 'e.g. https://google.com'),
              ),
              const SizedBox(height: 16),

              // ── Username / Email 
              TextFormField(
                controller: _userCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDeco(
                  'Username or Email', Icons.person_outline,
                  hint: 'e.g. zain@gmail.com'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty){
                    return 'Username or email is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Password field with show/hide toggle 
              TextFormField(
                controller: _passCtrl,
                obscureText: !_showPassword,
                onChanged: (val) => setState(() => _currentPassword = val),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(
                    Icons.lock_outline, color: Color(0xFF1E3A5F)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF1E3A5F), width: 2)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Password is required';
                  }
                  if (v.length < 4) {
                    return 'Password must be at least 4 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              StrengthMeter(password: _currentPassword),

              const SizedBox(height: 12),

              // The check button — shows spinner while checking
              OutlinedButton.icon(
                onPressed: _isCheckingBreach ? null : _checkBreach,
                icon: _isCheckingBreach
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.security_outlined, size: 18),
                label: Text(_isCheckingBreach
                  ? 'Checking...'
                  : 'Check for Data Breaches'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E3A5F),
                  side: const BorderSide(color: Color(0xFF1E3A5F)),
                ),
              ),

              // Result — shown only after a check
              if (_breachResult != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _breachResult!.isBreached
                        ? const Color(0xFFFDEDEC)
                        : const Color(0xFFEAF5EA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _breachResult!.isBreached
                          ? const Color(0xFFF1948A)
                          : const Color(0xFF81C784)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _breachResult!.isBreached
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline,
                        color: _breachResult!.isBreached
                            ? const Color(0xFFC0392B)
                            : const Color(0xFF2E7D32),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _breachResult!.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: _breachResult!.isBreached
                                ? const Color(0xFF922B21)
                                : const Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // ── Category dropdown 
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: _inputDeco('Category', Icons.folder_outlined),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 8),

              // ── Encryption notice 
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined,
                      size: 16, color: Color(0xFF1565C0)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your password will be AES-256 encrypted before saving.',
                        style: TextStyle(
                          fontSize: 12, color: Color(0xFF1565C0)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Save button 
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                    : const Text('Save Password',
                        style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}