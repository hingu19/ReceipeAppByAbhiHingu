import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/controller/data_controller.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/models/helper/recipe_helper.dart';
import 'package:hungry/views/screens/Add_recipe.dart';
import 'package:hungry/views/screens/bookmarks_page.dart';
import 'package:hungry/views/screens/delicious_today_page.dart';
import 'package:hungry/views/screens/newly_posted_page.dart';
import 'package:hungry/views/screens/profile_page.dart';
import 'package:hungry/views/screens/reports.dart';
import 'package:hungry/views/screens/search_page.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/dummy_search_bar.dart';
import 'package:hungry/views/widgets/featured_recipe_card.dart';
import 'package:hungry/views/widgets/recipe_tile.dart';
import 'package:hungry/views/widgets/recommendation_recipe_card.dart';

import '../../controller/authController.dart';
import '../../main.dart';
import '../../models/user_model.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Recipe> featuredRecipe = RecipeHelper.featuredRecipe;
  final List<Recipe> recommendationRecipe = RecipeHelper.recommendationRecipe;
  final List<Recipe> newlyPostedRecipe = RecipeHelper.newlyPostedRecipe;

  var dataController = Get.put(DataController());
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  bool? isAdmin;
  @override
  void initState() {
    refreshPage();
    super.initState();
  }

  Future refreshPage() async {
    await dataController.refreshPage().whenComplete(() {
      isAdmin = dataController.currentUser != null &&
          dataController.currentUser!.email == dataController.adminEmail;
      setState(() {});
    });
    dataController.fetchRecipeDataModelDataFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    // bool isAdmin = dataController.currentUser!.email == dataController.adminEmail;
    // bool adminWantsPictures = !(Get.find<AuthController>().user?.email == "recipesharing@gmail.com");

    return
      isAdmin != null && isAdmin == true ? AdminPage():

      Scaffold(
      appBar: AppBar(
        title: Text(
          'Hungry?',
          style: TextStyle(
            fontFamily: 'inter',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColor.primary,
        actions: [
          // Add Recipe button only visible to admins
          if (isAdmin != null && !isAdmin!)
            IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AddRecipePage()));
              },
            ),
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: Colors.white,
            ),
            onPressed: () {
              Get.to(() => BookmarksPage());
            },
          ),
          // Profile button visible to both users and admins
          IconButton(
            icon: Obx(
              () => CircleAvatar(
                backgroundImage: dataController.profileImageURL?.isNotEmpty ==
                        true
                    ? NetworkImage(dataController.profileImageURL.toString())
                    : null,
                child: dataController.profileImageURL?.isEmpty == true
                    ? Icon(Icons.person)
                    : null,
              ),
            ),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
        ],
      ),
      body:

      ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          if (isAdmin != null && !isAdmin!)
            Container(
              height: 350,
              color: Colors.white,
              child: Stack(
                children: [
                  Container(
                    height: 245,
                    color: AppColor.primary,
                  ),
                  Column(
                    children: [
                      DummySearchBar(
                        routeTo: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SearchPage()));
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Delicious Today',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'inter'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        DeliciousTodayPage()));
                              },
                              child: Text('see all'),
                              style: TextButton.styleFrom(
                                  primary: Colors.white,
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: featuredRecipe.map((e) {
                            var index = featuredRecipe.indexOf(e);
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: FeaturedRecipeCard(data: featuredRecipe[index]),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          if (isAdmin != null && !isAdmin!)
            Container(
              margin: EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Today recommendation based on your taste...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: recommendationRecipe.map((e) {
                        var index = recommendationRecipe.indexOf(e);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: RecommendationRecipeCard(
                              data: recommendationRecipe[index]),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          if (isAdmin != null && !isAdmin!)
            Container(
              margin: EdgeInsets.only(top: 14),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          dataController
                              .fetchRecipeDataModelDataFromFirestore();
                        },
                        child: Text(
                          'Newly Posted',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'inter'),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NewlyPostedPage()));
                        },
                        child: Text('see all'),
                        style: TextButton.styleFrom(
                            primary: Colors.black,
                            textStyle: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 14)),
                      ),
                    ],
                  ),
                  Obx(
                    () => ListView.separated(
                      shrinkWrap: true,
                      itemCount: dataController.recipeList.value.length <= 5
                          ? dataController.recipeList.value.length
                          : 5,
                      physics: NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 16);
                      },
                      itemBuilder: (context, index) {
                        return RecipeTile(
                          data: newlyPostedRecipe[index],
                          recipeDataModel:
                              dataController.recipeList.value[index],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
