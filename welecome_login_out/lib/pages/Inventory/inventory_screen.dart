// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class StockManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Management',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductScreen()),
              );
            },
          ),
        ],
      ),
      body: ProductList(),
    );
  }
}

class ProductList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductItem(product: products[index]);
      },
    );
  }
}

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product)),
        );
      },
      leading: Container(
        width: 100,
        color: Colors.orange,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(product.serialNumber),
            Text(product.title),
            Text(product.category),
          ],
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.title),
          Text('Price: ${product.price}'),
          Text('Quantity: ${product.quantity}'),
          Text('Location: ${product.locationInStore}'),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {},
      ),
    );
  }
}

class Product {
  final String id;
  final String title;
  final String serialNumber;
  final double amount;
  final DateTime date;
  final String category;
  final String image;
  final String description;
  final int quantity;
  final String locationInStore;
  final double price;

  Product({
    required this.id,
    required this.title,
    required this.serialNumber,
    required this.amount,
    required this.date,
    required this.category,
    required this.image,
    required this.description,
    required this.quantity,
    required this.locationInStore,
    required this.price,
  });
}

List<Product> products = [
  Product(
    id: '1',
    title: 'Product 1',
    serialNumber: 'SN001',
    amount: 100,
    date: DateTime.now(),
    category: 'Category A',
    image: 'assets/product1.jpg',
    description: 'Description of Product 1',
    quantity: 10,
    locationInStore: 'Shelf A',
    price: 10.99,
  ),
];

class AddProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [],
        ),
      ),
    );
  }
}
