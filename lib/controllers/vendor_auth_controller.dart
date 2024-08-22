import 'dart:convert';

import 'package:app_web_cms/gloab_variable.dart';
import 'package:app_web_cms/models/vendor.dart';
import 'package:app_web_cms/provider/vendor_provider.dart';
import 'package:app_web_cms/services/manage_http_response.dart';
import 'package:app_web_cms/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final providerContainer = ProviderContainer();

class VendorAuthController {
  Future<void> signUpVendor({
    required String fullName,
    required String email,
    required String password,
    required context,
  }) async {
    try {
      Vendor vendor = Vendor(
          id: '',
          fullName: fullName,
          email: email,
          state: '',
          city: '',
          locality: '',
          role: '',
          password: password);

      http.Response response = await http.post(
          Uri.parse('$uri/api/vendor/signup'),
          body: vendor
              .toJson(), // Convert the Vendor user object to json for the request body
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          }); // Set the Headers for the request

      //print('Response body: ${response.body}');

      //manage http response to handle http response base on their status code
      manageHttpResponse(
          response: response,
          context: context,
          onSuccess: () {
            showSnackBar(context, 'Vendor Account created');
          });
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }

  Future<void> signInVendor(
      {required String email,
      required String password,
      required context}) async {
    try {
      http.Response response = await http.post(
          Uri.parse('$uri/api/vendor/signin'),
          body: jsonEncode({'email': email, 'password': password}),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          }); // Set the Headers for the request
      //manage http response to handle http response base on their status code
      manageHttpResponse(
          response: response,
          context: context,
          onSuccess: () async {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();

            // Trích xuất token từ response body
            String token = jsonDecode(response.body)['accessToken'];

            // Lưu trữ token 1 cách an toàn trong SharedPreferences
            await preferences.setString('auth_token', token);

            // Mã hoá dữ liệu người dùng nhận đc từ backend dưới dạng JSON
            final vendorJson = jsonEncode(jsonDecode(response.body)['vendor']);
          // Thêm dòng print để kiểm tra

            // Cập nhật trạng thái ứng dụng với dữ liệu người dùng sử dụng Riverpod
            providerContainer
                .read(vendorProvider.notifier)
                .setVendor(vendorJson);

            // lưu trữ dữ liệu trong SharedPreferences
            await preferences.setString('vendor', vendorJson);
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) {
              return const MainScreen();
            }),
                (route) => false); // Chuyển ng dùng đến màn hình chính của nhà cung cấp mà k có tuỳ chọn quay lại màn hình đăng nhập
            showSnackBar(context, 'Logged in successfully');
          });
    } catch (e) {
      showSnackBar(context, 'Lỗi mất rồi $e');
    }
  }
}
