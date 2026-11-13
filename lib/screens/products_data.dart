class ProductItem {
  final String title;
  final int price;
  final String image;
  final String category;

  const ProductItem({
    required this.title,
    required this.price,
    required this.image,
    required this.category,
  });
}

// Categories
const List<String> kCategories = [
  "Flower Pots",
  "Saplings",
  "Fertilizers",
  "Garden Kits",
  "Compost Boxes",
];

// Products list
const List<ProductItem> kAllProducts = [
  ProductItem(
    title: "Flower Pot",
    price: 150,
    image: "assets/products/flowerpot.jpeg",
    category: "Flower Pots",
  ),
  ProductItem(
    title: "Indoor Plant",
    price: 200,
    image: "assets/products/plant.jpeg",
    category: "Saplings",
  ),
  ProductItem(
    title: "Seeds Pack",
    price: 40,
    image: "assets/products/Seedspack.jpeg",
    category: "Saplings",
  ),
  ProductItem(
    title: "Compost box",
    price: 120,
    image: "assets/products/compost.jpeg",
    category: "Compost Boxes",
  ),
  ProductItem(
    title: "Fertilizer",
    price: 80,
    image: "assets/products/fertilizer.jpeg",
    category: "Fertilizers",
  ),
  ProductItem(
    title: "Gardening Kit",
    price: 350,
    image: "assets/products/gardenkits.jpeg",
    category: "Garden Kits",
  ),
  ProductItem(
    title: "Tomato Sapling",
    price: 90,
    image: "assets/products/tomoto.jpeg",
    category: "Saplings",
  ),
  ProductItem(
    title: "Mango Sapling",
    price: 60,
    image: "assets/products/mango.jpeg",
    category: "Saplings",
  ),
  ProductItem(
    title: "Apple Sapling",
    price: 70,
    image: "assets/products/apple.jpeg",
    category: "Saplings",
  ),
  ProductItem( 
    title: "Coconut Sapling",
    price: 50,
    image: "assets/products/coconut.jpeg",
    category: "Saplings",
  ),
]; 