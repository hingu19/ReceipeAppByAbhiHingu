import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/models/receipe_data_model.dart';
import 'package:hungry/views/screens/recipe_detail_page.dart';
import 'package:hungry/views/utils/AppColor.dart';

import '../../controller/data_controller.dart';

class RecipeTile extends StatefulWidget {
  final Recipe? data;
  final RecipeModel? recipeDataModel;
  RecipeTile({required this.data,this.recipeDataModel});

  @override
  State<RecipeTile> createState() => _RecipeTileState();
}

class _RecipeTileState extends State<RecipeTile> {
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
      child: Container(
        height: 90,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColor.whiteSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Recipe Photo
            widget.recipeDataModel!= null ?
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                // color: Colors.blueGrey,
                image: DecorationImage(image:NetworkImage(widget.recipeDataModel!.imageUrl.toString()), fit: BoxFit.cover),
              ),
            ):
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
                        widget.recipeDataModel!= null ?  widget.recipeDataModel!.title: widget.data!.title.toString() ,
                        style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'inter'),
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
                        Container(
                          margin: EdgeInsets.only(left: 5),
                          child: Text(
                            widget.recipeDataModel!= null ?  widget.recipeDataModel!.calories!: widget.data!.title.toString(),
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.alarm,
                          size: 14,
                          color: Colors.black,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5),
                          child: Text(
                            widget.recipeDataModel!= null ? widget.recipeDataModel!.time! : widget.data!.title.toString(),
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
