import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

class EmployerHomeScreen extends StatefulWidget {
  final String token;
  final String employerId;

  const EmployerHomeScreen({
    super.key,
    required this.token,
    required this.employerId,
  });

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _approvedPickups = [];
  Timer? _refreshTimer;

  String get _baseUrl {
    if (kIsWeb) return "http://localhost:5000";
    return "http://10.0.2.2:5000";
  }

  @override
  void initState() {
    super.initState();
    _loadApprovedPickups();

    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        _loadApprovedPickups(showLoader: false);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// LOAD APPROVED PICKUPS
  Future<void> _loadApprovedPickups({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final url = Uri.parse("$_baseUrl/api/employer/approved-pickups");

      final res = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
          "Cache-Control": "no-cache",
        },
      );

      final body = res.body.isEmpty ? "{}" : res.body.trimLeft();

      final data = jsonDecode(body) as Map<String, dynamic>;

      final list = (data["data"] ?? []) as List<dynamic>;

      setState(() {
        _approvedPickups = list.where((item) {
          final map = item as Map<String, dynamic>;
          return (map["status"] ?? "").toString().toUpperCase() == "APPROVED";
        }).toList();

        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// MARK PICKUP COLLECTED
  Future<void> _completePickup(String pickupId) async {
    try {
      final url = Uri.parse("$_baseUrl/api/pickups/collect/$pickupId");

      final res = await http.patch(
        url,
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode != 200) {
        throw Exception("Failed to mark pickup collected");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pickup marked as collected")),
      );

      _loadApprovedPickups();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  /// PICKUP CARD
  Widget _pickupCard(Map<String, dynamic> pickup) {
    final status = (pickup["status"] ?? "").toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              const Expanded(
                child: Text(
                  "Approved Pickup",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text("Name : ${pickup["name"] ?? "User"}"),
          Text("Address : ${pickup["address"] ?? "-"}"),
          Text("Waste : ${pickup["wasteType"] ?? "-"}"),
          Text(
              "When : ${pickup["pickupDate"] ?? "-"} • ${pickup["pickupTime"] ?? "-"}"),
          Text("Notes : ${pickup["notes"] ?? "-"}"),

          const SizedBox(height: 10),

          /// SCAN BUTTON
          ElevatedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text("Scan House QR"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QrScanScreen(
                    onScanned: (pickupId) {
                      _completePickup(pickupId);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Employer Dashboard"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadApprovedPickups(),
          ),
        ],
      ),

      backgroundColor: const Color(0xFFF7F1F7),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text("Error: $_error"))
                : _approvedPickups.isEmpty
                    ? const Center(
                        child: Text(
                          "No approved pickup addresses yet.",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _approvedPickups.length,
                        itemBuilder: (context, index) {
                          final pickup =
                              _approvedPickups[index] as Map<String, dynamic>;
                          return _pickupCard(pickup);
                        },
                      ),
      ),
    );
  }
}

/// QR SCAN SCREEN
class QrScanScreen extends StatelessWidget {

  final Function(String) onScanned;

  const QrScanScreen({
    super.key,
    required this.onScanned,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Scan House QR"),
        backgroundColor: Colors.green,
      ),

      body: MobileScanner(

        onDetect: (BarcodeCapture capture) {

          final List<Barcode> barcodes = capture.barcodes;

          for (final barcode in barcodes) {

            final String? code = barcode.rawValue;

            if (code != null) {
              onScanned(code);
              Navigator.pop(context);
              break;
            }

          }

        },

      ),

    );
  }
}