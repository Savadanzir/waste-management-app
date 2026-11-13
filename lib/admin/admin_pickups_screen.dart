import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminPickupsScreen extends StatefulWidget {
  final String token;
  const AdminPickupsScreen({super.key, required this.token});

  @override
  State<AdminPickupsScreen> createState() => _AdminPickupsScreenState();
}

class _AdminPickupsScreenState extends State<AdminPickupsScreen> {
  // ✅ Base URL
  String get _baseUrl {
    if (kIsWeb) return "http://localhost:5000";
    return "http://10.0.2.2:5000";
  }

  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchPickups();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _fetchPickups();
    });
  }

  Future<List<dynamic>> _fetchPickups() async {
    final url = Uri.parse("$_baseUrl/api/admin/pickups");
    final res = await http.get(
      url,
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    // If server returns HTML (wrong route), show readable error
    final body = res.body.trimLeft();
    if (body.startsWith("<!DOCTYPE") || body.startsWith("<html")) {
      throw Exception("Wrong API route. Server returned HTML, not JSON.");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw Exception(data["message"] ?? "Request failed (${res.statusCode})");
    }

    return (data["data"] ?? []) as List<dynamic>;
  }

  Future<void> _approve(String id) async {
    final url = Uri.parse("$_baseUrl/api/admin/pickups/$id/approve");
    final res = await http.patch(
      url,
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (res.statusCode >= 400) {
      throw Exception("Approve failed: ${res.body}");
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Approved ✅")),
    );
    await _refresh();
  }

  Future<void> _reject(String id) async {
    final url = Uri.parse("$_baseUrl/api/admin/pickups/$id/reject");
    final res = await http.patch(
      url,
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (res.statusCode >= 400) {
      throw Exception("Reject failed: ${res.body}");
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Rejected ❌")),
    );
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1F7),
      appBar: AppBar(
        title: const Text("Pickup Requests"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),

      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Error: ${snap.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text("No pickup requests found"));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final p = list[i] as Map<String, dynamic>;

              final id = (p["_id"] ?? "").toString();
              final name = (p["name"] ?? "User").toString(); // if you store name
              final address = (p["address"] ?? "").toString();
              final wasteType = (p["wasteType"] ?? "").toString();
              final pickupDate = (p["pickupDate"] ?? "").toString();
              final pickupTime = (p["pickupTime"] ?? "").toString();
              final notes = (p["notes"] ?? "").toString();
              final status = (p["status"] ?? "PENDING").toString().toUpperCase();

              return _PickupCard(
                name: name,
                address: address,
                wasteType: wasteType,
                pickupDate: pickupDate,
                pickupTime: pickupTime,
                notes: notes,
                status: status,
                onApprove: status == "PENDING" ? () => _approve(id) : null,
                onReject: status == "PENDING" ? () => _reject(id) : null,
              );
            },
          );
        },
      ),
    );
  }
}

// ========================= UI CARD (like your sketch) =========================

class _PickupCard extends StatelessWidget {
  final String name;
  final String address;
  final String wasteType;
  final String pickupDate;
  final String pickupTime;
  final String notes;
  final String status;

  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _PickupCard({
    required this.name,
    required this.address,
    required this.wasteType,
    required this.pickupDate,
    required this.pickupTime,
    required this.notes,
    required this.status,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = status == "APPROVED"
        ? Colors.green
        : status == "REJECTED"
            ? Colors.redAccent
            : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top row: title + status chip
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Waste Pickup",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.35)),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontWeight: FontWeight.w800, color: statusColor, fontSize: 12),
                ),
              )
            ],
          ),

          const SizedBox(height: 12),

          _row("Name", name),
          const SizedBox(height: 6),
          _row("Address", address),

          if (wasteType.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row("Waste", wasteType),
          ],
          if (pickupDate.isNotEmpty || pickupTime.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row("When", [pickupDate, pickupTime].where((e) => e.isNotEmpty).join(" • ")),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            _row("Notes", notes),
          ],

          const SizedBox(height: 14),

          // buttons row like your sketch
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.green.withOpacity(0.25),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Approve", style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    disabledBackgroundColor: Colors.redAccent.withOpacity(0.25),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Reject", style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            "$k :",
            style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black54),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
} 