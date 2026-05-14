import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Rx<User?> firebaseUser; //rx variable
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onReady() {
    super.onReady();

    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.authStateChanges());
    Future.delayed(const Duration(seconds: 2), () {
      _setInitialScreen(firebaseUser.value);
      ever(firebaseUser, _setInitialScreen);
    });
  }

  //route
  Future<void> _setInitialScreen(User? user) async {
    if (user == null) {
      Get.offAllNamed('/login');
    } else {
      await fetchUserData(user.uid);
      Get.offAllNamed('/dashboard-shell');
    }
  }

  //fetch
  Future<void> fetchUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        currentUser.value = UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user data: $e');
    }
  }

  //new user
  Future<void> register(String email, String password, String name) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      UserModel newUser = UserModel.defaultUser(cred.user!.uid, name);
      await _firestore.collection('users').doc(cred.user!.uid).set(newUser.toMap());

      currentUser.value = newUser;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Registration Failed', e.message ?? 'An error occurred', snackPosition: SnackPosition.BOTTOM);
    }
  }

  //login
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login Failed', e.message ?? 'An error occurred', snackPosition: SnackPosition.BOTTOM);
    }
  }

  //logout
  Future<void> logout() async {
    await _auth.signOut();
    currentUser.value = null;
  }
}