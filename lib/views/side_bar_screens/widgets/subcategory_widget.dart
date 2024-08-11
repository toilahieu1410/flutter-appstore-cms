
import 'package:app_web_cms/controllers/subcategory_controller.dart';
import 'package:app_web_cms/models/subCategory.dart';
import 'package:flutter/material.dart';

class SubcategoryWidget extends StatefulWidget {

  const SubcategoryWidget({super.key});

  @override
  State<SubcategoryWidget> createState() => _SubcategoryWidgetState();
}

class _SubcategoryWidgetState extends State<SubcategoryWidget> {
  // A Future that will hold the list of banners once loaded from the API
  late Future<List<SubcategoryModel>> futureCategories;
  @override
  void initState() {
    super.initState();
    futureCategories = SubcategoryController().loadSubcategories();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureCategories, 
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'),
        );
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(
          child: Text('No SubCategories'),
        );
      } else {
        final subcategories = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true,
          itemCount: subcategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8 
        ), 
        itemBuilder: (context, index) {
          final subcategory = subcategories[index];
          return Column(
            children: [
              Image.network(subcategory.image, height: 100, width: 100,),
              Text(subcategory.subCategoryName),
            ], 
          );
        });
      }
    });
  }
}