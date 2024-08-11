import 'package:app_web_cms/controllers/category_controller.dart';
import 'package:app_web_cms/controllers/subcategory_controller.dart';
import 'package:app_web_cms/models/category.dart';
import 'package:app_web_cms/views/side_bar_screens/widgets/subcategory_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SubcategoryScreen extends StatefulWidget {
  static const String id = 'subCategoryScreen';

  const SubcategoryScreen({super.key});

  @override
  State<SubcategoryScreen> createState() => _SubcategoryScreenState();
}

class _SubcategoryScreenState extends State<SubcategoryScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SubcategoryController _subCategoryController = SubcategoryController();

  late Future<List<CategoryModel>> futureCategories;
  CategoryModel? selectedCategory;
  @override
  void initState() {
    super.initState();
    futureCategories = CategoryController().loadCategories();
  }
   late String name;
   dynamic _image;

  pickImage() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if(result != null) {
      setState(() {
        _image = result.files.first.bytes;
      });
    }
  }

  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.topLeft,
              child: const Text(
                'Subcategories',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(4.0),
            child: Divider(
              color: Colors.grey,
            ),
          ),
        
          FutureBuilder(future: futureCategories, 
          builder: (content, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'),
              );
            } else if(!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No category'),
              );
            } else {
              return DropdownButton<CategoryModel>(
                value: selectedCategory,
                hint: const Text('Select Category'),
                items: snapshot.data!.map((CategoryModel category) {
                return DropdownMenuItem(
                  
                  value: category,
                  child: Text(category.name));
              }).toList(), 
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
                print(selectedCategory!.name);
              });
            }
          }),
              Row(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: Center(
                        child: _image != null 
                        ? Image.memory(_image) 
                        : Text('SubCategory Image'),),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 200,
                        child: TextFormField(
                          onChanged: (value) {
                            name = value;
                          },
                          validator: (value) {
                            if(value!.isNotEmpty) {
                              return null;
                            } else {
                              return 'Please enter subCategory name';
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Enter Subcategory name'
                          ),
                        ),
                      ),
                    ),
            
                    
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () async {
                      if(_formKey.currentState!.validate()) {
                          await _subCategoryController.uploadSubcategory(
                            categoryId: selectedCategory!.id, 
                            categoryName: selectedCategory!.name, 
                            pickedImage: _image, 
                            subCategoryName: name, 
                            context: context
                          );
                          setState(() {
                            _formKey.currentState!.reset();
                            _image = null;
                          });
                        }
                      },
                      
                      child: const Text('Save', 
                      style: TextStyle(
                        color: Colors.white),
                      ),
                    )
                  ],
                ),
                   Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: ElevatedButton(
                  onPressed: (){
                    pickImage();
                  }, 
                  child: Text(
                    'Pick Image')
                  ),
               ),
          SubcategoryWidget()
        ]
        ),
      ),
    );
  }
}
