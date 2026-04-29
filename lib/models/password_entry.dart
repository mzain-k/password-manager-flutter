import 'package:cloud_firestore/cloud_firestore.dart';

class PasswordEntry {
  final String id;                  // Firestore document ID (auto-generated)
  final String siteName;
  final String siteUrl;
  final String username;
  final String encryptedPassword;   // AES encrypted — NEVER plain text
  final String strength;
  final bool   isBreached;
  final int    breachCount;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PasswordEntry({
    required this.id,
    required this.siteName,
    this.siteUrl        = '',
    required this.username,
    required this.encryptedPassword,
    this.strength       = 'Unknown',
    this.isBreached     = false,
    this.breachCount    = 0,
    this.category       = 'Personal',
    required this.createdAt,
    required this.updatedAt,
  });

  // ─── toMap 
  Map<String, dynamic> toMap() {
    return {
      'siteName':          siteName,
      'siteUrl':           siteUrl,
      'username':          username,
      'encryptedPassword': encryptedPassword,
      'strength':          strength,
      'isBreached':        isBreached,
      'breachCount':       breachCount,
      'category':          category,
      'createdAt':         Timestamp.fromDate(createdAt),
      'updatedAt':         Timestamp.fromDate(updatedAt),
    };
  }

  // ─── fromMap .
  factory PasswordEntry.fromMap(String id, Map<String, dynamic> map) {
    return PasswordEntry(
      id:                 id,
      siteName:           map['siteName']          ?? 'Unknown Site',
      siteUrl:            map['siteUrl']            ?? '',
      username:           map['username']           ?? '',
      encryptedPassword:  map['encryptedPassword']  ?? '',
      strength:           map['strength']           ?? 'Unknown',
      isBreached:         map['isBreached']         ?? false,
      breachCount:        map['breachCount']        ?? 0,
      category:           map['category']           ?? 'Personal',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  // ─── copyWith 
  PasswordEntry copyWith({
    String? siteName,
    String? siteUrl,
    String? username,
    String? encryptedPassword,
    String? strength,
    bool?   isBreached,
    int?    breachCount,
    String? category,
  }) {
    return PasswordEntry(
      id:                id,         // always keep the same ID
      createdAt:         createdAt,  // always keep original creation date
      updatedAt:         DateTime.now(), // update the modified timestamp
      siteName:          siteName          ?? this.siteName,
      siteUrl:           siteUrl           ?? this.siteUrl,
      username:          username          ?? this.username,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      strength:          strength          ?? this.strength,
      isBreached:        isBreached        ?? this.isBreached,
      breachCount:       breachCount       ?? this.breachCount,
      category:          category          ?? this.category,
    );
  }

  // ─── toString
  @override
  String toString() {
    return 'PasswordEntry(id: $id, site: $siteName, user: $username, '
        'strength: $strength, breached: $isBreached)';
  }
}