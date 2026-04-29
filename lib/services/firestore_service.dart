import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/password_entry.dart';

class FirestoreService {

  // ─── Private helpers ──────────────────────────────────────────────────

  // Gets the Firestore instance
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  static CollectionReference<Map<String, dynamic>> get _passwordsRef =>
      _db.collection('users').doc(_uid).collection('passwords');


  // ─── READ: Stream of all passwords (real-time)
  static Stream<List<PasswordEntry>> getPasswordsStream() {
    return _passwordsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return PasswordEntry.fromMap(
              doc.id,                             // the Firestore document ID
              // ignore: unnecessary_cast
              doc.data() as Map<String, dynamic>, // the fields inside the document
            );
          }).toList();
        });
  }


  // ─── CREATE: Add a new password entry
  static Future<void> addPassword(PasswordEntry entry) async {
    try {
      await _passwordsRef.add(entry.toMap());
    } catch (e) {
      throw Exception('Failed to save password: $e');
    }
  }


  // ─── UPDATE: Edit an existing password entry 
  static Future<void> updatePassword(String id, PasswordEntry entry) async {
    try {
      await _passwordsRef.doc(id).update(entry.toMap());
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }


  // ─── DELETE: Remove a password entry permanently
  static Future<void> deletePassword(String id) async {
    try {
      await _passwordsRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete password: $e');
    }
  }


  // ─── READ ONCE: Get all passwords as a one-time fetch
  static Future<List<PasswordEntry>> getPasswordsOnce() async {
    try {
      final snapshot = await _passwordsRef
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => PasswordEntry.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to load passwords: $e');
    }
  }


  // ─── SEARCH: Filter entries by site name or username 
  static Future<List<PasswordEntry>> searchPasswords(String query) async {
    final all = await getPasswordsOnce();
    final q = query.toLowerCase();
    return all.where((e) {
      return e.siteName.toLowerCase().contains(q) ||
             e.username.toLowerCase().contains(q) ||
             e.category.toLowerCase().contains(q);
    }).toList();
  }
}