import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── User Management ────────────────────────────────────────────────────────
  Future<void> createUser({
    required String uid,
    required String email,
    required String name,
    String? photoUrl,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': name,
      'photoURL': photoUrl,
      'plan': 'Free',
      'credits': 20,
      'createdAt': FieldValue.serverTimestamp(),
      'role': email == 'admin@faakhir.com' ? 'admin' : 'user',
    });
  }

  Future<DocumentSnapshot> getUser(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  // ── Usage Tracking ────────────────────────────────────────────────────────
  Future<void> logUsage(String uid, String feature) async {
    final userRef = _db.collection('users').doc(uid);
    
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final int currentCredits = data['credits'] ?? 0;

      if (currentCredits > 0 || data['plan'] == 'Pro') {
        if (data['plan'] != 'Pro') {
          transaction.update(userRef, {'credits': currentCredits - 1});
        }
        
        // Log activity
        final logRef = _db.collection('usage_logs').doc();
        transaction.set(logRef, {
          'userId': uid,
          'feature': feature,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // ── Chat Persistence ────────────────────────────────────────────────────────
  Future<String> createChatSession(String uid, String title) async {
    final doc = await _db.collection('chats').add({
      'userId': uid,
      'title': title,
      'lastUpdated': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> saveMessage(String chatId, String role, String content) async {
    await _db.collection('chats').doc(chatId).collection('messages').add({
      'role': role,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    await _db.collection('chats').doc(chatId).update({
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // ── Admin Panel Queries ───────────────────────────────────────────────────
  Stream<QuerySnapshot> getAllUsers() {
    return _db.collection('users').orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getUsageLogs() {
    return _db.collection('usage_logs').orderBy('timestamp', descending: true).limit(50).snapshots();
  }

  Future<Map<String, dynamic>> getGlobalStats() async {
    final users = await _db.collection('users').count().get();
    final logs = await _db.collection('usage_logs').count().get();
    
    return {
      'totalUsers': users.count,
      'totalRequests': logs.count,
    };
  }
}
