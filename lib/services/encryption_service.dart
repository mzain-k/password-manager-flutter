import 'package:encrypt/encrypt.dart' as enc;

class EncryptionService {

  // ─── The Encryption Key ───────────────────────────────────────────────
  // MUST be exactly 32 characters for AES-256.
  // Count these: V-a-u-l-t-G-u-a-r-d-S-e-c-r-e-t-K-e-y-2-0-2-4-!-A-B-C-D-E-F-G-H = 32
  //
  // FOR A UNIVERSITY PROJECT: hardcoding is acceptable.
  // IN A PRODUCTION APP: store this in flutter_secure_storage or
  // derive it from the user's master password using PBKDF2.
  static const String _rawKey = 'VaultGuardSecretKey2024!ABCDEFGH';

  // ─── encrypt() ────────────────────────────────────────────────────────
  // Takes a plain text password (e.g. 'MyPass123')
  // Returns an encrypted string (e.g. 'ivBase64:cipherBase64')
  // This returned string is what gets saved to Firestore.
  static String encrypt(String plainText) {
    if (plainText.isEmpty) return '';

    // Step 1: Build the key object from our 32-char string
    final key = enc.Key.fromUtf8(_rawKey);

    // Step 2: Generate a fresh random IV (16 bytes)
    // IMPORTANT: a new IV is created every single time encrypt() is called.
    // This means encrypting the same password twice gives different outputs.
    final iv = enc.IV.fromSecureRandom(16);

    // Step 3: Create the AES encrypter in CBC mode
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    // Step 4: Encrypt the plain text using the key and IV
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Step 5: Return 'ivBase64:encryptedBase64'
    // We store BOTH the IV and the cipher text together.
    // The IV is needed for decryption — without it the cipher text is useless.
    // The IV is not secret, so storing it alongside the cipher text is safe.
    return '${iv.base64}:${encrypted.base64}';
  }

  // ─── decrypt() ────────────────────────────────────────────────────────
  // Takes an encrypted string (e.g. 'ivBase64:cipherBase64')
  // Returns the original plain text password (e.g. 'MyPass123')
  static String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return '';

    try {
      // Step 1: Split the stored string back into IV and cipher parts
      final parts = encryptedText.split(':');

      // Safety check: we need exactly 2 parts (IV and cipher)
      // If the format is wrong, return an error string instead of crashing
      if (parts.length < 2) return '[Decryption Error]';

      // Step 2: Rebuild the IV from the stored base64 string
      final iv = enc.IV.fromBase64(parts[0]);

      // Step 3: Rebuild the same key
      final key = enc.Key.fromUtf8(_rawKey);

      // Step 4: Create the same encrypter
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

      // Step 5: Decrypt using the cipher text (parts[1]) and the IV
      // parts[1] is the base64-encoded cipher text
      return encrypter.decrypt64(parts[1], iv: iv);

    } catch (e) {
      // Never crash the app due to a decryption error.
      // Return a safe placeholder string instead.
      // This can happen if the key changes or data is corrupted.
      return '[Decryption Error]';
    }
  }

  // ─── isEncrypted() ────────────────────────────────────────────────────
  // Helper to check if a string looks like it has been encrypted.
  // Encrypted strings always contain a colon separating IV:CipherText.
  static bool isEncrypted(String text) {
    return text.contains(':') && text.length > 30;
  }
}