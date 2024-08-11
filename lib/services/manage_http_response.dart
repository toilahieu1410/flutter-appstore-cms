import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

void manageHttpResponse({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,

}) {
  // Switch statement to handle different http status codes
  switch(response.statusCode) {
    case 200: // status code 200 indicates a successfull request
      onSuccess();
      break;
    case 400: // status code 400 indicates bad request
      showSnackBar(context, json.decode(response.body)['msg']);
      break;
    case 500: // status code 400 indicates a server error
      showSnackBar(context, json.decode(response.body)['error']);
      break;
    case 201: // status code 201 indicates a resource was created successfully
      onSuccess();
      break;
  } 
}

void showSnackBar(BuildContext context, String title) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title)));
}