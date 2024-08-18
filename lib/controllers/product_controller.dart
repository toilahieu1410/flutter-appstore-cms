import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_web_cms/gloab_variable.dart';
import 'package:app_web_cms/models/product.dart';
import 'package:app_web_cms/services/manage_http_response.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class ProductController{
  
  Future<void> uploadProduct({
    required String productName,
    required int productPrice,
    required int quantity,
    required String description,
    required String vendorId,
    required String fullName,
    required String category,
    required String subCategory,
    required List<Uint8List>? pickedImages,
    required context,
  }) async {
    if(pickedImages != null) {
      final cloudinary = CloudinaryPublic('minh-hieu', 'lp1wsb4q');
      List<String> images = [];
      //loop through each image in the pickedImage List
      for(var i =0; i < pickedImages.length; i++) {
        // await the upload of current image to cloudinary
       CloudinaryResponse cloudinaryResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          pickedImages[i]!,
          identifier: 'product_image_$i', 
          folder: productName)
        );

        // add the secure Url to the images list
        images.add(cloudinaryResponse.secureUrl);
      }
      if(category.isNotEmpty && subCategory.isNotEmpty) {
        final ProductModel product = ProductModel(
          id: '', 
          productName: productName, 
          productPrice: productPrice, 
          quantity: quantity, 
          description: description, 
          category: category, 
          vendorId: vendorId, 
          fullName: fullName, 
          subCategory: subCategory, 
          images: images);
        
      http.Response response = await http.post(Uri.parse('$uri/api/add-product'),
          body: product.toJson(),
          headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        manageHttpResponse(
          response: response, 
          context: context, 
          onSuccess: (){
            showSnackBar(context, 'Product Uploaded');
          });
      } else {
        showSnackBar(context, 'Select Category');
      }

    } else {
      showSnackBar(context, 'Select Image');
    }
  }

  // load the upload product
  Future<List<ProductModel>> loadPopularProducts(BuildContext context) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/popular-products'),
          headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if(response.statusCode == 200) {
              final List<dynamic> data = jsonDecode(response.body);

        List<ProductModel> products = data.map((product) => ProductModel.fromJson(product)).toList();
        return products;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error loading Products $e');
    }

  }
}