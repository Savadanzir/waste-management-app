import 'dart:ui';
import 'package:flutter/material.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final Map<String, List<_ProductItem>> _categories = {
    "Pots & Plants": const [
      _ProductItem("Flower Pot", "₹150", "assets/products/flowerpot.jpeg"),
      _ProductItem("Indoor Plant", "₹200", "assets/products/plant.jpeg"),
    ],
    "Seeds & Compost": const [
      _ProductItem("Seeds Pack", "₹40", "assets/products/Seedspack.jpeg"),
      _ProductItem("Compost box", "₹120", "assets/products/compost.jpeg"),
    ],
    "Tools & Fertilizer": const [
      _ProductItem("gardening kit", "₹350", "assets/products/gardenkits.jpeg"),
      _ProductItem("Fertilizer", "₹80", "assets/products/fertilizer.jpeg"),
    ],
    "Saplings": const [
      _ProductItem("tomoto sapling", "₹90", "assets/products/tomotosapling.jpeg"),
      _ProductItem("mango sapling", "₹60", "assets/products/mangosapling.jpeg"),
      _ProductItem("Apple sapling", "₹70", "assets/products/apple.jpeg"),
      _ProductItem("coconut sapling", "₹50", "assets/products/coconut.jpeg"),
    ],
  };

  String _categoryThumb(String category) {
    final list = _categories[category] ?? const [];
    return list.isNotEmpty ? list.first.image : "";
  }

  @override
  Widget build(BuildContext context) {
    final keys = _categories.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Products"),
        backgroundColor: Colors.green,
      ),

      body: Stack(
        children: [

          /// Animated Gradient Background
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade200,
                      Colors.teal.shade100,
                      Colors.lightGreen.shade100,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),

          /// Glass Blur Layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.white.withOpacity(0.05),
            ),
          ),

          /// Product List
          ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: keys.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final category = keys[index];
              final products = _categories[category] ?? const [];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),

                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 46,
                      height: 46,
                      color: Colors.black12,
                      child: _categoryThumb(category).isEmpty
                          ? const Icon(Icons.image_not_supported)
                          : Image.asset(
                              _categoryThumb(category),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                    ),
                  ),

                  title: Text(
                    category,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),

                  trailing: const Icon(Icons.keyboard_arrow_down),

                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: products
                          .map(
                            (p) => ProductCard(
                              title: p.title,
                              price: p.price,
                              image: p.image,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProductItem {
  final String title;
  final String price;
  final String image;

  const _ProductItem(this.title, this.price, this.image);
}

class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String image;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Image.asset(
            image,
            height: 100,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                alignment: Alignment.center,
                color: Colors.black12,
                child: Text(
                  "Image not found\n$image",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11),
                ),
              );
            },
          ),

          const SizedBox(height: 15),

          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            price,
            style: const TextStyle(color: Colors.green),
          ),

          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: () => _showPaymentOptions(context, title, price),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text("Buy"),
          )
        ],
      ),
    );
  }
}

/// PAYMENT OPTIONS
void _showPaymentOptions(BuildContext context, String title, String price) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Text(
              "Choose Payment Method",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text("Google Pay"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Google Pay selected for $title")),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text("UPI"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("UPI selected for $title")),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.money),
              title: const Text("Cash on Delivery"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("COD selected for $title")),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}