import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/receipe_data_model.dart';
import '../models/user_model.dart';
import '../util/colors.dart';
import '../util/common_methods.dart';
import 'authController.dart';

class DataController extends  GetxController{
  RxString profileImageURL=''.obs;
  RxString filterName = "Newest".obs;
  String adminEmail = "recipesharinga@gmail.com";

  void updateProfileImageURL(String newURL){
    profileImageURL.value = newURL;
  }
  var authController = Get.put(AuthController());


  RxList<RecipeModel> recipeList = <RecipeModel>[].obs;
  RxList<RecipeModel> searchRecipeList = <RecipeModel>[].obs;
  RxList<RecipeModel> favoriteRecipeDataList = <RecipeModel>[].obs;
  RxList<RecipeModel> myRecipeDataList = <RecipeModel>[].obs;
  get profilepageURL => null;

  UserModel? currentUser ;
  User? user = FirebaseAuth.instance.currentUser;


  Future refreshPage() async {
    user = await authController.getCurrentUser();
    log('----currentUser-----${user.toString()}');
    if (user != null) {
     currentUser = await authController.getUserById(user!.uid);
      if (currentUser != null) {
        // emailController.text = currentUser!.email.toString();
        // if (user.name != null) {
        //   nameController.text = user.name.toString();
        // }
        if(currentUser!.profileUrl != null){
          updateProfileImageURL(currentUser!.profileUrl.toString());
        }

      }
    }
  }


  Future<List<RecipeModel>> filterRecipes(String query) async {
    log("---filterRecipes----$query");
    List<RecipeModel> filteredList = searchRecipeList.value.where((recipe) {
      // Here you can define your search logic
      return recipe.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (filterName.value == "Newest") {
      filteredList.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sorting by newest date
    } else if( (filterName.value == "Oldest")) {
      filteredList.sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Sorting by oldest date
    }

    searchRecipeList.value = filteredList; // Assigning the filtered and sorted list to searchRecipeList
    log("---searchRecipeList----${searchRecipeList.value.length}");

    return filteredList; // Return the filtered and sorted list
  }
  Future<List<RecipeModel>> fetchRecipeDataModelDataFromFirestore() async {
    log('-----isAdmin----->>$user!email==adminEmail');
    // Fetch data from Firestore and create a list of RecipeDataModel objects
    // Assume 'catadd' is the collection name in Firestore

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('recipes').get();

    List<RecipeModel> recipeDataModelList = querySnapshot.docs.map((doc) {
      // Fetch image URL using fetchImageUrl function
      return RecipeModel.fromMap({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      });
    }).toList();
    // if(user!.email==adminEmail) {
      recipeList.value = recipeDataModelList;
      searchRecipeList.value = recipeDataModelList;
      favoriteRecipeDataList.value = recipeDataModelList.where((pet) =>
          pet.favorite!.contains(user!.uid)).toList();
      myRecipeDataList.value =
          recipeDataModelList.where((pet) => pet.userId == user!.uid)
              .toList();
    // }
    update();
    log("----fetchRecipeDataModelDataFromFirestor"
        "e----");
    log("----RecipeDataModelList----" + recipeDataModelList.length.toString());


    return recipeDataModelList;
  }


  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  Future<void> addOrUpdateUserData(UserModel userModel) async {
    log('-----addOrUpdateUserData------');
    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    // Check if the user document already exists
    DocumentSnapshot userSnapshot = await users.doc(userModel.id).get();

    // Convert UserModel object to a map without null values
    Map<String, dynamic> userDataMap = userModel.toUpdateMap();
    log(("------userDataMap----->> ${userDataMap.toString()}"));
    if (userSnapshot.exists) {
      // User document exists, update the username field
      await users.doc(userModel.id).update(userModel.toMap());
    } else {
      // User document doesn't exist, create a new document
      await users.doc(userModel.id).set(userModel.toMap());
    }
    CommonMethod()
        .getXSnackBar("Success", "Profile upadate successfully", success);
  }

  Future<bool> isUserIdInFavorite(String recipeId, String userId) async {
    try {
      // Get the reference to the document in Firestore
      DocumentSnapshot petSnapshot = await FirebaseFirestore.instance.collection('recipes').doc(recipeId).get();

      // Check if the document exists
      if (petSnapshot.exists) {
        // Get the data from the document
        Map<String, dynamic>? petData = petSnapshot.data() as Map<String, dynamic>?;

        // Check if the 'favorite' field exists and if it contains the userId
        if (petData != null && petData['favorite'] is List<dynamic>) {
          return (petData['favorite'] as List<dynamic>).contains(userId);
        }
      }
      // Return false if the document doesn't exist or 'favorite' field is not found
      return false;
    } catch (error) {
      print('Error checking if userId is in favorite: $error');
      return false;
    }
  }


  Future<void> updateRecipeDataInFirestore(String recipeId, RecipeModel recipeModel, String userId) async {
    print("-----updateRecipeDataInFirestore------");

    try {
      // Ensure the favorite array is not null
      recipeModel.favorite ??= [];

      // Get the reference to the document in Firestore
      DocumentReference recipeRef = FirebaseFirestore.instance.collection('recipes').doc(recipeId);

      // If userId exists in the favorite array, remove it; otherwise, add it
      if (recipeModel.favorite!.contains(userId)) {
        print("-----updateRecipeDataInFirestore------if");
        recipeModel.favorite!.remove(userId);
      } else {
        print("-----updateRecipeDataInFirestore------else");
        recipeModel.favorite!.add(userId);
      }

      // Convert RecipeModel object to map
      Map<String, dynamic> dataToUpdate = recipeModel.toJson();

      // Update the document with the new data
      await recipeRef.update(dataToUpdate);
      print('Document with ID $recipeId successfully updated.');
    } catch (error) {
      print('Error updating document: $error');
    }
  }


  Future<void> addReviews(String recipeId, RecipeModel recipeModel, String reviewTxt) async {
    print("-----updateRecipeDataInFirestore------");

    try {
      // Ensure the reviews array is not null
      recipeModel.reviews ??= [];

      // Get the reference to the document in Firestore
      DocumentReference recipeRef = FirebaseFirestore.instance.collection('recipes').doc(recipeId);
log('---currentUser---${user.toString()}');
      // Add the review to the reviews array
      recipeModel.reviews!.add({
        'userId': user!.uid,
        'name': user!.email,
        'review': reviewTxt,
      });

      // Convert RecipeModel object to map
      Map<String, dynamic> dataToUpdate = recipeModel.toJson();

      // Update the document with the new data
      await recipeRef.update(dataToUpdate);
      Get.back();
      print('Document with ID $recipeId successfully updated.');
    } catch (error) {
      print('Error updating document: $error');
    }
  }


// Save Recipe to Firestore
  // Future<void> saveToFirestore(RecipeDataModel model) async {
  //   try {
  //     // Access the Firestore instance
  //     FirebaseFirestore firestore = FirebaseFirestore.instance;
  //
  //     // Create a new document reference with an auto-generated ID
  //     DocumentReference recipeRef = await firestore.collection('recipes').add(toMap());
  //
  //     print('Recipe saved to Firestore with ID: ${recipeRef.id}');
  //   } catch (e) {
  //     print('Error saving recipe to Firestore: $e');
  //   }
  // }

}