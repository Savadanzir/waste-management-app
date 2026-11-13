import 'package:flutter/material.dart';
import 'products_data.dart';

class ProductsByCategoryScreen extends StatelessWidget {
  final String category;
  const ProductsByCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final products = kAllProducts.where((p) => p.category == category).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: products.isEmpty
            ? const Center(child: Text("No products found"))
            : GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final p = products[index];
                  return _ProductCard(
                    title: p.title,
                    price: p.price,
                    image: p.image,
                    onBuy: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Buying: ${p.title}")),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final int price;
  final String image;
  final VoidCallback onBuy;

  const _ProductCard({
    required this.title,
    required this.price,
    required this.image,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFC07A7A), // similar to your background
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              image,
              height: 90,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 90,
                alignment: Alignment.center,
                color: Colors.black12,
                child: const Text("Image not found"),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            "₹$price",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.green,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 40,
            width: 110,
            child: ElevatedButton(
              onPressed: onBuy,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text("Buy"),
            ),
          ),
        ],
      ),
    );
  }
}