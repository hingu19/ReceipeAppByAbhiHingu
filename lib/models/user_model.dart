import 'package:flutter/cupertino.dart';

/// Represents a user model with basic information.
class UserModel {
  final String id;
  final String email;
  final String? password;
  final String? profileUrl;
  final String? name;

  const UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.profileUrl,
    required this.name,
  });

  /// Constructs a UserModel instance from a map.
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      password: data['password'],
      profileUrl: data['profileUrl'],
      name: data['name'] ,
    );
  }
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'email': email,
      'profileUrl': profileUrl,
      'name': name,
    };

    map.removeWhere((key, value) => value == null );

    return map;
  }
  /// Converts UserModel instance to a map for updating, removing null or empty values.
  Map<String, dynamic> toUpdateMap() {
    final map = toMap();
    map.removeWhere((key, value) => value == null || value is List && value.isEmpty);
    return map;
  }
}

/// Represents a language with an ID, flag emoji, name, and language code.
class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;

  Language(this.id, this.flag, this.name, this.languageCode);

  /// Returns a list of supported languages.
  static List<Language> languageList() {
    return <Language>[
      Language(1, "🇦🇫", "فارسی", "fa"),
      Language(2, "🇺🇸", "English", "en"),
      Language(3, "🇸🇦", "اَلْعَرَبِيَّةُ", "ar"),
      Language(4, "🇮🇳", "हिंदी", "hi")
    ];
  }
}
