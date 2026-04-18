import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/password_entry.dart';

class FirestoreService {

  // ─── Private helpers ──────────────────────────────────────────────────

  // Gets the Firestore instance
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Gets the current logged-in user's unique ID
  // The '!' means we are sure a user is logged in when this is called
  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // Builds the reference to THIS user's passwords subcollection
  // Path: users -> {uid} -> passwords
  // Every user gets their own isolated subcollection — they cannot see each other's data
  static CollectionReference<Map<String, dynamic>> get _passwordsRef =>
      _db.collection('users').doc(_uid).collection('passwords');


  // ─── READ: Stream of all passwords (real-time) ────────────────────────
  // Returns a Stream — every time Firestore data changes, the UI rebuilds
  // automatically. No need to manually refresh or call fetch again.
  // Ordered by createdAt so newest entries appear at the top.
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


  // ─── CREATE: Add a new password entry ────────────────────────────────
  // .add() tells Firestore to create a new document and auto-generate an ID
  // We pass entry.toMap() which converts the Dart object to a plain Map
  static Future<void> addPassword(PasswordEntry entry) async {
    try {
      await _passwordsRef.add(entry.toMap());
    } catch (e) {
      throw Exception('Failed to save password: $e');
    }
  }


  // ─── UPDATE: Edit an existing password entry ─────────────────────────
  // .doc(id) targets the specific document we want to change
  // .update() only changes the fields we pass — other fields stay the same
  static Future<void> updatePassword(String id, PasswordEntry entry) async {
    try {
      await _passwordsRef.doc(id).update(entry.toMap());
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }


  // ─── DELETE: Remove a password entry permanently ──────────────────────
  static Future<void> deletePassword(String id) async {
    try {
      await _passwordsRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete password: $e');
    }
  }


  // ─── READ ONCE: Get all passwords as a one-time fetch ─────────────────
  // Unlike getPasswordsStream(), this fetches once and stops.
  // Useful for the dashboard where you need a snapshot to calculate stats.
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


  // ─── SEARCH: Filter entries by site name or username ──────────────────
  // Note: Firestore does not support full text search natively.
  // So we load all entries and filter in Dart (fine for small collections).
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