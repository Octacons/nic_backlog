import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nic_backlog/data/model/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registerUser({
    required String username,
    required String password,
    required String email,
  }) async {
    try {
      final cleanUsername = username.trim().toLowerCase();
      final cleanEmail = email.trim().toLowerCase();

      final usernameCheck = await _firestore
          .collection('users')
          .where('username', isEqualTo: cleanUsername)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        return "Username sudah dipakai, cari username lain.";
      }

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final uid = credential.user!.uid;

      UserModel newUser = UserModel(
        uid: uid,
        username: cleanUsername,
        email: cleanEmail,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Terjadi kesalahan pada pendaftaran akun.";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> loginUser({
    required String input,
    required String password,
  }) async {
    try {
      final cleanInput = input.trim().toLowerCase();
      String targetEmail = cleanInput;

      if (!cleanInput.contains('@')) {
        final usernameQuery = await _firestore
            .collection('users')
            .where('username', isEqualTo: cleanInput)
            .get();

        if (usernameQuery.docs.isEmpty) {
          return "Username tidak ditemukan.";
        }

        targetEmail = usernameQuery.docs.first.data()['email'] as String;
      }

      await _auth.signInWithEmailAndPassword(
        email: targetEmail,
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return "Password yang kamu masukkan salah.";
      } else if (e.code == 'user-not-found') {
        return "Akun tidak terdaftar.";
      }
      return e.message ?? "Gagal melakukan login.";
    } catch (e) {
      return e.toString();
    }
  }
}
