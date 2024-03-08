import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controller/data_controller.dart';
import '../widgets/input_text_field_widget.dart';

class AddRecipePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Recipe',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[900],
      ),
      body: AddRecipeForm(),
    );
  }
}

class AddRecipeForm extends StatefulWidget {
  @override
  _AddRecipeFormState createState() => _AddRecipeFormState();
}

class _AddRecipeFormState extends State<AddRecipeForm> {
  final titleController = TextEditingController();
  final caloriesController = TextEditingController();
  final timeController = TextEditingController();
  final descriptionController = TextEditingController();
  final tutorialController = TextEditingController();
  XFile? imageFile;
  File? _image;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final List<Map<String, String>> _ingredientsList = [];
  final List<String> _tutorialSteps = [];
  var dataController = Get.put(DataController());

  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = XFile(pickedFile.path);
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveRecipe(BuildContext context) async {
    if (!_validateForm(context)) {
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        var recipeData = {
          'userId': user.uid,
          'title': titleController.text,
          'calories': caloriesController.text,
          'time': timeController.text,
          'description': descriptionController.text,
          'tutorial': tutorialController.text,
          'ingredients': _ingredientsList,
          'tutorialSteps': _tutorialSteps,
          'timestamp':FieldValue.serverTimestamp()
        };

        var result = await FirebaseFirestore.instance.collection('recipes').add(recipeData);

        if (imageFile != null) {
          var imageUrl = await uploadImageToStorage(result.id!, result.id!);
          log('-----imageUrl----' + imageUrl.toString());
          await FirebaseFirestore.instance.collection('recipes').doc(result.id).update({
            'id':result.id,
            'imageUrl': imageUrl});
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recipe saved successfully.'),
            backgroundColor: Colors.green,
          ),
        );

        dataController.fetchRecipeDataModelDataFromFirestore();
        // Clear form fields after successful submission
        titleController.clear();
        caloriesController.clear();
        timeController.clear();
        descriptionController.clear();
        tutorialController.clear();
        _ingredientsList.clear();
        _tutorialSteps.clear();
        setState(() {
          imageFile = null;
          _image = null;
        });

        // Navigate back to the previous screen
        Navigator.pop(context);

      } else {
        print('User not authenticated.');
      }
    } catch (e, stackTrace) {
      print('Error saving recipe: $e');
      print(stackTrace); // Print stack trace for better debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while saving the recipe.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validateForm(BuildContext context) {
    if (titleController.text.isEmpty ||
        caloriesController.text.isEmpty ||
        timeController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        _ingredientsList.isEmpty ||
        _tutorialSteps.isEmpty ||
        imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields and select an image.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    for (var ingredient in _ingredientsList) {
      if (ingredient['name']!.isEmpty || ingredient['size']!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all fields for ingredients.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    for (var step in _tutorialSteps) {
      if (step.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all fields for tutorial steps.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    return true;
  }

  Future<String> uploadImageToStorage(String childName, String documentId) async {
    Reference ref = _storage.ref().child(childName).child('$documentId.jpg');
    UploadTask uploadTask = ref.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Widget _buildIngredientsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Text(
          'Ingredients',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _ingredientsList.length,
          itemBuilder: (context, index) {
            return _buildIngredientRow(index);
          },
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            _addIngredient();
          },
          child: Row(
            children: [
              Icon(Icons.add, color: Colors.green),
              SizedBox(width: 5),
              Text(
                'Add Ingredient',
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientRow(int index) {
    return Row(
      children: [
        Expanded(
          child: TextFormFieldWidget(
            onChanged: (value) => _ingredientsList[index]['name'] = value!,
            controller: TextEditingController(text: _ingredientsList[index]['name']),
            hintText: 'Name',
            prefixIcon: Icon(Icons.food_bank),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: TextFormFieldWidget(
            onChanged: (value) => _ingredientsList[index]['size'] = value!,
            controller: TextEditingController(text: _ingredientsList[index]['size']),
            hintText: 'Size',
            prefixIcon: Icon(Icons.settings_ethernet),
          ),
        ),
      ],
    );
  }

  void _addIngredient() {
    setState(() {
      _ingredientsList.add({'name': '', 'size': ''});
    });
  }

  Widget _buildTutorialField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Text(
          'Tutorial',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _tutorialSteps.length,
          itemBuilder: (context, index) {
            return _buildTutorialStepRow(index);
          },
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            _addTutorialStep();
          },
          child: Row(
            children: [
              Icon(Icons.add, color: Colors.green),
              SizedBox(width: 5),
              Text(
                'Add Step',
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTutorialStepRow(int index) {
    return Row(
      children: [
        Icon(Icons.star), // Icon for tutorial step
        SizedBox(width: 5),
        Expanded(
          child: TextFormFieldWidget(
            onChanged: (value) => _tutorialSteps[index] = value!,
            controller: TextEditingController(text: _tutorialSteps[index]),
            hintText: 'Step ${index + 1}',
          ),
        ),
      ],
    );
  }

  void _addTutorialStep() {
    setState(() {
      _tutorialSteps.add('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                _getImage();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    margin: EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: _image != null
                        ? Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    )
                        : Icon(
                      Icons.add_photo_alternate,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            TextFormFieldWidget(controller: titleController, hintText: "Enter your title", label: 'Title', prefixIcon: Icon(Icons.title)),
            TextFormFieldWidget(controller: caloriesController, hintText: "Enter your calories", label: 'Calories', prefixIcon: Icon(Icons.local_fire_department)),
            TextFormFieldWidget(controller: timeController, hintText: "Enter expect time", keyboardType: TextInputType.number, label: 'Time', prefixIcon: Icon(Icons.access_time)),
            TextFormFieldWidget(controller: descriptionController, hintText: "Enter your description", maxLines: 5, label: 'Description', prefixIcon: Icon(Icons.description)),
            _buildIngredientsField(),

            _buildTutorialField(),
            ElevatedButton(
              onPressed: () {
                _saveRecipe(context);
              },
              child: Text('Save Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AddRecipePage(),
  ));
}
