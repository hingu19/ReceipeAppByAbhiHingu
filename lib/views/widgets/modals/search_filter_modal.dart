import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/views/utils/AppColor.dart';

import '../../../controller/data_controller.dart';

class SearchFilterModal extends StatefulWidget {
  @override
  State<SearchFilterModal> createState() => _SearchFilterModalState();
}

class _SearchFilterModalState extends State<SearchFilterModal> {
  var dataController = Get.put(DataController());

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        // Section 1 - Header
        Container(
          width: MediaQuery.of(context).size.width,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: AppColor.primaryExtraSoft,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 60,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Reset', style: TextStyle(color: Colors.grey)),
                ),
              ),
              Text(
                'Sort by',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'inter'),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 60,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
        // Sort By Option
        GestureDetector(
          onTap: (){
            dataController.filterName.value = "Newest";
            Get.back();

            dataController.fetchRecipeDataModelDataFromFirestore().whenComplete(() =>
            dataController.filterRecipes(''));
          },
          child: Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
            child: ListTileTheme(
              selectedColor: AppColor.primary,
              textColor: Colors.grey,
              child: ListTile(
                selected:     dataController.filterName.value == "Newest",
                title: Text('Newest', style: TextStyle(fontWeight: FontWeight.w600)),
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
            ),
          ),
        ),
        // Sort By Option
        GestureDetector(
          onTap: (){
            dataController.filterName.value = "Oldest";
            Get.back();

            dataController.fetchRecipeDataModelDataFromFirestore().whenComplete(() =>

                dataController.filterRecipes(''));

          },
          child: Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
            child: ListTileTheme(
              selectedColor: AppColor.primary,
              textColor: Colors.grey,
              child: ListTile(
                selected: dataController.filterName.value == "Oldest",
                title: Text('Oldest', style: TextStyle(fontWeight: FontWeight.w600)),
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
            ),
          ),
        ),
        // Sort By Option
        GestureDetector(
          onTap: (){
            dataController.filterName.value = "Popular";
            Get.back();
            dataController.fetchRecipeDataModelDataFromFirestore().whenComplete(() =>

                dataController.filterRecipes(''));

          },
          child: Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
            child: ListTileTheme(
              selectedColor: AppColor.primary,
              textColor: Colors.grey,
              child: ListTile(
                selected: dataController.filterName.value == "Popular",
                title: Text('Popular', style: TextStyle(fontWeight: FontWeight.w600)),
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
