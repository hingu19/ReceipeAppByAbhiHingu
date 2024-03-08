import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String title;
  final String calories;
  final String time;
  final String description;
  final String tutorial;
  List<String> favorite;
  final List<Map<String, dynamic>> ingredients;
   List<Map<String, dynamic>> reviews;
  final List<String> tutorialSteps;
  final DateTime timestamp; // Timestamp field

  RecipeModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.title,
    required this.calories,
    required this.time,
    required this.favorite,
    required this.reviews,
    required this.description,
    required this.tutorial,
    required this.ingredients,
    required this.tutorialSteps,
    required this.timestamp, // Add timestamp field to constructor
  });

  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    // Ensure that the expected fields are present and of the correct type
    List<String>? favorites = (map['favorite'] as List<dynamic>?)?.map((e) => e.toString()).toList();

    if (
    map['id'] is String &&
        map['userId'] is String &&
        map['title'] is String &&
        map['calories'] is String &&
        map['time'] is String &&
        map['description'] is String &&
        map['tutorial'] is String &&
        map['imageUrl'] is String &&
        map['timestamp'] is Timestamp) { // Check if recipeDate is present and of correct type
      return RecipeModel(
        id: map['id'],
        userId: map['userId'],
        title: map['title'],
        calories: map['calories'],
        time: map['time'],
        description: map['description'],
        favorite: favorites ?? [],
        tutorial: map['tutorial'],
        imageUrl: map['imageUrl'],
        ingredients: List<Map<String, dynamic>>.from(map['ingredients']),
        reviews: (map['reviews'] != null) ? List<Map<String, dynamic>>.from(map['reviews']) : [],
        tutorialSteps: List<String>.from(map['tutorialSteps']),
        timestamp: (map['timestamp'] as Timestamp).toDate(), // Parse timestamp
      );
    } else {
      // Handle unexpected data format
      throw FormatException('Invalid data format for RecipeModel');
    }
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'title': title,
      'calories': calories,
      'time': time,
      'favorite': favorite,
      'description': description,
      'tutorial': tutorial,
      'ingredients': ingredients,
      'tutorialSteps': tutorialSteps,
      'reviews': reviews,
      'timestamp': timestamp,
    };

    // Remove key-value pairs with null or empty string values
    json.removeWhere((key, value) => value == null || value == '');
    return json;

  }


}
