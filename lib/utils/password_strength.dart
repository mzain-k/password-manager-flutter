import 'package:flutter/material.dart';

class StrengthResult {
  final String label;
  final int    score;
  final Color  color;
  final double fraction;
  final List<String> suggestions;

  const StrengthResult({
    required this.label,
    required this.score,
    required this.color,
    required this.fraction,
    required this.suggestions,
  });
}

// The 30 most common passwords
const List<String> _commonPasswords = [
  '123456', 'password', '123456789', '12345678', '12345',
  '1234567', 'password123', '1234567890', 'qwerty', 'abc123',
  'asdf1234', '000000', '1234', 'pakistan', 'zain4321',
  'ilovepakistan', 'qqww1122', '123', 'khan123', '123321',
  'qwertyuiop', 'Nust@1234', 'qwerty123', '123qwe', '654321',
  '111111', '123123', 'ronaldo', 'messi', 'laptop',
];


StrengthResult analyzePassword(String password) {
  // Handle empty input gracefully
  if (password.isEmpty) {
    return StrengthResult(
      label: 'Enter a password',
      score: 0,
      color: const Color(0xFFBDBDBD),
      fraction: 0.0,
      suggestions: [],
    );
  }

  int score = 0;
  final List<String> suggestions = [];

  // ── FACTOR 1: Length ───────────────────────────────────────────────
  if (password.length < 6) {
    score -= 10;
    suggestions.add('Use at least 8 characters');
  } else if (password.length < 8) {
    score += 10;
    suggestions.add('Aim for 12 or more characters');
  } else if (password.length < 12) {
    score += 25;
    suggestions.add('Longer passwords are stronger — try 12+');
  } else if (password.length < 16) {
    score += 35;
  } else {
    score += 50; // 16+ characters
  }

  // ── FACTOR 2: Lowercase letters ───────────────────────────────────
  final hasLower = RegExp(r'[a-z]').hasMatch(password);
  if (hasLower) {
    score += 10;
  } else {
    suggestions.add('Add lowercase letters (a-z)');
  }

  // ── FACTOR 3: Uppercase letters ───────────────────────────────────
  final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
  if (hasUpper) {
    score += 10;
  } else {
    suggestions.add('Add uppercase letters (A-Z)');
  }

  // ── FACTOR 4: Numbers ─────────────────────────────────────────────
  final hasDigit = RegExp(r'[0-9]').hasMatch(password);
  if (hasDigit) {
    score += 10;
  } else {
    suggestions.add('Add numbers (0-9)');
  }

  // ── FACTOR 5: Special characters ──────────────────────────────────
  final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>\-_=+\[\]\/\\]')
      .hasMatch(password);
  if (hasSpecial) {
    score += 15;
  } else {
    suggestions.add('Add special characters (!@#\$%^&*)');
  }

  // ── FACTOR 6: Common password penalty ─────────────────────────────
  if (_commonPasswords.contains(password.toLowerCase())) {
    score -= 30;
    suggestions.insert(0,
      'This is one of the most common passwords — change it immediately!');
  }

  // ── Clamp and map to label ─────────────────────────────────────────
  score = score.clamp(0, 100);
  final fraction = score / 100.0;

  if (score < 20) {
    return StrengthResult(
      label: 'Very Weak', score: score, fraction: fraction,
      color: const Color(0xFFD32F2F), suggestions: suggestions);
  } else if (score < 40) {
    return StrengthResult(
      label: 'Weak', score: score, fraction: fraction,
      color: const Color(0xFFF57C00), suggestions: suggestions);
  } else if (score < 60) {
    return StrengthResult(
      label: 'Fair', score: score, fraction: fraction,
      color: const Color(0xFFFBC02D), suggestions: suggestions);
  } else if (score < 80) {
    return StrengthResult(
      label: 'Strong', score: score, fraction: fraction,
      color: const Color(0xFF388E3C), suggestions: suggestions);
  } else {
    return StrengthResult(
      label: 'Very Strong', score: score, fraction: fraction,
      color: const Color(0xFF1B5E20), suggestions: suggestions);
  }
}