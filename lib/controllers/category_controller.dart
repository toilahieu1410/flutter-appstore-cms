import 'dart:convert';

import 'package:app_web_cms/gloab_variable.dart';
import 'package:app_web_cms/models/category.dart';
import 'package:app_web_cms/services/manage_http_response.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:http/http.dart' as http;

class CategoryController{
  uploadCategory(
    {required dynamic pickedImage, 
    required dynamic pickedBanner, 
    required String name, 
    required context
    }) async {
    try {
      final cloudinary = CloudinaryPublic('minh-hieu', 'lp1wsb4q');

      // upload the image
      CloudinaryResponse imageResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(pickedImage, identifier: 'pickedImage', folder: 'categoryImages')
      );
      String image = imageResponse.secureUrl;

      CloudinaryResponse bannerResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(pickedBanner, identifier: 'pickedImage', folder: 'categoryImages')
      );
      String banner = bannerResponse.secureUrl;

      CategoryModel category = CategoryModel(
        id: "", 
        name: name, 
        image: image, 
        banner: banner
      );
      http.Response response = await http.post(
      Uri.parse('$uri/api/categories'), 
      body: category.toJson(),
      headers: <String, String> {
        'Content-Type': 'application/json; charset=UTF-8',

      }
      );
      manageHttpResponse(
        response: response, 
        context: context, 
        onSuccess: () {
        showSnackBar(context, 'Uploaded Category');
      });
    } catch (e) {
      print('Error uploading to cloudinary: $e');
    }
  }

  //load the uploaded category

  Future<List<CategoryModel>> loadCategories () async {
    try {
      // send an http get request to load the categories
      http.Response response = await http.get(
        Uri.parse('$uri/api/categories'),
          headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        List<CategoryModel> categories = data.map((category) => CategoryModel.fromJson(category)).toList();
        return categories;
      } else {
         throw Exception('Failed to load categories');
      }
     
    } catch (e) {
     throw Exception('Error loading Categories $e');
    }
  }
}