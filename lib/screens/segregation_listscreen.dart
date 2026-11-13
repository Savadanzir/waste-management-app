import 'package:flutter/material.dart';
import 'package:waste_management_system/widgets/glass_animated_background.dart';
import 'package:waste_management_system/widgets/glass_section.dart';
import 'segregation_detail_screen.dart';

class SegregationListScreen extends StatelessWidget {
  const SegregationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = _segregationItems;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(
            child: GlassAnimatedBackground(),
          ),
          Positioned.fill(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                  ),
                  child: const Text(
                    "Segregation",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return GlassSection(
                          padding: EdgeInsets.zero,
                          child: _SegTile(
                            title: item.title,
                            subtitle: "Tap to view details",
                            icon: item.icon,
                            iconBg: item.iconBg,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SegregationDetailScreen(item: item),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SegregationItem {
  final String title;
  final IconData icon;
  final Color iconBg;

  final String bagColor;
  final List<String> putIn;
  final List<String> doNotPut;
  final List<String> tips;

  const SegregationItem({
    required this.title,
    required this.icon,
    required this.iconBg,
    required this.bagColor,
    required this.putIn,
    required this.doNotPut,
    required this.tips,
  });
}

class _SegTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final VoidCallback onTap;

  const _SegTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: iconBg,
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Data ----
const _segregationItems = <SegregationItem>[
  SegregationItem(
    title: "Plastic",
    icon: Icons.local_drink,
    iconBg: Colors.orange,
    bagColor: "Blue bag",
    putIn: [
      "Plastic bottles (water/soft drink)",
      "Food containers (clean & dry)",
      "Plastic covers and packaging (clean)"
    ],
    doNotPut: [
      "Dirty plastic with food oil",
      "Medical waste / syringes",
      "Batteries or electronics"
    ],
    tips: [
      "Rinse and dry plastics before putting in bag",
      "Crush bottles to save space",
      "Keep plastic separate from wet waste"
    ],
  ),
  SegregationItem(
    title: "Paper",
    icon: Icons.description,
    iconBg: Colors.blue,
    bagColor: "White/Yellow bag",
    putIn: [
      "Newspapers, notebooks, office paper",
      "Cardboard (flattened)",
      "Paper bags"
    ],
    doNotPut: [
      "Wet/greasy paper (pizza boxes with oil)",
      "Tissues / used napkins",
      "Laminated paper"
    ],
    tips: [
      "Keep paper dry",
      "Remove plastic covers/staples if possible",
      "Bundle newspapers to keep tidy"
    ],
  ),
  SegregationItem(
    title: "Metal",
    icon: Icons.settings,
    iconBg: Colors.grey,
    bagColor: "Grey bag",
    putIn: [
      "Aluminium cans",
      "Steel tins (clean)",
      "Metal bottle caps"
    ],
    doNotPut: [
      "Gas cylinders",
      "Sharp blades without wrapping",
      "E-waste items"
    ],
    tips: [
      "Rinse cans before disposal",
      "Wrap sharp edges with paper/cardboard",
      "Keep separate from wet waste"
    ],
  ),
  SegregationItem(
    title: "E-Waste",
    icon: Icons.computer,
    iconBg: Colors.green,
    bagColor: "Separate box (E-waste)",
    putIn: [
      "Old chargers, cables",
      "Mobile phones",
      "Small electronics (mouse, remote)"
    ],
    doNotPut: [
      "Food waste",
      "Glass bottles",
      "Wet waste"
    ],
    tips: [
      "Do NOT throw in normal garbage bags",
      "Keep in a separate box and give to authorized collector",
      "Remove batteries if possible and store safely"
    ],
  ),
  SegregationItem(
    title: "Organic waste (vegetables, fruits)",
    icon: Icons.delete,
    iconBg: Colors.red,
    bagColor: "Green bag",
    putIn: [
      "Vegetable peels",
      "Fruit waste",
      "Cooked food leftovers (small quantity)"
    ],
    doNotPut: [
      "Plastic wrappers",
      "Glass/metal",
      "Sanitary/medical waste"
    ],
    tips: [
      "Tie the bag properly to avoid smell",
      "Composting is best if you can do it",
      "Keep wet waste separate from dry waste"
    ],
  ),
];