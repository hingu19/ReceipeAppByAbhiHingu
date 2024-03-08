// views/screens/HomePage.dart
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/controller/data_controller.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/models/helper/recipe_helper.dart';
import 'package:hungry/views/screens/Add_recipe.dart';
import 'package:hungry/views/screens/delicious_today_page.dart';
import 'package:hungry/views/screens/newly_posted_page.dart';
import 'package:hungry/views/screens/profile_page.dart';
import 'package:hungry/views/screens/search_page.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/dummy_search_bar.dart';
import 'package:hungry/views/widgets/featured_recipe_card.dart';
import 'package:hungry/views/widgets/recipe_tile.dart';
import 'package:hungry/views/widgets/recommendation_recipe_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../controller/authController.dart';
import '../../models/user_model.dart';
import 'bookmarks_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Recipe> featuredRecipe = RecipeHelper.featuredRecipe;

  final List<Recipe> recommendationRecipe = RecipeHelper.recommendationRecipe;

  final List<Recipe> newlyPostedRecipe = RecipeHelper.newlyPostedRecipe;

  var dataController = Get.put(DataController());

  @override
  void initState() {
    dataController.refreshPage();
    dataController.fetchRecipeDataModelDataFromFirestore();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hungry?', style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: AppColor.primary,
        actions: [
          // Add Icon Button
          IconButton(
            icon: Icon(Icons.add, color: Colors.white,),
            onPressed: () {
              // Navigate to the AddRecipePage
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddRecipePage()));
            },
          ),
          // Heart Icon Button (Favorites)
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.white,),
            onPressed: () {
              Get.to(()=>BookmarksPage());
              // Handle adding to favorites here
              // You can call a function to add the current recipe to favorites
              // For example: dataController.addToFavorites(currentRecipe);
            },
          ),
          // Profile Photo
          // Profile Photo
          IconButton(
            icon:
            Obx(()=>
            CircleAvatar(
              backgroundImage: dataController.profileImageURL?.isNotEmpty == true
                  ? NetworkImage(dataController.profileImageURL.toString())
                  : null, // Set to null if profileImageURL is empty or null
              child: dataController.profileImageURL?.isEmpty == true
                  ? Icon(Icons.person) // Show an icon if profileImageURL is empty
                  : null , // Set to null if profileImageURL is not empty
            )),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          // Section 1 - Featured Recipe - Wrapper
          Container(
            height: 350,
            color: Colors.white,
            child: Stack(
              children: [
                Container(
                  height: 245,
                  color: AppColor.primary,
                ),
                // Section 1 - Content
                Column(
                  children: [
                    // Search Bar
                    DummySearchBar(
                      routeTo: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchPage()));
                      },
                    ),
                    // Delicious Today - Header
                    Container(
                      margin: EdgeInsets.only(top: 12),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delicious Today',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'inter'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => DeliciousTodayPage()));
                            },
                            child: Text('see all'),
                            style: TextButton.styleFrom(primary: Colors.white, textStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                    // Delicious Today - ListView
                    Container(
                      margin: EdgeInsets.only(top: 6),
                      height: 220,
                      child: ListView.separated(
                        itemCount: featuredRecipe.length,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            width: 16,
                          );
                        },
                        itemBuilder: (context, index) {
                          return FeaturedRecipeCard(data: featuredRecipe[index]);
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          // Section 2 - Recommendation Recipe
          Container(
            margin: EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Today recommendation based on your taste...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                // Content

                Container(
                  height: 174,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendationRecipe.length,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (context, index) {
                      return SizedBox(width: 16);
                    },
                    itemBuilder: (context, index) {
                      return RecommendationRecipeCard(data: recommendationRecipe[index]);
                    },
                  ),
                )
              ],
            ),
          ),
          // Section 3 - Newly Posted
          Container(
            margin: EdgeInsets.only(top: 14),
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap:(){
                        dataController.fetchRecipeDataModelDataFromFirestore();

                      },
                      child: Text(
                        'Newly Posted',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'inter'),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewlyPostedPage()));
                      },
                      child: Text('see all'),
                      style: TextButton.styleFrom(primary: Colors.black, textStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
                    ),
                  ],
                ),
                // Content
                Obx(() =>
                    ListView.separated(
                      shrinkWrap: true,
                      itemCount: dataController.recipeList.value.length,
                      physics: NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 16);
                      },
                      itemBuilder: (context, index) {
                        return RecipeTile(
                          data: newlyPostedRecipe[index],
                          recipeDataModel: dataController.recipeList.value[index],
                        );
                      },
                    ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
