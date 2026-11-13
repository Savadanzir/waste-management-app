import 'package:flutter/material.dart';
import 'package:waste_management_system/admin/admin_create_employer_screen.dart';
import 'admin_api.dart';
import 'admin_pickups_screen.dart';
import 'admin_complaints_page.dart';
import 'admin_map_screen.dart'; // ✅ USED NOW (Map tab)

class AdminDashboardScreen extends StatefulWidget {
  final AdminApi api;
  final String token;
  const AdminDashboardScreen({super.key, required this.api, required this.token});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedMenu = 0; // 0=Home, 1=WastePickup, 2=Complaints, 3=Map, 4=Employer ✅ FIXED
  Future<void> refresh() async => setState(() {});

  static const String _fallbackVehicleAsset = "assets/vehicles/vehicle_placeholder.png";

  final List<VehicleInfo> _vehicles = [
    VehicleInfo(
      vehicleNo: "KL-07-AB-1234",
      allottedNo: "A-01",
      driverName: "Afsal",
      wentForPickup: false,
      imageAsset: "assets/vehicles/vehicle1.jpeg",
    ),
    VehicleInfo(
      vehicleNo: "KL-10-CD-5588",
      allottedNo: "A-02",
      driverName: "Nihal",
      wentForPickup: false,
      imageAsset: "assets/vehicles/vehicle2.jpeg",
    ),
    VehicleInfo(
      vehicleNo: "KL-11-EF-9087",
      allottedNo: "A-03",
      driverName: "Shameer",
      wentForPickup: false,
      imageAsset: "assets/vehicles/vehicle3.jpeg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const double pollutionRatePercent = 72;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F1F7), // same soft background
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          "assets/ecogurd.png",
          height: 80,
          fit: BoxFit.contain,
        ),
      ),

