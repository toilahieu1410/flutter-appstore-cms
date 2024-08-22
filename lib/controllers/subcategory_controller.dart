import 'dart:convert';

import 'package:app_web_cms/gloab_variable.dart';
import 'package:app_web_cms/models/subCategory.dart';
import 'package:app_web_cms/services/manage_http_response.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:http/http.dart' as http;

class SubcategoryController {
  uploadSubcategory(
      {required String categoryId,
      required String categoryName,
      required dynamic pickedImage,
      required String subCategoryName,
      required context}) async {
    try {
      final cloudinary = CloudinaryPublic('minh-hieu', 'lp1wsb4q');

      // upload the image
      CloudinaryResponse imageResponse = await cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(pickedImage,
              identifier: 'pickedImage', folder: 'categoryImages'));
      String image = imageResponse.secureUrl;
      SubcategoryModel subcategory = SubcategoryModel(
          id: '',
          categoryId: categoryId,
          categoryName: categoryName,
          image: image,
          subCategoryName: subCategoryName);
      http.Response response = await http.post(
          Uri.parse('$uri/api/subcategories'),
          body: subcategory.toJson(),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });
      manageHttpResponse(
          response: response,
          context: context,
          onSuccess: () {
            showSnackBar(context, 'Uploaded Subcategory');
          });
    } catch (e) {
      print('Error uploading to cloudinary: $e');
    }
  }

  Future<List<SubcategoryModel>> getSubCategoriesByCategoryName(
      String categoryName) async {
    try {
      // send an http get request to load the categories
      http.Response response = await http.get(
        Uri.parse('$uri/api/category/$categoryName/subcategories'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data
              .map((subcategory) => SubcategoryModel.fromJson(subcategory))
              .toList();
        } else {
          print('subcategories not found');
          return [];
        }
      } else if (response.statusCode == 404) {
        print('subcategories not found');
          return [];
      } else {
        print('failed to fetch subcategories');
        return [];
      }
    } catch (e) {
      print('error fetching subcategories $e');
      return [];
    }
  }
  //load the uploaded subCategory

  Future<List<SubcategoryModel>> loadSubcategories () async {
    try {
      // send an http get request to load the categories
      http.Response response = await http.get(
        Uri.parse('$uri/api/subcategories'),
          headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        List<SubcategoryModel> subcategories = data.map((subcategory) => SubcategoryModel.fromJson(subcategory)).toList();
        return subcategories;
      } else {
         throw Exception('Failed to load subCategories');
      }
     
    } catch (e) {
     throw Exception('Error loading subCategories $e');
    }
  }
}
