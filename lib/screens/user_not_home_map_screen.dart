import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

class UserNotHomeMapScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const UserNotHomeMapScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserNotHomeMapScreen> createState() => _UserNotHomeMapScreenState();
}

class _UserNotHomeMapScreenState extends State<UserNotHomeMapScreen> {
  // ✅ Base URL (Web vs Android Emulator)
  String get _baseUrl {
    if (kIsWeb) return "http://localhost:5000";
    return "http://10.0.2.2:5000";
  }

  GoogleMapController? _mapCtrl;
  LatLng _center = const LatLng(11.2588, 75.7804); // Kozhikode default
  final Set<Marker> _markers = {};

  // ✅ user details
  final _nameCtrl = TextEditingController();
  final _houseCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();

  bool _loadingLocation = false;
  bool _sending = false;
  bool _loadingPlace = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.userName;
    _loadUserLocation();
  }

  @override
  void dispose() {
    _mapCtrl?.dispose();
    _nameCtrl.dispose();
    _houseCtrl.dispose();
    _addressCtrl.dispose();
    _placeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserLocation() async {
    setState(() => _loadingLocation = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack("Location service is disabled. Turn it ON.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnack("Location permission denied.");
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _center = LatLng(pos.latitude, pos.longitude);
      _setMarker(_center);

      if (_mapCtrl != null) {
        await _mapCtrl!.animateCamera(
          CameraUpdate.newLatLngZoom(_center, 14),
        );
      }

      // ✅ Fill Place/Address from map point
      await _updatePlaceFromLatLng(_center);
    } catch (e) {
      _showSnack("Location error: $e");
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _setMarker(LatLng latLng) {
    setState(() {
      _markers
        ..clear()
        ..add(
          Marker(
            markerId: const MarkerId("user_location"),
            position: latLng,
            infoWindow: const InfoWindow(title: "Selected Location"),
          ),
        );
    });
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // =========================================================
  // ✅ NEW: Fill "Place" (and Address) from selected map point
  // =========================================================
  Future<void> _updatePlaceFromLatLng(LatLng p) async {
    if (_loadingPlace) return;
    setState(() => _loadingPlace = true);

    try {
      // ✅ Web sometimes fails with geocoding plugin → use OpenStreetMap reverse API
      if (kIsWeb) {
        final url = Uri.parse(
          "https://nominatim.openstreetmap.org/reverse"
          "?format=jsonv2&lat=${p.latitude}&lon=${p.longitude}",
        );

        final res = await http.get(
          url,
          headers: {
            // Nominatim requires a User-Agent
            "User-Agent": "waste_management_system/1.0 (contact: demo@app)"
          },
        );

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final display = (data["display_name"] ?? "").toString();

          if (display.isNotEmpty) {
            // Put a short place in Place, full in Address
            final parts = display.split(",");
            final shortPlace = parts.take(3).join(",").trim();

            _placeCtrl.text = shortPlace;
            if (_addressCtrl.text.trim().isEmpty) {
              _addressCtrl.text = display;
            }
          }
        }
      } else {
        // ✅ Android/iOS/Desktop: geocoding plugin works
        final placemarks = await placemarkFromCoordinates(
          p.latitude,
          p.longitude,
        );
        if (placemarks.isNotEmpty) {
          final pm = placemarks.first;

          final place = [
            pm.name,
            pm.subLocality,
            pm.locality,
          ].where((x) => (x ?? "").trim().isNotEmpty).join(", ");

          final address = [
            pm.street,
            pm.subLocality,
            pm.locality,
            pm.administrativeArea,
            pm.postalCode,
          ].where((x) => (x ?? "").trim().isNotEmpty).join(", ");

          if (place.trim().isNotEmpty) _placeCtrl.text = place.trim();
          if (_addressCtrl.text.trim().isEmpty && address.trim().isNotEmpty) {
            _addressCtrl.text = address.trim();
          }
        }
      }
    } catch (e) {
      // don't block UI, just show info
      _showSnack("Could not fetch place from map.");
    } finally {
      if (mounted) setState(() => _loadingPlace = false);
    }
  }

  bool _validateDetails() {
    if (_nameCtrl.text.trim().isEmpty) {
      _showSnack("Enter your name");
      return false;
    }
    if (_houseCtrl.text.trim().isEmpty) {
      _showSnack("Enter house number");
      return false;
    }
    if (_addressCtrl.text.trim().isEmpty) {
      _showSnack("Enter address");
      return false;
    }
    if (_placeCtrl.text.trim().isEmpty) {
      _showSnack("Select place from map (tap on map)");
      return false;
    }
    return true;
  }

  Future<void> _sendNotInHome() async {
    if (_sending) return;
    if (!_validateDetails()) return;

    setState(() => _sending = true);

    try {
      final url = Uri.parse("$_baseUrl/api/waste/not-home");

      final payload = {
        "userId": widget.userId,
        "userName": widget.userName,
        "name": _nameCtrl.text.trim(),
        "houseNo": _houseCtrl.text.trim(),
        "address": _addressCtrl.text.trim(),
        "place": _placeCtrl.text.trim(),
        "lat": _center.latitude,
        "lng": _center.longitude,
        "status": "OPEN",
      };

      final res = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 12));

      final bodyTrim = res.body.trimLeft();
      if (bodyTrim.startsWith("<!DOCTYPE") || bodyTrim.startsWith("<html")) {
        throw Exception("Server returned HTML. Check your API route.");
      }

      Map<String, dynamic> data = {};
      if (res.body.isNotEmpty) {
        try {
          data = jsonDecode(res.body) as Map<String, dynamic>;
        } catch (_) {}
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        _showSnack("Sent to admin ✅");
      } else {
        throw Exception((data["message"] ?? res.body).toString());
      }
    } catch (e) {
      _showSnack("Not-in-home failed: $e");
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1F7),
      body: Column(
        children: [
          // ✅ TOP DETAILS CARD
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Container(
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
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          controller: _nameCtrl,
                          hint: "Name",
                          icon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _field(
                          controller: _houseCtrl,
                          hint: "House No",
                          icon: Icons.home_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _field(
                    controller: _addressCtrl,
                    hint: "Address",
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 10),

                  // ✅ Place is now filled from map; keep editable if you want.
                  _field(
                    controller: _placeCtrl,
                    hint: "Place (choose from map)",
                    icon: Icons.place_outlined,
                    readOnly: true, // ✅ lock typing (map chooses it)
                    suffix: _loadingPlace
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.map_outlined),
                  ),
                ],
              ),
            ),
          ),

          // ✅ MAP
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 13,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (c) => _mapCtrl = c,
                  onTap: (latLng) async {
                    _center = latLng;
                    _setMarker(latLng);
                    await _updatePlaceFromLatLng(latLng); // ✅ fill place
                  },
                ),

                Positioned(
                  left: 12,
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      _loadingLocation
                          ? "Getting your location..."
                          : "Tap on map to select exact point",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _sending ? null : _sendNotInHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: _sending
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Not in home",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
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

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
} 