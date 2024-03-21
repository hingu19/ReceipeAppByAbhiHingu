import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hungry/controller/data_controller.dart';
import 'package:hungry/views/screens/auth/welcome_page.dart';
import 'package:hungry/views/screens/home_page.dart';
import 'package:hungry/views/widgets/app_text_style.dart';
import 'package:hungry/views/widgets/input_text_field_widget.dart';
import 'package:hungry/views/widgets/modals/login_modal.dart';
import 'package:image_picker/image_picker.dart';
import '../../controller/authController.dart';
import '../../models/core/recipe.dart';
import '../../models/helper/recipe_helper.dart';
import '../../models/user_model.dart';
import '../../util/colors.dart';
import '../../util/common_methods.dart';
import '../utils/AppColor.dart';
import '../widgets/modals/personal_information.dart';
import '../widgets/modals/selectImage.dart';
import '../widgets/recipe_tile.dart';
import '../widgets/user_info_tile.dart';
import 'path_to_your_login_screen.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  List<Recipe> bookmarkedRecipe = RecipeHelper.bookmarkedRecipe;

  File? _image;
  User? currentUser = FirebaseAuth.instance.currentUser;
  var dataController = Get.put(DataController());
  String? imageUrl;
  var authController = Get.put(AuthController());

  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    refreshPage();
    super.initState();
  }

  Future refreshPage() async {
    log('----refreshPage-----');
    currentUser = await authController.getCurrentUser();
    log('----currentUser-----${currentUser.toString()}');
    if (currentUser != null) {
      UserModel? user = await authController.getUserById(currentUser!.uid);
      emailController.text = currentUser!.email.toString();

      if (user != null) {
        if (user!.name != null) {
          nameController.text = user.name.toString();
        }
        if (user.profileUrl != null) {
          imageUrl = user.profileUrl;
        }
      }
    }
    dataController.fetchRecipeDataModelDataFromFirestore();
    setState(() {});

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Profile',
          style: TextStyle(
              fontFamily: 'inter',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: primaryWhite
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // Removed the 'Edit' button TextButton
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          // Section 1 - Profile Picture Wrapper
          Container(
            color: AppColor.primary,
            padding: EdgeInsets.symmetric(vertical: 24),
            child: GestureDetector(
              onTap: () {
                selectImage();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    margin: EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(100),
                      // Profile Picture
                      image: _image != null
                          ? DecorationImage(
                        image: FileImage(_image!),
                        fit: BoxFit.cover,
                      )
                          : imageUrl != null
                          ? DecorationImage(
                        image: NetworkImage(imageUrl.toString()),
                        fit: BoxFit.cover,
                      )
                          : DecorationImage(
                        image: AssetImage('assets/images/profile.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Change Profile Picture',
                        style: TextStyle(
                          fontFamily: 'inter',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      SvgPicture.asset(
                        'assets/icons/camera.svg',
                        color: Colors.white,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          // Section 2 - User Info Wrapper
          Container(
            margin: EdgeInsets.only(top: 24),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Email', style: TextStyle(color: AppColor.primary, fontSize: 12)),
                ),
                TextFormFieldWidget(
                  enabled: false,
                  controller: emailController,
                  hintText: "Enter your email",
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Full Name', style: TextStyle(color: AppColor.primary, fontSize: 12)),
                ),
                TextFormFieldWidget(
                  controller: nameController,
                  hintText: "Enter your full name",
                ),

                // Save Changes Button
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      print("=========before saveprofile button=======");
                      saveProfile();
                      print("=========after saveprofile button=======");
                    },
                    child: Text('Save Changes'),
                  ),
                ),

                // Sign Out Button
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut().whenComplete(() =>
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => WelcomePage(),
                        ),
                      ));
                    },
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        color: Colors.red, // Adjust the color as needed
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('My Recipes', style: AppTextStyle.normalBold18),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width,
                  child:
                  Obx(()=>
                      ListView.separated(
                        shrinkWrap: true,
                        itemCount: dataController.myRecipeDataList.value.length,
                        physics: NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 16);
                        },
                        itemBuilder: (context, index) {
                          return RecipeTile(
                            data: bookmarkedRecipe[index],
                            recipeDataModel:  dataController.myRecipeDataList.value[index],
                          );
                        },
                      ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> uploadImageToStorage(String childName, String documentId) async {
    Reference ref = _storage.ref().child(childName).child('$documentId.jpg');
    UploadTask uploadTask = ref.putFile(File(_image!.path));
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  void saveProfile() async {
    log("----saveProfileCalled-----");

    CommonMethod().getXSnackBar("Wait", "Upload Process", lightPurpelColor);
    if (_image != null) {
      imageUrl = await uploadImageToStorage(currentUser!.uid.toString(), currentUser!.uid.toString());
    }

    await StoreData().addOrUpdateUserData(UserModel(
      id: currentUser!.uid,
      email: emailController.text,
      name: nameController.text,
      profileUrl: imageUrl.toString(), password: null,
    ));

    await CommonMethod()
        .getXSnackBar("Success", 'Profile Info Saved Successfully', success)
        .whenComplete(() => Get.to(() => HomePage()));
  }

  void selectImage() async {
    File? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      setState(() {
        _image = img;
      });
    } else {
      CommonMethod().getXSnackBar(
        "Error",
        "Image selection error",
        Colors.red,
      );
    }
  }
}