      // ✅ HOME = only the header card (no NestedScrollView blank body)
      body: _selectedMenu == 0
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: _headerCard(
                  pollutionRatePercent: pollutionRatePercent,
                  showDashboard: true, // ✅ show radials + vehicle only on home
                ),
              ),
            )

          // ✅ OTHER TABS = menu + page
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: _headerCard(
                    pollutionRatePercent: pollutionRatePercent,
                    showDashboard: false, // ✅ menu only
                  ),
                ),
                Expanded(
                  child: _selectedMenu == 1
                      ? AdminPickupsScreen(token: widget.token)
                      : _selectedMenu == 2
                          ? AdminComplaintsPage(api: widget.api, token: widget.token)
                          : _selectedMenu == 3
                              ? AdminMapScreen(api: widget.api, token: widget.token) // ✅ MAP ONLY
                              : AdminCreateEmployerScreen(api: widget.api, token: widget.token), // ✅ EMPLOYER ONLY
                ),
              ],
            ),
    );
  }

  // ================= HEADER CARD (MENU ALWAYS, DASHBOARD OPTIONAL) =================

  Widget _headerCard({
    required double pollutionRatePercent,
    required bool showDashboard,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: _whiteMiniMenuBar(
              selectedIndex: _selectedMenu,
              onChanged: (i) => setState(() => _selectedMenu = i),
            ),
          ),

          if (showDashboard) ...[
            const SizedBox(height: 12),
            PollutionRadials(pollutionPercent: pollutionRatePercent),
            const SizedBox(height: 12),
            _vehicleInfoPanel(_vehicles),
          ],
        ],
      ),
    );
  }

  // ================== MENU ==================

  Widget _whiteMiniMenuBar({required int selectedIndex, required ValueChanged<int> onChanged}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _whiteMenuChip(
            label: "Home",
            icon: Icons.home_outlined,
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _whiteMenuChip(
            label: "WastePickup",
            icon: Icons.delete_outline,
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
          _whiteMenuChip(
            label: "Complaints",
            icon: Icons.report_problem_outlined,
            selected: selectedIndex == 2,
            onTap: () => onChanged(2),
          ),
          _whiteMenuChip(
            label: "Map",
            icon: Icons.map_outlined,
            selected: selectedIndex == 3,
            onTap: () => onChanged(3),
          ),
          _whiteMenuChip(
            label: "Employer",
            icon: Icons.badge_outlined,
            selected: selectedIndex == 4, // ✅ FIXED
            onTap: () => onChanged(4), // ✅ FIXED
          ),
        ],
      ),
    );
  }

  Widget _whiteMenuChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.green.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: selected ? Colors.green.shade800 : Colors.grey.shade700),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.green.shade800 : Colors.grey.shade700,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== VEHICLE PANEL ==================

  Widget _vehicleInfoPanel(List<VehicleInfo> vehicles) {
    final went = vehicles.where((v) => v.wentForPickup).toList();
    final notWent = vehicles.where((v) => !v.wentForPickup).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vehicle Information",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              _pillStat("Went", "${went.length}", Colors.green),
              const SizedBox(width: 8),
              _pillStat("Not went", "${notWent.length}", Colors.redAccent),
            ],
          ),

          const SizedBox(height: 12),

          _driversTable(vehicles),

          const SizedBox(height: 12),

          _subTitleRow("Went for pickup"),
          const SizedBox(height: 8),
          went.isEmpty
              ? const Text("No vehicles went for pickup.", style: TextStyle(color: Colors.black54))
              : Column(children: went.map((v) => _vehicleRowCard(v)).toList()),

          const SizedBox(height: 12),

          _subTitleRow("Not went"),
          const SizedBox(height: 8),
          notWent.isEmpty
              ? const Text("All vehicles went for pickup.", style: TextStyle(color: Colors.black54))
              : Column(children: notWent.map((v) => _vehicleRowCard(v)).toList()),
        ],
      ),
    );
  }

  Widget _driversTable(List<VehicleInfo> vehicles) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(flex: 3, child: Text("Driver", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
              Expanded(flex: 3, child: Text("Vehicle", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
              Expanded(flex: 2, child: Text("Allotted", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
              Expanded(flex: 2, child: Text("Status", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey.shade200),
          ...vehicles.map((v) {
            final statusText = v.wentForPickup ? "Went" : "Not";
            final statusColor = v.wentForPickup ? Colors.green : Colors.redAccent;

            return Column(
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(flex: 3, child: Text(v.driverName, style: const TextStyle(fontSize: 12))),
                    Expanded(flex: 3, child: Text(v.vehicleNo, style: const TextStyle(fontSize: 12))),
                    Expanded(flex: 2, child: Text(v.allottedNo, style: const TextStyle(fontSize: 12))),
                    Expanded(
                      flex: 2,
                      child: Text(
                        statusText,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(height: 1, color: Colors.grey.shade200),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _vehicleRowCard(VehicleInfo v) {
    final statusColor = v.wentForPickup ? Colors.green : Colors.redAccent;
    final statusText = v.wentForPickup ? "Went for pickup" : "Not went";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 46,
              width: 60,
              child: Image.asset(
                (v.imageAsset ?? _fallbackVehicleAsset),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.local_shipping, size: 24),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.vehicleNo, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  "Allotted: ${v.allottedNo} • Driver: ${v.driverName}",
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.35)),
            ),
            child: Text(
              statusText,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subTitleRow(String text) {
    return Row(
      children: [
        Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800))),
      ],
    );
  }

  Widget _pillStat(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, color: color)),
          const SizedBox(width: 6),
          Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

// ================== VEHICLE INFO CLASS ==================

class VehicleInfo {
  final String vehicleNo;
  final String allottedNo;
  final String driverName;
  final bool wentForPickup;
  final String? imageAsset;

  VehicleInfo({
    required this.vehicleNo,
    required this.allottedNo,
    required this.driverName,
    required this.wentForPickup,
    this.imageAsset,
  });
}

// ================== RADIAL WIDGETS ==================

class PollutionRadials extends StatelessWidget {
  final double pollutionPercent;

  const PollutionRadials({
    super.key,
    required this.pollutionPercent,
  });

  @override
  Widget build(BuildContext context) {
    final p = pollutionPercent.clamp(0, 100);
    final pollution = p / 100.0;
    final clean = 1.0 - pollution;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Color(0x14000000),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _RadialStat(
              title: "Pollution rate",
              valueText: "${(pollution * 100).round()}%",
              value: pollution,
              color: const Color.fromARGB(255, 218, 27, 27),
              icon: Icons.warning_amber_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _RadialStat(
              title: "Clean rate",
              valueText: "${(clean * 100).round()}%",
              value: clean,
              color: Colors.green,
              icon: Icons.eco_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadialStat extends StatelessWidget {
  final String title;
  final String valueText;
  final double value;
  final Color color;
  final IconData icon;

  const _RadialStat({
    required this.title,
    required this.valueText,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 6),
          SizedBox(
            height: 110,
            width: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.black.withOpacity(0.08),
                  ),
                ),
                CircularProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  strokeWidth: 10,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  backgroundColor: Colors.transparent,
                ),
                Text(
                  valueText,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}