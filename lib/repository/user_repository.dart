import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  createUser(UserModel user) async {
    log("----createUser----");
    log("----createUser1111---- $user");
    await _db.collection("Users").doc(user.id).set(user.toMap()).then(
          (value) {
        Get.snackbar(
          "Success",
          "Your account has been created.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      },
      onError: (error, stackTrace) {
        Get.snackbar(
          "Error",
          "Something Went Wrong.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red,
        );
        print(error.toString());
      },
    );
  }

  // createProfile(InfoModel profile) async {
  //   log("----createProfile----");
  //   log("----createProfile1111---- $profile");
  //   await _db.collection("Profile").add(profile.toJson()).then(
  //         (value) {
  //       Get.snackbar(
  //         "Success",
  //         "Your Profile has been created.",
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.green.withOpacity(0.1),
  //         colorText: Colors.green,
  //       );
  //     },
  //     onError: (error, stackTrace) {
  //       Get.snackbar(
  //         "Error",
  //         "Something Went Wrong.",
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.redAccent.withOpacity(0.1),
  //         colorText: Colors.red,
  //       );
  //       print(error.toString());
  //     },
  //   );
  // }

}