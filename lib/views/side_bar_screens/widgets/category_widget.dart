import 'package:app_web_cms/controllers/banner_controller.dart';
import 'package:app_web_cms/controllers/category_controller.dart';
import 'package:app_web_cms/models/banner.dart';
import 'package:app_web_cms/models/category.dart';
import 'package:flutter/material.dart';

class CategoryWidget extends StatefulWidget {

  const CategoryWidget({super.key});

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  // A Future that will hold the list of banners once loaded from the API
  late Future<List<CategoryModel>> futureCategories;
  @override
  void initState() {
    super.initState();
    futureCategories = CategoryController().loadCategories();
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
          child: Text('No Categories'),
        );
      } else {
        final categories = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true,
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8 
        ), 
        itemBuilder: (context, index) {
          final category = categories[index];
          return Column(
            children: [
              Image.network(category.image, height: 100, width: 100,),
              Text(category.name),
            ], 
          );
        });
      }
    });
  }
}