import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/models/receipe_data_model.dart';
import 'package:hungry/utils/image_widget.dart';
import 'package:hungry/views/screens/recipe_detail_page.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/utils/shadow_container_widget.dart';
import 'package:hungry/views/widgets/app_text_style.dart';

import '../../controller/authController.dart';
import '../../controller/data_controller.dart';
import '../../models/user_model.dart';

class RecipeTile extends StatefulWidget {
  final Recipe? data;
  final RecipeModel? recipeDataModel;
  RecipeTile({required this.data,this.recipeDataModel});

  @override
  State<RecipeTile> createState() => _RecipeTileState();
}

class _RecipeTileState extends State<RecipeTile> {


  var authController = Get.put(AuthController());

  var dataController = Get.put(DataController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => RecipeDetailPage(data: widget.data, recipeDataModel: widget.recipeDataModel,))).then((value) {
          dataController.fetchRecipeDataModelDataFromFirestore();
        }
        );
      },
      child: ShadowContainerWidget(
        widget: Column(
          children: [

            if(widget.recipeDataModel != null)
        FutureBuilder<UserModel?>(
        future: dataController.getUserById(widget.recipeDataModel!.userId), // Call your service method to fetch data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While data is being fetched, show a loading indicator
            return SizedBox();
          } else if (snapshot.hasError) {
            // If there's an error fetching data, display an error message
            return SizedBox();
          } else {
            // If data is successfully fetched, display it
            UserModel? data = snapshot.data;
            return
              data != null ?

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  if(data.profileUrl != null)
                    NetworkImageWidget(imageUrl: data.profileUrl ,height: 30,width: 30,borderRadius: BorderRadius.circular(30),),
                  if(data.name != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:8.0),
                      child: Text(data.name ?? "",style: AppTextStyle.regularBold,),
                    ),
                ],
              ):SizedBox();
          }
        },
      ),



            Container(
              // height: 90,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.whiteSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Recipe Photo
                  widget.recipeDataModel!= null ?

                  NetworkImageWidget(imageUrl: widget.recipeDataModel!.imageUrl,width: 70,height: 70,borderRadius: BorderRadius.circular(70),):
                  // Container(
                  //   width: 70,
                  //   height: 70,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(5),
                  //     // color: Colors.blueGrey,
                  //     image: DecorationImage(image:NetworkImageWidget(widget.recipeDataModel!.imageUrl.toString()), fit: BoxFit.cover),
                  //   ),
                  // ):
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.blueGrey,
                      image: DecorationImage(image:AssetImage(widget.data!.photo!), fit: BoxFit.cover),
                    ),
                  )
                  ,
                  // Recipe Info
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Recipe title
                          Container(
                            margin: EdgeInsets.only(bottom: 12),
                            child: Text(
                              widget.recipeDataModel != null ? widget.recipeDataModel!.title : widget.data!.title.toString(),
                              style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'inter'),
                              overflow: TextOverflow.ellipsis, // Add this line to handle overflow
                            ),
                          ),
                          // Recipe Calories and Time
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/fire-filled.svg',
                                color: Colors.black,
                                width: 12,
                                height: 12,
                              ),
                              SizedBox(width: 5),
                              Flexible( // Wrap the first Text widget with Flexible
                                child: Text(
                                  widget.recipeDataModel != null ? widget.recipeDataModel!.calories! : widget.data!.calories.toString(),
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis, // Add this line to handle overflow
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.alarm,
                                size: 14,
                                color: Colors.black,
                              ),
                              SizedBox(width: 5),
                              Flexible( // Wrap the second Text widget with Flexible
                                child: Text(
                                  widget.recipeDataModel != null ? widget.recipeDataModel!.time! : widget.data!.time.toString(),
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis, // Add this line to handle overflow
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
