import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'admin_api.dart';

class AdminMapScreen extends StatefulWidget {
  final AdminApi api;
  final String token;
  const AdminMapScreen({super.key, required this.api, required this.token});

  @override
  State<AdminMapScreen> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends State<AdminMapScreen> {
  dynamic _map;
  late Future<List<dynamic>> _future;
  Timer? _timer;

  final Set<Marker> _markers = {};
  List<dynamic> _rows = [];

  @override
  void initState() {
    super.initState();
    _future = _load();

    // auto-refresh (optional)
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() => _future = _load());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _map?.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _load() async {
    final list = await widget.api.getNotHomeAlerts(widget.token);
    _rows = list;

    _markers
      ..clear()
      ..addAll(list.map((e) {
        final m = e as Map<String, dynamic>;
        final id = (m["_id"] ?? "").toString();
        final lat = (m["lat"] ?? 0).toDouble();
        final lng = (m["lng"] ?? 0).toDouble();
        final name = (m["userName"] ?? "User").toString();
        final place = (m["place"] ?? "").toString();

        return Marker(
          markerId: MarkerId(id),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: "Not in home: $name",
            snippet: place.isEmpty ? "Tap to view details" : place,
            onTap: () => _openDetails(m),
          ),
          onTap: () => _openDetails(m),
        );
      }));

    return list;
  }

  void _openDetails(Map<String, dynamic> m) {
    final id = (m["_id"] ?? "").toString();
    final name = (m["userName"] ?? "User").toString();
    final houseNo = (m["houseNo"] ?? "").toString();
    final address = (m["address"] ?? "").toString();
    final place = (m["place"] ?? "").toString();
    final lat = (m["lat"] ?? 0).toDouble();
    final lng = (m["lng"] ?? 0).toDouble();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Not-in-home Alert",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 10),
              Text("Name: $name"),
              if (houseNo.isNotEmpty) Text("House No: $houseNo"),
              if (address.isNotEmpty) Text("Address: $address"),
              if (place.isNotEmpty) Text("Place: $place"),
              const SizedBox(height: 8),
              Text("Location: $lat, $lng", style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.near_me),
                      label: const Text("Go to point"),
                      onPressed: () {
                        Navigator.pop(context);
                        _map?.animateCamera(
                          CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      icon: const Icon(Icons.check),
                      label: const Text("Resolve"),
                      onPressed: () async {
                        Navigator.pop(context);
                        await widget.api.resolveNotHomeAlert(widget.token, id);
                        if (!mounted) return;
                        setState(() => _future = _load());
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Table under the map
  Widget _table(List<dynamic> list) {
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("No open not-in-home alerts."),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("User")),
          DataColumn(label: Text("House")),
          DataColumn(label: Text("Place")),
          DataColumn(label: Text("Action")),
        ],
        rows: list.map((e) {
          final m = e as Map<String, dynamic>;
          final id = (m["_id"] ?? "").toString();
          final name = (m["userName"] ?? "User").toString();
          final houseNo = (m["houseNo"] ?? "").toString();
          final place = (m["place"] ?? "").toString();
          final lat = (m["lat"] ?? 0).toDouble();
          final lng = (m["lng"] ?? 0).toDouble();

          return DataRow(
            onSelectChanged: (_) {
              _map?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15));
              _openDetails(m);
            },
            cells: [
              DataCell(Text(name)),
              DataCell(Text(houseNo.isEmpty ? "-" : houseNo)),
              DataCell(Text(place.isEmpty ? "-" : place)),
              DataCell(
                TextButton(
                  onPressed: () async {
                    await widget.api.resolveNotHomeAlert(widget.token, id);
                    if (!mounted) return;
                    setState(() => _future = _load());
                  },
                  child: const Text("Resolve"),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Default start (Kozhikode-ish) — change if you want
    const start = LatLng(11.2588, 75.7804);

    return FutureBuilder<List<dynamic>>(
      future: _future,
      builder: (context, snap) {
        final loading = snap.connectionState == ConnectionState.waiting;
        final err = snap.hasError ? snap.error.toString() : null;
        final list = snap.data ?? _rows;

        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  google_maps.GoogleMap(
                    initialCameraPosition: const CameraPosition(target: start, zoom: 9),
                    markers: _markers,
                    onMapCreated: (c) => _map = c,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                  ),
                  if (loading)
                    const Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: LinearProgressIndicator(),
                    ),
                  if (err != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Material(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text("Error: $err",
                              style: const TextStyle(color: Colors.red)),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ✅ TABLE AREA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Not-in-home Alerts (Table)",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  _table(list),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}