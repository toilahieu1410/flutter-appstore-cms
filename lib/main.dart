import 'package:app_web_cms/provider/vendor_provider.dart';
import 'package:app_web_cms/views/authentications/login_screen.dart'; // Đường dẫn tới login screen của bạn

import 'package:app_web_cms/views/main_screen.dart';  // Đường dẫn tới main screen của bạn
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  Future<void> checkTokenAndSetUser(WidgetRef ref) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('auth_token');
    String? vendorJson = preferences.getString('vendor');

    if (token != null && vendorJson != null) {
      ref.read(vendorProvider.notifier).setVendor(vendorJson);
    } else {
      ref.read(vendorProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
        title: 'CMS',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: FutureBuilder(
          future: checkTokenAndSetUser(ref),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final vendor = ref.watch(vendorProvider);
            return vendor != null ? const MainScreen() : LoginScreen();
          },
        ),
      );
  }
}
