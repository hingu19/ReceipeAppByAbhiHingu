import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hungry/models/core/recipe.dart';
import 'package:hungry/util/colors.dart';
import 'package:hungry/views/screens/full_screen_image.dart';
import 'package:hungry/views/utils/AppColor.dart';
import 'package:hungry/views/widgets/ingridient_tile.dart';
import 'package:hungry/views/widgets/review_tile.dart';
import 'package:hungry/views/widgets/step_tile.dart';
import 'package:share_plus/share_plus.dart';

import '../../controller/data_controller.dart';
import '../../models/receipe_data_model.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe? data;
  final RecipeModel? recipeDataModel;
  RecipeDetailPage({required this.data,required this.recipeDataModel});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> with TickerProviderStateMixin {
  TabController? _tabController;
  ScrollController? _scrollController;
  var dataController = Get.put(DataController());
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _scrollController!.addListener(() {
      changeAppBarColor(_scrollController!);
    });
  }

  Color appBarColor = Colors.transparent;

  changeAppBarColor(ScrollController scrollController) {
    if (scrollController.position.hasPixels) {
      if (scrollController.position.pixels > 2.0) {
        setState(() {
          appBarColor = AppColor.primary;
        });
      }
      if (scrollController.position.pixels <= 2.0) {
        setState(() {
          appBarColor = Colors.transparent;
        });
      }
    } else {
      setState(() {
        appBarColor = Colors.transparent;
      });
    }
  }

  // fab to write review
  showFAB(TabController tabController) {
    int reviewTabIndex = 2;
    if (tabController.index == reviewTabIndex) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AnimatedContainer(
          color: appBarColor,
          duration: Duration(milliseconds: 200),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('Search Recipe', style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w400, fontSize: 16,color: primaryWhite)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            actions: [
              // IconButton(onPressed: () {}, icon: SvgPicture.asset('assets/icons/bookmark.svg', color: Colors.white)),
            ], systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
      ),
      // Post Review FAB
      floatingActionButton: Visibility(
        visible: showFAB(_tabController!),
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 150,
                      color: Colors.white,
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        minLines: 6,
                        controller: reviewController,
                        decoration: InputDecoration(
                          hintText: 'Write your review here...',
                        ),
                        maxLines: null,
                      ),
                    ),
                    actions: [
                      Row(
                        children: [
                          Container(
                            width: 120,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('cancel'),
                              style: TextButton.styleFrom(
                                primary: Colors.grey[600],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: ElevatedButton(
                                onPressed: () {
                                  dataController.addReviews(widget.recipeDataModel!.id, widget.recipeDataModel!, reviewController.text);
                                  reviewController.clear();
                                  setState(() {

                                  });
                                },
                                child: Text('Post Review'),
                                style: ElevatedButton.styleFrom(
                                  primary: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                });
          },
          child: Icon(Icons.edit,color: primaryWhite,),
          backgroundColor: AppColor.primary,
        ),
      ),
      body: ListView(
        controller: _scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: BouncingScrollPhysics(),
        children: [
          // Section 1 - Recipe Image
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => FullScreenImage(image:
              widget.recipeDataModel != null ?
              Image.network(widget.recipeDataModel!.imageUrl,fit: BoxFit.cover,):
              Image.asset(widget.data!.photo!, fit: BoxFit.cover))));
            },
            child: Container(
              height: 280,
              width: MediaQuery.of(context).size.width,
              decoration:
              widget.recipeDataModel != null ?
              BoxDecoration(image: DecorationImage(image: NetworkImage(widget.recipeDataModel!.imageUrl), fit: BoxFit.cover))
              :
              BoxDecoration(image: DecorationImage(image:
              AssetImage(widget.data!.photo!), fit: BoxFit.cover)),
              child: Container(
                decoration: BoxDecoration(gradient: AppColor.linearBlackTop),
                height: 280,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
          // Section 2 - Recipe Info
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 20, bottom: 30, left: 16, right: 16),
            color: AppColor.primary,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Calories and Time
                Row(

                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/fire-filled.svg',
                            color: Colors.white,
                            width: 16,
                            height: 16,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Text(
                              widget.recipeDataModel != null ?         widget.recipeDataModel!.calories :    widget.data!.calories!,
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.alarm, size: 16, color: Colors.white),
                          Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Text(
                              widget.recipeDataModel != null ?        widget.recipeDataModel!.time  : widget.data!.time!,
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(onTap: () async {
                      final result = await Share.shareWithResult('${widget.recipeDataModel!.title},\n ${widget.recipeDataModel!.description},\n\n ${widget.recipeDataModel!.calories}');

                      if (result.status == ShareResultStatus.success) {
                        print('Thank you for sharing my website!');
                      }
                    },child:Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.green[900],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      child: Center(
                        child: Icon(Icons.share_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ),
                    SizedBox(width: 12,),
                    if(widget.recipeDataModel != null)
                    GestureDetector(
                      onTap: () {
                        dataController.updateRecipeDataInFirestore(
                            widget.recipeDataModel!.id.toString(), widget.recipeDataModel!, user!.uid);
                        setState(() {});
                      },
                      child: FutureBuilder<bool>(
                        future: dataController.isUserIdInFavorite(
                            widget.recipeDataModel!.id.toString(), user!.uid.toString()),
                        builder: (context, snapshot) {
                          return Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.green[900],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                snapshot.data != null && snapshot.data!
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                // Recipe Title
                Container(
                  margin: EdgeInsets.only(bottom: 12, top: 16),
                  child: Text(
                    widget.recipeDataModel != null ?      widget.recipeDataModel!.title: widget.data!.title!,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'inter'),
                  ),
                ),
                // Recipe Description
                Text(
                  widget.recipeDataModel != null ?        widget.recipeDataModel!.description:  widget.data!.description!,
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 150 / 100),
                ),
              ],
            ),
          ),
          // Tabbar ( Ingridients, Tutorial, Reviews )
          Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            color: AppColor.secondary,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  _tabController!.index = index;
                });
              },
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black.withOpacity(0.6),
              labelStyle: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w500),
              indicatorColor: Colors.black,
              tabs: [
                Tab(
                  text: 'Ingridients',

          ),
                Tab(
                  text: 'Tutorial',
                ),
                Tab(
                  text: 'Reviews',
                ),
              ],
            ),
          ),
          // IndexedStack based on TabBar index
          IndexedStack(
            index: _tabController!.index,
            children: [
              // Ingridients
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount:        widget.recipeDataModel != null ?        widget.recipeDataModel!.ingredients.length: widget.data!.ingridients!.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return IngridientTile(name:  widget.recipeDataModel != null ? widget.recipeDataModel!.ingredients[index]['name']:widget.data!.ingridients![index].name, size:  widget.recipeDataModel != null ? widget.recipeDataModel!.ingredients[index]['size']:widget.data!.ingridients![index].size,
                    // data: widget.data!.ingridients![index],
                    // widget..ingridients.toString();
                    // style: TextStyle(
                    //   fontWeight: FontWeight.bold,
                    //   fontSize: 32.0,
                    //   color: Colors.white,
                  //   ),
                   );
                },
              ),
              // Tutorials
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount:        widget.recipeDataModel != null ?        widget.recipeDataModel!.tutorialSteps.length: widget.data!.tutorial!.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
var stp = index;
stp++;
                  return StepTile(
                    step:        widget.recipeDataModel != null ?stp.toString(): widget.data!.tutorial![index].step.toString(), description:  widget.recipeDataModel != null ?  widget.recipeDataModel!.tutorialSteps[index]: widget.data!.tutorial![index].step.toString(),
                  );
                },
              ),
              // Reviews
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount:     widget.recipeDataModel != null ?        widget.recipeDataModel!.reviews.length:    widget.data!.reviews!.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ReviewTile(review:  widget.recipeDataModel != null ? widget.recipeDataModel!.reviews[index]['review'] :widget.data!.reviews![index].review, username:widget.recipeDataModel != null ?
                  widget.recipeDataModel!.reviews[index]
                  ['name']:widget.data!.reviews![index].username);
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
