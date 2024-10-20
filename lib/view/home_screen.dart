import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hecker_kernal_task/view/all_product_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/product_model.dart';
import 'add_product_screen.dart';
import 'login_screen.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  Future<void> _loadProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? productList = prefs.getStringList('products');

    if (productList != null) {
      setState(() {
        _products = productList.map((item) {
          final Map<String, dynamic> jsonData = jsonDecode(item);
          return Product.fromJson(jsonData);
        }).toList();
      });
    }
  }


  List<Product> get filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products.where((product) =>
        product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _deleteProduct(Product product) async {
    setState(() {
      _products.remove(product);
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
        'products',
        _products.map((p) => jsonEncode(p.toJson())).toList()
    );
  }


  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (
          context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _logout,
        ),
        title: _isSearching
            ? TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Type to search...',
            border: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(20)
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        )
            : const Text(''),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.clear : Icons.search, size: 30),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Hi-Fi Shop & Service',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Audio shop on Rustaveli Ave 57.\nThis shop offers both products and services',
                style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey),
              ),
            ),
            SizedBox(height: MediaQuery
                .of(context)
                .size
                .height * 0.02),
            _buildSectionTitle('Products', filteredProducts.length, context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildProductList(filteredProducts),
            ),
            SizedBox(height: MediaQuery
                .of(context)
                .size
                .height * 0.02),
            _buildSectionTitle('Accessories', filteredProducts.length, context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildProductList(filteredProducts),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          ).then((_) {
            _loadProducts();
          });
        },
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),

    );
  }

  Widget _buildSectionTitle(String title, int count, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$title ',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: '$count',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AllProductScreen()));
            },
            child: const Text(
              'See all',
              style: TextStyle(fontSize: 14, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    if (products.isEmpty) {
      return const Center(child: Text('No Product Found'));
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.26,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.43,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.16,
                    width: MediaQuery.of(context).size.width * 0.43,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade300,
                      image: DecorationImage(
                        image: FileImage(File(product.productImage)),
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 2,
                          top: 2,
                          child: IconButton(
                            onPressed: () => _deleteProduct(product),
                            icon: const Icon(Icons.delete_outline, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '\$${product.price}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
