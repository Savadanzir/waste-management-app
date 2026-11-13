import 'dart:async';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:waste_management_system/screens/user_not_home_map_screen.dart';
import 'package:waste_management_system/screens/waste_pickup_screen.dart';
import 'complaints_screen.dart';
import 'segregation_listscreen.dart';
import 'profile_screen.dart';
import 'package:waste_management_system/widgets/common_appbar.dart';
import 'products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeDashboard(),
    const WastePickupScreen(),
    const UserNotHomeMapScreen(
      userId: "TEMP_USER_ID",
      userName: "User",
    ),
    const ComplaintsScreen(),
    const SegregationListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green.shade600),
              child: const Text(
                "Menu",
                style: TextStyle(
                  color: Color.fromARGB(255, 227, 231, 4),
                  fontSize: 32,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 5);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text("Waste Pickup"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text("Map"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning_amber_outlined),
              title: const Text("Complaints"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text("Segregation"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 4);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),

      appBar: const CommonAppBar(showMenu: true),

      body: Stack(
        children: [
          const Positioned.fill(
            child: GlassAnimatedBackground(),
          ),
          Positioned.fill(
            child: _screens[_currentIndex],
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: "Waste pickup",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Map",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_outlined),
            label: "Complaints",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: "Segregation",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    final images = [
      'assets/news/slider1.jpeg',
      'assets/news/slider2.jpeg',
      'assets/news/slider3.jpeg',
      'assets/news/slider4.jpeg',
      'assets/news/slider5.jpeg',
      'assets/news/slider6.jpeg',
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Latest Activities",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),

            CarouselSlider(
              options: CarouselOptions(
                height: 170,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 2),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.easeInOut,
                enlargeCenterPage: false,
                viewportFraction: 0.88,
                enableInfiniteScroll: true,
                pauseAutoPlayOnTouch: true,
              ),
              items: images.map((path) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      path,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: Text(
                            "Image not found:\n$path",
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            const Text(
              "Our Mission",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.28),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                "Our mission is to redefine the lifecycle of resources by bridging the gap between consumption and conservation. We are committed to achieving a zero-waste future through innovative recovery systems, community education, and a relentless pursuit of environmental harmony.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Our Products",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: productsCard(
                    context: context,
                    title: "Garbage Bag",
                    price: "₹50 / pack",
                    image: "assets/images/garbage_bag.jpeg",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: productsCard(
                    context: context,
                    title: "Paper Basket",
                    price: "₹100 / pack",
                    image: "assets/images/paper_bag.jpeg",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductsScreen(),
                    ),
                  );
                },
                child: const Text(
                  "View More",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Waste Control (Live)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            const WasteControlLiveCard(),
          ],
        ),
      ),
    );
  }
}

Widget productsCard({
  required BuildContext context,
  required String title,
  required String price,
  required String image,
}) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.30),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.white.withOpacity(0.25)),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            image,
            height: 85,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 85,
                alignment: Alignment.center,
                color: Colors.black12,
                child: Text(
                  "Image not found\n$image",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 36,
          child: ElevatedButton(
            onPressed: () => _showPaymentOptions(context, title, price),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Buy"),
          ),
        ),
      ],
    ),
  );
}

void _showPaymentOptions(BuildContext context, String title, String price) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Choose Payment Method",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "$title • $price",
              style: const TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            _payTile(
              context,
              icon: Icons.account_balance_wallet_outlined,
              title: "Google Pay",
              subtitle: "Pay using GPay",
              onTap: () {
                Navigator.pop(context);
                _showUpiDialog(
                  context,
                  appName: "Google Pay",
                  title: title,
                  price: price,
                );
              },
            ),
            _payTile(
              context,
              icon: Icons.qr_code_2,
              title: "UPI",
              subtitle: "Pay using any UPI app",
              onTap: () {
                Navigator.pop(context);
                _showUpiDialog(
                  context,
                  appName: "UPI",
                  title: title,
                  price: price,
                );
              },
            ),
            _payTile(
              context,
              icon: Icons.payments_outlined,
              title: "Cash on Delivery",
              subtitle: "Pay when you receive",
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("COD selected for $title ✅")),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

