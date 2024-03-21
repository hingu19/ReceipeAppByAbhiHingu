import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:hungry/controller/authController.dart';
import 'package:hungry/views/screens/reports.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/custom_text_field.dart';
import 'package:hungry/views/widgets/modals/register_modal.dart';
import '../../../repository/user_repository.dart';
import '../../../util/colors.dart';
import '../../../util/common_methods.dart';
import '../../utils/shadow_container_widget.dart';

class LoginModal extends StatefulWidget {
  @override
  State<LoginModal> createState() => LoginModalState();
}

class LoginModalState extends State<LoginModal> {
  var controller = Get.put(AuthController());
  var usercontroller = Get.put(UserRepository());
  final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isEmailValid = true;
  bool isPasswordValid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  margin: EdgeInsets.only(bottom: 20),
                  height: 6,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(20)),
                ),
              ),
              Text(
                'Login',
                style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w700, fontFamily: 'inter'),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              CustomTextField(
                title: 'Email',
                controller: controller.emailController,
                hint: 'youremail@email.com',
                onChanged: (value) {
                  setState(() {
                    isEmailValid = validateEmail(value);
                  });
                },
                errorText: isEmailValid ? null : 'Enter a valid email',
              ),
              CustomTextField(
                title: 'Password',
                hint: '**********',
                obsecureText: true,
                controller: controller.passwordController,
                margin: EdgeInsets.only(top: 16),
                onChanged: (value) {
                  setState(() {
                    isPasswordValid = validatePassword(value);
                  });
                },
                errorText: isPasswordValid ? null : 'Password must be at least 6 characters',
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  print("==========================email:------${controller.emailController.text.toString()}=====================================");
                  print("==========================pass:-------${controller.passwordController.text.toString()}=====================================");
                  if (controller.emailController.text.isEmpty) {
                    showCustomSnackBar(context, 'Please enter email', red);
                  }else if (!emailRegex.hasMatch(controller.emailController.text)) {
                    showCustomSnackBar(context, 'Please enter valid email', red);
                  } else if (controller.passwordController.text.isEmpty) {
                    showCustomSnackBar(context, 'Please enter password', red);
                  }
                  else {
                    await _auth.signOut().whenComplete(() =>
                    controller.signInWithEmailAndPassword(context));
                  }
                },
                child: Text('Login', style: TextStyle(color: AppColor.secondary, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'inter')),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  primary: AppColor.primarySoft,
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  if (controller.emailController.text.isEmpty) {
                    showCustomSnackBar(context, 'Please enter your email', red);
                  } else {
                    sendPasswordResetEmail(controller.emailController.text);
                  }
                },
                style: TextButton.styleFrom(primary: Colors.white),
                child: Text(
                  'Forgot your password?',
                  style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.w700, fontFamily: 'inter'),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  controller.handleSignInGoogle();
                },
                child: Text(
                  'Login with Google',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool validateEmail(String email) {
    return emailRegex.hasMatch(email);
  }

  bool validatePassword(String password) {
    return password.length >= 6;
  }

  void showCustomSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(16),
          height: 90,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  void sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showCustomSnackBar(context, 'Password reset email sent. Check your email inbox.', Colors.green);
    } catch (e) {
      print('Error sending password reset email: $e');
      showCustomSnackBar(context, 'Failed to send password reset email. Please try again later.', red);
    }
  }
}
