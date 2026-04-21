import 'dart:math';

// Configuration object — all generator settings in one place
class GeneratorConfig {
  final int    length;
  final bool   useLowercase;
  final bool   useUppercase;
  final bool   useNumbers;
  final bool   useSymbols;
  final bool   avoidAmbiguous; // removes 0,O,l,1,I,| to prevent confusion

  const GeneratorConfig({
    this.length        = 16,
    this.useLowercase  = true,
    this.useUppercase  = true,
    this.useNumbers    = true,
    this.useSymbols    = true,
    this.avoidAmbiguous = false,
  });

  // Creates a copy with specific fields updated (useful for the toggles)
  GeneratorConfig copyWith({
    int?  length,
    bool? useLowercase,
    bool? useUppercase,
    bool? useNumbers,
    bool? useSymbols,
    bool? avoidAmbiguous,
  }) {
    return GeneratorConfig(
      length: length ?? this.length,
      useLowercase: useLowercase ?? this.useLowercase,
      useUppercase: useUppercase ?? this.useUppercase,
      useNumbers: useNumbers ?? this.useNumbers,
      useSymbols: useSymbols ?? this.useSymbols,
      avoidAmbiguous: avoidAmbiguous ?? this.avoidAmbiguous,
    );
  }
}

class PasswordService {
  // Character sets — full versions
  static const _lower   = 'abcdefghijklmnopqrstuvwxyz';
  static const _upper   = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _digits  = '0123456789';
  static const _symbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

  // Ambiguity-free versions (removes characters that look similar)
  static const _lowerClean  = 'abcdefghjkmnpqrstuvwxyz';  // no i,l,o
  static const _upperClean  = 'ABCDEFGHJKMNPQRSTUVWXYZ';  // no I,L,O
  static const _digitsClean = '23456789';                  // no 0,1

  static String generate(GeneratorConfig config) {
    // At least one character type must be enabled
    if (!config.useLowercase && !config.useUppercase &&
        !config.useNumbers   && !config.useSymbols) {
      return 'Enable at least one character type';
    }

    // Use cryptographically secure random — NEVER use Random()
    final rng = Random.secure();

    // Build the full character pool and list of required characters
    final pool     = StringBuffer();
    final required = <String>[];

    if (config.useLowercase) {
      final set = config.avoidAmbiguous ? _lowerClean : _lower;
      pool.write(set);
      required.add(set[rng.nextInt(set.length)]); // guarantee one lowercase
    }
    if (config.useUppercase) {
      final set = config.avoidAmbiguous ? _upperClean : _upper;
      pool.write(set);
      required.add(set[rng.nextInt(set.length)]); // guarantee one uppercase
    }
    if (config.useNumbers) {
      final set = config.avoidAmbiguous ? _digitsClean : _digits;
      pool.write(set);
      required.add(set[rng.nextInt(set.length)]); // guarantee one digit
    }
    if (config.useSymbols) {
      pool.write(_symbols);
      required.add(_symbols[rng.nextInt(_symbols.length)]); // guarantee one symbol
    }

    final poolStr = pool.toString();

    // Fill remaining slots with random characters from the full pool
    final result = <String>[];
    final remaining = config.length - required.length;
    for (int i = 0; i < remaining; i++) {
      result.add(poolStr[rng.nextInt(poolStr.length)]);
    }

    // Add the guaranteed required characters
    result.addAll(required);

    // Shuffle so required chars are not always at the end
    // IMPORTANT: use the same secure rng for shuffle
    result.shuffle(rng);

    return result.join();
  }

  // Convenience method — generate with default config
  static String generateDefault() => generate(const GeneratorConfig());

  // Estimate how long it would take to brute-force this password
  // (informational — shown on the generator screen)
  static String crackTimeEstimate(String password) {
    if (password.isEmpty) return '';
    // Rough pool size based on character variety
    int poolSize = 0;
    if (RegExp(r'[a-z]').hasMatch(password)) poolSize += 26;
    if (RegExp(r'[A-Z]').hasMatch(password)) poolSize += 26;
    if (RegExp(r'[0-9]').hasMatch(password)) poolSize += 10;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) poolSize += 32;

    // Combinations = poolSize ^ length
    // At 1 billion guesses/second:
    final combinations = BigInt.from(poolSize).pow(password.length);
    final seconds = combinations ~/ BigInt.from(1000000000);

    if (seconds < BigInt.from(60)) return 'less than a minute';
    if (seconds < BigInt.from(3600)) return '${seconds ~/ BigInt.from(60)} minutes';
    if (seconds < BigInt.from(86400)) return '${seconds ~/ BigInt.from(3600)} hours';
    if (seconds < BigInt.from(31536000)) return '${seconds ~/ BigInt.from(86400)} days';
    if (seconds < BigInt.from(31536000) * BigInt.from(1000)) return '${seconds ~/ BigInt.from(31536000)} years';
    return 'centuries';
  }
}