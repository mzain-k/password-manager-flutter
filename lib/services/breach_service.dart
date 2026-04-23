import 'dart:async';
import 'dart:convert';          // for utf8.encode()
import 'package:crypto/crypto.dart';  // for sha1.convert()
import 'package:http/http.dart' as http; // for http.get()

// This class holds the result of one breach check
class BreachResult {
  final bool   isBreached;   // true = found in breaches, false = safe
  final int    breachCount;  // how many times found (0 if safe)
  final String message;      // human-readable message to show the user

  const BreachResult({
    required this.isBreached,
    required this.breachCount,
    required this.message,
  });
}

class BreachService {
  // The HIBP API base URL — we append the 5-char prefix to this
  static const String _baseUrl =
      'https://api.pwnedpasswords.com/range/';

  // ─── Main method: check if a password has been breached 
  static Future<BreachResult> checkPassword(String password) async {

    // Handle empty input gracefully
    if (password.isEmpty) {
      return const BreachResult(
        isBreached: false,
        breachCount: 0,
        message: 'Enter a password to check.',
      );
    }

    try {
      // ── STEP 1: Hash the password with SHA-1
      // utf8.encode() converts the password string into raw bytes
      // sha1.convert() scrambles those bytes into a 40-char hex code
      // .toString() converts the hash object to a readable string
      // .toUpperCase() makes it uppercase so comparison works later
      final bytes    = utf8.encode(password);
      final sha1Hash = sha1.convert(bytes).toString().toUpperCase();

      // ── STEP 2: Split into prefix (first 5) and suffix (rest) 
      // The prefix is sent to the server
      // The suffix is kept on the device for local comparison
      final prefix = sha1Hash.substring(0, 5);
      final suffix = sha1Hash.substring(5);

      // ── STEP 3: Send ONLY the prefix to the HIBP API
      // We are making an HTTP GET request — like a browser loading a URL
      // timeout: if the server takes more than 10 seconds, give up
      final uri      = Uri.parse('$_baseUrl$prefix');
      final response = await http.get(
        uri,
        headers: {'Add-Padding': 'true'}, // extra privacy protection
      ).timeout(const Duration(seconds: 10));

      // Check if the server responded successfully
      // HTTP status 200 means OK. Anything else is an error.
      if (response.statusCode != 200) {
        return BreachResult(
          isBreached: false,
          breachCount: 0,
          message: 'Server error (${response.statusCode}). Try again later.',
        );
      }

      // ── STEP 4: Parse the response 
      // The response body is a plain text list, one entry per line.
      // Each line looks like: "75F9834B4E7F0A528CC65C055702BF5F66E:3456"
      //                        ↑ hash suffix                      ↑ count
      // We split the body by newlines to get individual lines
      final lines = response.body.split('\n');

      // ── STEP 5: Check locally if our suffix is in the list 
      for (final line in lines) {
        // Split each line by ':' to separate the suffix from the count
        final parts = line.trim().split(':');
        if (parts.length < 2) continue; // skip malformed lines

        final responseSuffix = parts[0].trim(); // the hash suffix
        final count = int.tryParse(parts[1].trim()) ?? 0; // the count

        // Compare our suffix with this line's suffix
        if (responseSuffix == suffix) {
          // Match found! This password is in the breach database.
          if (count == 0) break; // count 0 = padding line, not real
          return BreachResult(
            isBreached: true,
            breachCount: count,
            message:
              'Found in $count known data breach${count == 1 ? '' : 'es'}!\n'
              'You should change this password immediately.',
          );
        }
      }

      // Loop finished without finding our suffix — password is safe
      return const BreachResult(
        isBreached: false,
        breachCount: 0,
        message: 'Good news! Not found in any known data breaches.',
      );

    } on TimeoutException catch (_) {
      // Network request took too long
      return const BreachResult(
        isBreached: false,
        breachCount: 0,
        message: 'Request timed out. Check your internet connection.',
      );
    } catch (e) {
      // Any other error (no internet, DNS failure, etc.)
      return const BreachResult(
        isBreached: false,
        breachCount: 0,
        message: 'Could not check right now. Try again later.',
      );
    }
  }
}