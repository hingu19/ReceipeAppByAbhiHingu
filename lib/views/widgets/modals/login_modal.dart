import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/controller/authController.dart';
import 'package:hungry/views/screens/page_switcher.dart';
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
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

  bool isEmailValid = true;
  bool isPasswordValid = true;

  get child => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Wrap(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 85 / 100,
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 35,
                    margin: EdgeInsets.only(bottom: 20),
                    height: 6,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                // header
                Container(
                  margin: EdgeInsets.only(bottom: 24),
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w700, fontFamily: 'inter'),
                  ),
                ),
                // Form
                CustomTextField(
                  title: 'Email',
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
                  margin: EdgeInsets.only(top: 16),
                  onChanged: (value) {
                    setState(() {
                      isPasswordValid = validatePassword(value);
                    });
                  },
                  errorText: isPasswordValid ? null : 'Password must be at least 6 characters',
                ),

                // Log in Button
                Container(
                  margin: EdgeInsets.only(top: 32, bottom: 6),
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.emailController.text.isEmpty) {
                        showCustomSnackBar(context, 'Please enter email', red);
                      } else if (!emailRegex.hasMatch(controller.emailController.text)) {
                        showCustomSnackBar(context, 'Please enter valid email', red);
                      } else if (controller.passwordController.text.isEmpty) {
                        showCustomSnackBar(context, 'Please enter password', red);
                      } else {
                        controller.signInWithEmailAndPassword(context);
                      }
                    },
                    child: Text('Login', style: TextStyle(color: AppColor.secondary, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'inter')),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      primary: AppColor.primarySoft,
                    ),
                  ),
                ),

                ShadowContainerWidget(
                  padding: 0,
                  widget: SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sign In with Google')
                        // Add more widgets if needed
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle forgot password logic
                  },
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Forgot your password? ',
                      style: TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(
                          style: TextStyle(
                            color: AppColor.primary,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'inter',
                          ),
                          text: 'Reset',
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  bool validateEmail(String email) {
    // Use a regular expression for basic email validation
    RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }

  bool validatePassword(String password) {
    // Password must be at least 6 characters
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
}
