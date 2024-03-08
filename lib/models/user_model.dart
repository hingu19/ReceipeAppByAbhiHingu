import 'package:flutter/cupertino.dart';


class UserModel {
  final String id;
  final String email;
  final String? password;
  final String? profileUrl;
  final String? name;

  const UserModel({
    required this.id,
    required this.email,
    this.password,
    this.profileUrl,
    this.name,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      email: data['email'],
      password: data['password'],
      profileUrl: data['profileUrl'],
      name: data['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) "id": id,
      if (email != null) "email": email,
      if (password != null) "password": password,
      if (profileUrl != null) "profileUrl": profileUrl,
      if (name != null) "name": name,
    };
  }

  // Map<String, dynamic> toUpdateMap() {
  //   Map<String, dynamic> map = toMap();
  //   map.removeWhere((key, value) => value == null);
  //   return map;
  // }

  Map<String, dynamic> toUpdateMap() {
    Map<String, dynamic> map = toMap();
    map.removeWhere(
            (key, value) => value == null || value is List && value.isEmpty);
    return map;
  }
}


