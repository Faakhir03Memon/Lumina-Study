import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lumina_study/shared/services/database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Auth State Stream
  Stream<User?> get userStream => _auth.authStateChanges();

  // Current User
  User? get currentUser => _auth.currentUser;

  // Sign In with Email & Password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign Up with Email & Password
  Future<UserCredential?> signUpWithEmail(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user document in Firestore
        await DatabaseService().createUser(
          uid: credential.user!.uid,
          email: email,
          name: name,
        );
      }
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign In with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await DatabaseService().createUser(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName ?? 'Student',
          photoUrl: userCredential.user!.photoURL,
        );
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign In with GitHub
  Future<UserCredential?> signInWithGitHub() async {
    try {
      final GithubAuthProvider githubProvider = GithubAuthProvider();
      final UserCredential userCredential = await _auth.signInWithProvider(githubProvider);

      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await DatabaseService().createUser(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          name: userCredential.user!.displayName ?? 'Dev Student',
          photoUrl: userCredential.user!.photoURL,
        );
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
