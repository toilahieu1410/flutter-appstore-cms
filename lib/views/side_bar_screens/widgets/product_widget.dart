import 'package:app_web_cms/controllers/product_controller.dart';
import 'package:app_web_cms/models/product.dart';
import 'package:flutter/material.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({super.key});

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {

  late Future<List<ProductModel>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = ProductController().loadPopularProducts(context);
  }

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder(
      future: futureProducts, 
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'),
        );
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(
          child: Text('No Products'),
        );
      } else {
        final products = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true,
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8 
        ), 
        itemBuilder: (context, index) {
          final product = products[index];
          return Column(
            children: [
              Image.network(product.images[0], height: 100, width: 100,),
              Text(product.productName),
            ], 
          );
        });
      }
    });
  }
}