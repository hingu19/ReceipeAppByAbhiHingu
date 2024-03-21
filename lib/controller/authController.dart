import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/views/screens/home_page.dart';
import 'package:hungry/views/screens/reports.dart';
import 'package:hungry/views/widgets/modals/login_modal.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';
import '../models/user_model.dart';
import '../repository/user_repository.dart';
import '../util/colors.dart';
import '../util/common_methods.dart';
import '../views/widgets/modals/personal_information.dart';

class AuthController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  // final UserRepository userRepo;

  // AuthController(this.userRepo); // Constructor with UserRepository dependency

  Future clearForm() async {
    emailController.clear();
    passwordController.clear();
    passwordController.clear();
  }

  Future<bool> isUserSignedIn() async {
    return _auth.currentUser != null;
  }

  Future<void> registerWithEmailAndPassword(BuildContext context) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (userCredential.user != null) {
        User user = userCredential.user!;
        await userCredential.user!.sendEmailVerification().whenComplete(() async =>


        await StoreData().addOrUpdateUserData(UserModel(
          id: user.uid.toString(),
          email:  user.email.toString().trim(),
          name: null,
          profileUrl: null, password: null,
        )));
            // saveUserDetails(UserModel(
            //     id: user.uid.toString(),
            //     email: user.email.toString().trim(),
            //     password: passwordController.text)));

        await CommonMethod().getXSnackBar(
          "Success",
          'Verification email sent to ${userCredential.user!.email}',
          Colors.green,
        ).then((value) => Get.to(() => LoginModal()));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        await CommonMethod().getXSnackBar(
          "Error",
          'The email address is already in use. Please use a different email.',
          Colors.red,
        );
      } else if (e.code == 'weak-password') {
        await CommonMethod().getXSnackBar(
          "Error",
          'The password provided is too weak. Please choose a stronger password.',
          Colors.red,
        );
      } else {
        await CommonMethod().getXSnackBar(
          "Error",
          'Failed to register: ${e.message}',
          Colors.red,
        );
      }
    }
  }

  Future<void> saveUserDetails(UserModel user) async {
    userRepo.createUser(user);
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        return UserModel.fromMap(
            userSnapshot.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print("Error retrieving user data: $e");
      return null;
    }
  }

  Future<User?> getCurrentUser() async {
    User? user = await _auth.currentUser;

    if (user != null) {
      String userId = user.uid;
      print('-----Current User ID: $userId');
      return user;
    } else {
      print('----User is not signed in.');
    }
  }

  Future<String?> signInWithEmailAndPassword(BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim().toString(),
          password: passwordController.text);

      if (userCredential.user!.emailVerified) {
        // saveUserDetails(UserModel(id: userCredential.user!.uid.toString(),
        //     email: userCredential.user!.email.toString().trim(),
        //     password: passwordController.text, profileUrl:null, name: null));
        if(emailController.text == "recipesharinga@gmail.com" && passwordController.text == "Admin@01"){
          print("==================Entering email:-${emailController}");
          print("==================Entering pass:-${passwordController}");
          await CommonMethod()
              .getXSnackBar("Success", 'You are redirect to admin dashboard', success)
              .whenComplete(() => Get.to(() => AdminPage()));
        }
        else {
          await CommonMethod()
              .getXSnackBar("Success", 'Sign-in successfully', success)
              .whenComplete(() => Get.to(() => HomePage()));
        }
      } else {
        await CommonMethod().getXSnackBar(
            "Error",
            'Email not verified. Check your inbox for the verification email.',
            red);
        print('');
      }
    } on FirebaseAuthException catch (e) {
      await CommonMethod()
          .getXSnackBar("Error", 'Failed to sign in: ${e.message}', red);
    }
  }

  Future<User?> handleSignInGoogle() async {
    try {
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleSignInAccount =
      await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        await CommonMethod()
            .getXSnackBar("Info", 'Google Sign-In canceled by user', red);
        return null;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
      await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        saveUserDetails(UserModel(id: user.uid.toString(),
            email: user.email.toString().trim(),
            password: passwordController.text, profileUrl: null, name: null));
        await CommonMethod()
            .getXSnackBar("Success", 'Signed in: ${user.displayName}', success)
            .whenComplete(() => Get.to(() => HomePage()));
      }

      return user;
    } catch (error) {
      if (error is FirebaseAuthException) {
        await CommonMethod().getXSnackBar(
            "Error", 'Firebase Auth Error: ${error.message}', red);
      } else {
        await CommonMethod()
            .getXSnackBar("Error", 'Error signing in with Google: $error', red);
      }
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      CommonMethod().getXSnackBar("Error", 'Error signing out: $e', red);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Failed to send password reset email: $e");
    }
  }

  void getUserInfo() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('user').doc(uid).snapshots().listen((event) {});
  }
}

// Instantiate UserRepository
final userRepo = UserRepository();

