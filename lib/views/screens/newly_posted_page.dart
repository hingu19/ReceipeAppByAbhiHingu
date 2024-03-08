import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/models/helper/recipe_helper.dart';
import 'package:hungry/util/colors.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/recipe_tile.dart';

import '../../controller/data_controller.dart';

class NewlyPostedPage extends StatefulWidget {
  @override
  State<NewlyPostedPage> createState() => _NewlyPostedPageState();
}

class _NewlyPostedPageState extends State<NewlyPostedPage> {
  final TextEditingController searchInputController = TextEditingController();
  var dataController = Get.put(DataController());

  final List<Recipe> newlyPostedRecipe = RecipeHelper.newlyPostedRecipe;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        centerTitle: true,
        elevation: 0,
        title: Text('Newly Posted', style: TextStyle(fontFamily: 'inter',color: primaryWhite, fontWeight: FontWeight.w400, fontSize: 16)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ), systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      body:
      Obx(()=>
      ListView.separated(
        padding: EdgeInsets.all(16),
        shrinkWrap: true,
        itemCount: dataController.recipeList.value.length,
        physics: BouncingScrollPhysics(),
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
    );
  }
}
