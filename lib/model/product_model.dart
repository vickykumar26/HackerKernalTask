import 'dart:convert';

class Product {
  final String name;
  final double price;
  final String productImage;

  Product({required this.name, required this.price, required this.productImage});

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'productImage': productImage,
  };

  static Product fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      price: json['price'],
      productImage: json['productImage'],
    );
  }
}
