import 'package:cloud_firestore/cloud_firestore.dart';

class AiUsageTracking {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Plan limits
  static const Map<String, int> planLimits = {
    'FREE': 10,
    'STARTER': 100,
    'PRO': 1000,
  };

  Future<void> checkAndIncrementUsage(String userId, String companyId, String plan) async {
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month}';
    final docId = '${companyId}_$monthKey';
    
    final docRef = _firestore.collection('ai_usage').doc(docId);
    final doc = await docRef.get();
    
    int used = 0;
    if (doc.exists) {
      used = doc.data()?['used'] ?? 0;
    }

    final limit = planLimits[plan] ?? 10;
    
    if (used >= limit) {
      throw Exception('AI generation limit exceeded for your $plan plan ($limit/month). Please upgrade your subscription.');
    }

    // Increment usage
    await docRef.set({
      'userId': userId,
      'companyId': companyId,
      'month': monthKey,
      'used': used + 1,
      'limit': limit,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> getUsage(String companyId) async {
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month}';
    final docId = '${companyId}_$monthKey';
    
    final doc = await _firestore.collection('ai_usage').doc(docId).get();
    if (doc.exists) {
      return doc.data()!;
    }
    return {'used': 0, 'limit': 10};
  }
}
