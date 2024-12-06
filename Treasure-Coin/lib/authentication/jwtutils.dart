import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JWTUtils {
  // Method to generate and store JWT in Firestore
  static Future<String?> generateAndStoreJWT(User user) async {
    try {
      // Get the ID token (JWT) from Firebase
      String? idToken = await user.getIdToken();

      // Store the token in Firestore with a timestamp
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'jwt': idToken,
        'jwtCreatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merges fields to avoid overwriting other user data

      return idToken;
    } catch (e) {
      throw Exception("Error generating and storing JWT: $e");
    }
  }

  // Method to retrieve the stored JWT from Firestore
  static Future<String?> getStoredJWT(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['jwt'] as String?;
      }
      return null; // Document doesn't exist or data is null
    } catch (e) {
      throw Exception("Error retrieving stored JWT: $e");
    }
  }

  // Method to check if the stored JWT is still valid (less than 1 hour old)
  static Future<bool> isJWTValid(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        Timestamp? createdAt = data['jwtCreatedAt'] as Timestamp?;

        if (createdAt != null) {
          // Check if the JWT is less than 1 hour old
          return DateTime.now().difference(createdAt.toDate()).inHours < 1;
        }
      }
      return false; // Document doesn't exist or no createdAt field
    } catch (e) {
      throw Exception("Error checking JWT validity: $e");
    }
  }
}
