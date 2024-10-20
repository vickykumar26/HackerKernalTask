import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/product_model.dart';

class AllProductScreen extends StatefulWidget {
  const AllProductScreen({super.key});

  @override
  State<AllProductScreen> createState() => _AllProductScreenState();
}

class _AllProductScreenState extends State<AllProductScreen> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? productList = prefs.getStringList('products');

    if (productList != null) {
      setState(() {
        _products = productList.map((item) {
          return Product.fromJson(jsonDecode(item));
        }).toList();
      });
    }
  }

  Future<void> _deleteProduct(Product product) async {
    setState(() {
      _products.remove(product);
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'products',
      _products.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _buildProductList(),
      ),
    );
  }

  Widget _buildProductList() {
    if (_products.isEmpty) {
      return const Center(child: Text('No Product Found'));
    }

    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade300,
                image: DecorationImage(
                  image: FileImage(File(product.productImage)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              '\$${product.price}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            trailing: IconButton(
              onPressed: () => _deleteProduct(product),
              icon: const Icon(Icons.delete_outline, color: Colors.black),
            ),
          ),
        );
      },
    );
  }
}
