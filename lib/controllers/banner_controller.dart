import 'dart:convert';

import 'package:app_web_cms/gloab_variable.dart';
import 'package:app_web_cms/models/banner.dart';
import 'package:app_web_cms/services/manage_http_response.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:http/http.dart' as http;

class BannerController {
  uploadBanner(
    {required dynamic pickedImage, 
      required context
    }) async {
    try {
      final cloudinary = CloudinaryPublic('minh-hieu', 'lp1wsb4q');

      // upload the image
      CloudinaryResponse imageResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(pickedImage, identifier: 'pickedImage', folder: 'banners')
      );

      String image = imageResponse.secureUrl;

      BannerModel bannerModel = BannerModel(
        id: "", 
        image: image, 
      );

      http.Response response = await http.post(
      Uri.parse('$uri/api/banner'), 
      body: bannerModel.toJson(),
      headers: <String, String> {
        'Content-Type': 'application/json; charset=UTF-8',
        }
      );
      manageHttpResponse(
        response: response, 
        context: context, 
        onSuccess: () {
        showSnackBar(context, 'Uploaded Banner');
      });
    } catch (e) {
      print('Error uploading to cloudinary: $e');
    }
  }

  // fetch banners
  Future<List<BannerModel>> loadBanners () async {
    try {
      // send an http get request to fetch banners
      http.Response response = await http.get(
        Uri.parse('$uri/api/banner'), 
        headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8',
        }
      );
      print(response.body);
      if(response.statusCode == 200) { // OK
        final List<dynamic> data = jsonDecode(response.body);
        List<BannerModel> banners = data.map((banner) => BannerModel.fromJson(banner)).toList();

        return banners;
      } else {
        // throw an execption if the server responsed with an error status code
        throw Exception('Failed to load Banners');
      }
    } catch(e) {
        throw Exception('Error loading Banners $e');
    }
  }
}