Widget _payTile(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 6),
    leading: CircleAvatar(
      backgroundColor: Colors.green.withOpacity(0.12),
      child: Icon(icon, color: Colors.green),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

void _showUpiDialog(
  BuildContext context, {
  required String appName,
  required String title,
  required String price,
}) {
  final upiController = TextEditingController();

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text("$appName Payment"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Enter your UPI ID to pay for:\n$title ($price)"),
            const SizedBox(height: 12),
            TextField(
              controller: upiController,
              decoration: const InputDecoration(
                labelText: "UPI ID (example@bank)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              final upi = upiController.text.trim();
              if (upi.isEmpty || !upi.contains("@")) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter a valid UPI ID")),
                );
                return;
              }

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Payment initiated via $appName for $title ✅"),
                ),
              );
            },
            child: const Text("Pay"),
          ),
        ],
      );
    },
  );
}

class WasteControlLiveCard extends StatefulWidget {
  const WasteControlLiveCard({super.key});

  @override
  State<WasteControlLiveCard> createState() => _WasteControlLiveCardState();
}

class _WasteControlLiveCardState extends State<WasteControlLiveCard> {
  late final Stream<double> _stream;

  @override
  void initState() {
    super.initState();
    _stream = Stream.periodic(const Duration(seconds: 3), (tick) {
      const base = 0.45;
      const range = 0.45;
      final v = base + (range * ((tick % 16) / 15));
      return v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: _stream,
      initialData: 0.62,
      builder: (context, snapshot) {
        final p = (snapshot.data ?? 0.62).clamp(0.0, 1.0);
        final percentText = "${(p * 100).toStringAsFixed(1)}%";

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.30),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.eco, color: Colors.green),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Waste Control Progress",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    percentText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: p,
                  minHeight: 12,
                  backgroundColor: Colors.black12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _statusText(p),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        );
      },
    );
  }

  String _statusText(double p) {
    if (p >= 0.8) {
      return "Excellent control! Keep maintaining segregation & pickup.";
    }
    if (p >= 0.6) return "Good control. Improving steadily.";
    if (p >= 0.4) return "Average control. More segregation awareness needed.";
    return "Low control. Increase segregation and timely pickups.";
  }
}

class GlassAnimatedBackground extends StatefulWidget {
  const GlassAnimatedBackground({super.key});

  @override
  State<GlassAnimatedBackground> createState() => _GlassAnimatedBackgroundState();
}

class _GlassAnimatedBackgroundState extends State<GlassAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _blob({
    required double size,
    required List<Color> colors,
  }) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: colors),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0E7A3D),
                    Color(0xFF0A5D2E),
                    Color(0xFF159A4D),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 40 + (30 * t),
              left: -40 + (20 * t),
              child: _blob(
                size: 180,
                colors: [
                  Colors.white.withOpacity(0.18),
                  Colors.white.withOpacity(0.02),
                ],
              ),
            ),
            Positioned(
              top: 220 - (20 * t),
              right: -50 + (25 * t),
              child: _blob(
                size: 220,
                colors: [
                  const Color(0xFF7CFFD0).withOpacity(0.16),
                  const Color(0xFF7CFFD0).withOpacity(0.02),
                ],
              ),
            ),
            Positioned(
              bottom: 120 + (25 * t),
              left: 40 - (15 * t),
              child: _blob(
                size: 160,
                colors: [
                  const Color(0xFFB8FFF0).withOpacity(0.14),
                  const Color(0xFFB8FFF0).withOpacity(0.02),
                ],
              ),
            ),
            Positioned(
              bottom: -30,
              right: -30 + (20 * t),
              child: _blob(
                size: 240,
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.01),
                ],
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ],
        );
      },
    );
  }
}