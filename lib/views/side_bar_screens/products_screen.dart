import 'dart:io';
import 'dart:typed_data';

import 'package:app_web_cms/controllers/category_controller.dart';
import 'package:app_web_cms/controllers/product_controller.dart';
import 'package:app_web_cms/controllers/subcategory_controller.dart';
import 'package:app_web_cms/models/category.dart';
import 'package:app_web_cms/models/subCategory.dart';
import 'package:app_web_cms/provider/vendor_provider.dart';
import 'package:app_web_cms/services/manage_http_response.dart';
import 'package:app_web_cms/views/side_bar_screens/widgets/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart'; // chỉ dùng trên máy ảo 
import 'package:file_picker/file_picker.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  static const String id = 'productScreen';
  const ProductsScreen({super.key});

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProductController _productController = ProductController();
  late Future<List<CategoryModel>> futureCategories;
  Future<List<SubcategoryModel>>? futureSubCategories;

  CategoryModel? selectedCategory;
  SubcategoryModel? selectedSubcategory;
  late String productName;
  late int productPrice;
  late int quantity;
  late String description;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futureCategories = CategoryController().loadCategories();
  }

  List<Uint8List?> images = [];
  
  chooseImage() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: true,
  );

  if (result != null) {
    setState(() {
      images.addAll(result.files.map((file) => file.bytes).toList());
    });
  } else {
    print('No Image Picked');
  }
}
// chooseImage() async {
//   FilePickerResult? result = await FilePicker.platform.pickFiles(
//     type: FileType.image,
//     allowMultiple: true,
//   );

//   if (result == null) {
//     print('No Image Picked');
//   } else {
//     setState(() {
//       // Kiểm tra nếu `path` không phải là null trước khi thêm vào danh sách
//       images.addAll(result.paths.where((path) => path != null).map((path) => File(path!)).toList());
//     });
//   }
// }

  getSubcategoryByCategory(value) {
     // fetch subcategories base on the selected category
    futureSubCategories = SubcategoryController().getSubCategoriesByCategoryName(value.name);
      //reset the selectedSubCategory
    selectedSubcategory = null;
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.builder(
              shrinkWrap: true,
              itemCount: images.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4
                ), 
              itemBuilder: (context, index) {
                return index == 0
                ? Center(
                  child: IconButton(
                    onPressed: chooseImage,
                    icon: const Icon(Icons.add),
                  ),
                ) 
                : SizedBox(
                  width: 50,
                  height: 40,
                   child: Image.memory(images[index - 1]!),
                );
              }
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      onChanged: (value) {
                        productName = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Product Name';
                        } else {
                          return null;
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Enter product Name',
                        hintText: 'Enter Product Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                   SizedBox(
                    width: 200,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        productPrice = int.parse(value);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Product Price';
                        } else {
                          return null;
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Enter product Price',
                        hintText: 'Enter Product Price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                     SizedBox(
                    width: 200,
                    child: FutureBuilder<List<CategoryModel>>(
                      future: futureCategories,
                      builder: (content, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('No Category'),
                          );
                        } else {
                          return DropdownButton<CategoryModel>(
                            value: selectedCategory,
                            hint: const Text('Selected Category'),
                            items: snapshot.data!.map((CategoryModel category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                                getSubcategoryByCategory(selectedCategory);
                              });
                            },
                          );
                        }
                      },
                    ),
                  ),
                     SizedBox(
                    width: 200,
                    child: FutureBuilder<List<SubcategoryModel>>(
                      future: futureSubCategories,
                      builder: (content, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('No SubCategory'),
                          );
                        } else {
                          return DropdownButton<SubcategoryModel>(
                            value: selectedSubcategory,
                            hint: const Text('Selected Subcategory'),
                            items: snapshot.data!.map((SubcategoryModel subcategory) {
                              return DropdownMenuItem(
                                value: subcategory,
                                child: Text(subcategory.subCategoryName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSubcategory = value;
                              });
                            },
                          );
                        }
                      },
                    ),
                  ),
                    SizedBox(
                    width: 200,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        quantity = int.parse(value);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Product Quantity';
                        } else {
                          return null;
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Enter product Quantity',
                        hintText: 'Enter Product Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    width: double.infinity,
                    child: TextFormField(
                      onChanged: (value){
                        description = value;
                      },
                      validator: (value){
                        if(value!.isEmpty) {
                          return 'Enter Product Description';
                        } else {
                          return null;
                        }
                      },
                      maxLines: 3,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'Enter Product description 1',
                        hintText: 'Enter Product description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: InkWell(
                onTap: () async {
                  final vendor = ref.read(vendorProvider); 
                  final nonNullImages = images.whereType<Uint8List>().toList();
                   if(_formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });
                    

                    if (vendor == null) {
                      showSnackBar(context, 'Vendor not found');
                      return;
                    }
                    
                    await _productController.uploadProduct(
                      productName: productName, 
                      productPrice: productPrice, 
                      quantity: quantity, 
                      description: description, 
                     vendorId: vendor.id,
        fullName: vendor.fullName,
                      category: selectedCategory!.name, 
                      subCategory: selectedSubcategory!.subCategoryName, 
                      pickedImages: nonNullImages, 
                      context: context).whenComplete((){
                      setState(() {
                        isLoading = false;
                      });
                      selectedCategory = null;
                      selectedSubcategory = null;
                      images.clear();
                      });
                   
                  } else {
                    print('Please enter all the fields');
                  }
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Center(
                    child: isLoading
                    ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                    : const Text(
                      'Upload product',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.7
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}