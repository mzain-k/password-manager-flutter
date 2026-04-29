import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _showPass = false;
  bool _showConfirm = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.signUp(_emailCtrl.text, _passCtrl.text);
      if (mounted) Navigator.pushReplacementNamed(context, '/scaffold');
    } catch (e) {
      setState(() =>
        _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1E3A5F)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Create Account',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A5F))),
                const SizedBox(height: 6),
                const Text('Start protecting your passwords today',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 32),

                // Error box
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDEDEC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF1948A)),
                    ),
                    child: Text(_errorMessage!,
                      style: const TextStyle(color: Color(0xFFC0392B), fontSize: 13)),
                  ),
                  const SizedBox(height: 16),
                ],

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim()))
                      {return 'Enter a valid email';}
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passCtrl,
                  obscureText: !_showPass,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    helperText: 'At least 8 characters, mix of letters and numbers',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_showPass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                      onPressed: () => setState(() => _showPass = !_showPass),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'At least 6 characters required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm password — validates that it matches _passCtrl
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: !_showConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_showConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                      onPressed: () =>
                        setState(() => _showConfirm = !_showConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm your password';
                    if (v != _passCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Create account button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A5F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                    : const Text('Create Account',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 16),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Already have an account? ',
                    style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Login',
                      style: TextStyle(color: Color(0xFF1E3A5F),
                        fontWeight: FontWeight.bold)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}