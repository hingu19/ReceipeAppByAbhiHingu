import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hungry/models/receipe_data_model.dart';
import 'package:hungry/util/colors.dart';
import 'package:hungry/utils/image_widget.dart';
import 'package:hungry/views/utils/shadow_container_widget.dart';
import 'package:hungry/views/widgets/app_text_style.dart';

import '../../models/core/recipe.dart';
import '../../models/helper/recipe_helper.dart';
import '../../models/user_model.dart';
import '../utils/AppColor.dart';
import '../widgets/recipe_tile.dart';
import 'auth/welcome_page.dart';



class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      DefaultTabController(
        length: 3, // Number of tabs
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColor.primary,

            title: Row(
              children: [
                Expanded(child: Text('Admin DashBoard',style: AppTextStyle.homeAppbarTextStyle.copyWith(color: primaryWhite),)),
                InkWell(
                    onTap: () async {

                      await FirebaseAuth.instance.signOut().whenComplete(() =>
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => WelcomePage(),
                            ),
                          ));
                    },

                    child: Icon(Icons.logout,color: primaryWhite,))
              ],
            ),
            bottom: TabBar(
              labelColor: primaryWhite,
              unselectedLabelColor: primaryWhite.withOpacity(.5),
              unselectedLabelStyle: AppTextStyle.normalRegular14
              ,
              tabs: [
                Tab(text: 'Users',), // Define each tab
                Tab(text: 'Recipes'),

                Tab(text: 'Overview'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              userListWidget(),
              recipeListWidget(),
              Center(child: Text('Tab 3 Content')),
            ],
          ),
        ),
      ),);
    }


  Widget userListWidget() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Users').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError || snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Display data
        return SizedBox(
          // height: 200,
          child: ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              // Access UserModel from document
              final UserModel user = UserModel.fromMap(document.data() as Map<String, dynamic>);

              // Display user data
              return ListTile(
                leading:NetworkImageWidget(imageUrl: user.profileUrl ?? '',height: 50,width: 50,borderRadius: BorderRadius.circular(50),),
                title: Text(user.email), // Display email or other appropriate field
                subtitle: Text(user.name ?? ''), // Display name or fallback to empty string
              );
            }).toList(),
          ),
        );
      },
    );
  }


  Widget recipeListWidget() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError || snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Display data
        return SizedBox(
          // height: 200,
          child: ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              // Access UserModel from document
              final RecipeModel recipe = RecipeModel.fromMap(document.data() as Map<String, dynamic>);
              final List<Recipe> newlyPostedRecipe = RecipeHelper.newlyPostedRecipe;

              // Display user data
              return RecipeTile(
                data: newlyPostedRecipe[0],
                recipeDataModel:recipe
              );
            }).toList(),
          ),
        );
      },
    );
  }
}


