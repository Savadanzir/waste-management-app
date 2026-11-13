import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WastePickupScreen extends StatefulWidget {
  const WastePickupScreen({super.key});

  @override
  State<WastePickupScreen> createState() => _WastePickupScreenState();
}

class _WastePickupScreenState extends State<WastePickupScreen> {
  String get _baseUrl {
    if (kIsWeb) return "http://localhost:5000";
    return "http://10.0.2.2:5000";
  }

  final String _userId = "TEMP_USER_ID";

  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedWasteType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _submitting = false;
  String statusText = "PENDING...";

  late Future<List<dynamic>> _historyFuture;
  Timer? _historyTimer;

  final List<String> _wasteTypes = const [
    "Plastic",
    "Paper",
    "Glass",
    "Metal",
    "E-Waste",
    "Organic",
    "Mixed Waste",
  ];

  @override
  void initState() {
    super.initState();
    _historyFuture = fetchPickupHistory(_baseUrl, _userId);

    _historyTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) _refreshHistory();
    });
  }

  @override
  void dispose() {
    _historyTimer?.cancel();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> fetchPickupHistory(String baseUrl, String userId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/waste/pickups/user/$userId"),
      headers: {"Content-Type": "application/json"},
    );

    final json = jsonDecode(res.body);
    if (res.statusCode != 200 || json["success"] != true) {
      throw Exception(json["message"] ?? "Failed to load pickup history");
    }
    return (json["data"] as List<dynamic>);
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = fetchPickupHistory(_baseUrl, _userId);
    });
  }

  String _statusMessage(String statusRaw) {
    final s = statusRaw.toUpperCase();
    if (s == "APPROVED") return "Your waste pickup is APPROVED ✅";
    if (s == "REJECTED") return "Your waste pickup is REJECTED ❌";
    if (s == "COLLECTED") return "Your waste pickup is COLLECTED ✅";
    return "Waiting for approval ⏳";
  }

  Future<void> _submitPickupRequest() async {
    if (_submitting) return;

    final wasteType = _selectedWasteType ?? "";
    final address = _addressController.text.trim();
    final notes = _notesController.text.trim();

    if (wasteType.isEmpty ||
        address.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() {
      _submitting = true;
      statusText = "SENDING...";
    });

    try {
      final url = Uri.parse("$_baseUrl/api/waste/pickup");

      final payload = {
        "userId": _userId,
        "name": "User",
        "wasteType": wasteType,
        "address": address,
        "pickupDate": _selectedDate!.toIso8601String(),
        "pickupTime": _selectedTime!.format(context),
        "notes": notes,
      };

      final res = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 12));

      if (!mounted) return;

      final bodyTrim = res.body.trimLeft();
      if (bodyTrim.startsWith("<!DOCTYPE") || bodyTrim.startsWith("<html")) {
        setState(() => statusText = "FAILED");
        throw Exception(
          "Wrong API route. Backend returned HTML. Check /api/waste/pickup in Node.",
        );
      }

      Map<String, dynamic> data = {};
      if (res.body.isNotEmpty) {
        try {
          data = jsonDecode(res.body) as Map<String, dynamic>;
        } catch (_) {}
      }

      if (res.statusCode == 201 || res.statusCode == 200) {
        setState(() {
          statusText = "PENDING...";
        });

        _addressController.clear();
        _notesController.clear();
        setState(() {
          _selectedWasteType = null;
          _selectedDate = null;
          _selectedTime = null;
        });

        _refreshHistory();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pickup request submitted successfully")),
        );
      } else {
        setState(() => statusText = "FAILED");
        final msg = (data["message"] ?? res.body).toString();
        throw Exception(msg);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => statusText = "FAILED");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (!mounted) return;
      setState(() => _submitting = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(
            child: GlassAnimatedBackground(),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      border: Border(
                        bottom: BorderSide(color: Colors.white.withOpacity(0.15)),
                      ),
                    ),
                    child: const Text(
                      "Request Waste Pickup",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _glassSection(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Waste Category",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedWasteType,
                                items: _wasteTypes
                                    .map((t) => DropdownMenuItem(
                                          value: t,
                                          child: Text(t),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedWasteType = v),
                                decoration: InputDecoration(
                                  hintText: "Select Waste Type",
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.90),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _addressController,
                                decoration: InputDecoration(
                                  hintText: "Pickup Address",
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.90),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _pillButton(
                                      label: _selectedDate == null
                                          ? "Select Date"
                                          : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
                                      borderColor: Colors.green,
                                      onTap: _pickDate,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _pillButton(
                                      label: _selectedTime == null
                                          ? "Select Time"
                                          : _selectedTime!.format(context),
                                      borderColor: Colors.redAccent,
                                      onTap: _pickTime,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _notesController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: "Additional Notes (Optional)",
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.90),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed:
                                      _submitting ? null : _submitPickupRequest,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF43A047),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(26),
                                    ),
                                  ),
                                  child: _submitting
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          "Submit Pickup Request",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        _glassSection(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "History / Recents",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: _refreshHistory,
                                  ),
                                ],
                              ),
                              FutureBuilder<List<dynamic>>(
                                future: _historyFuture,
                                builder: (context, snap) {
                                  if (snap.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  if (snap.hasError) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text("Error: ${snap.error}"),
                                    );
                                  }

                                  final items = (snap.data ?? [])
                                      .map((e) => e as Map<String, dynamic>)
                                      .toList();

                                  if (items.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text("No pickup requests yet."),
                                    );
                                  }

                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(label: Text("Status")),
                                        DataColumn(label: Text("Message")),
                                        DataColumn(label: Text("Waste")),
                                        DataColumn(label: Text("Date")),
                                        DataColumn(label: Text("Time")),
                                      ],
                                      rows: items.map((p) {
                                        final status =
                                            (p["status"] ?? "PENDING")
                                                .toString();
                                        final waste =
                                            (p["wasteType"] ?? "-").toString();
                                        final dateRaw =
                                            (p["pickupDate"] ?? "-").toString();
                                        final date = dateRaw.contains("T")
                                            ? dateRaw.split("T").first
                                            : dateRaw;
                                        final time =
                                            (p["pickupTime"] ?? "-").toString();

                                        return DataRow(
                                          cells: [
                                            DataCell(_StatusChip(status: status)),
                                            DataCell(
                                                Text(_statusMessage(status))),
                                            DataCell(Text(waste)),
                                            DataCell(Text(date)),
                                            DataCell(Text(time)),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassSection({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _pillButton({
    required String label,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: Colors.white.withOpacity(0.90),
      ),
      child: Text(label),
    );
  }
}

class _StatusChip extends StatefulWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  State<_StatusChip> createState() => _StatusChipState();
}

class _StatusChipState extends State<_StatusChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _shouldAnimate {
    final s = widget.status.toUpperCase();
    return s == "APPROVED" || s == "REJECTED";
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    if (_shouldAnimate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _StatusChip oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldS = oldWidget.status.toUpperCase();
    final newS = widget.status.toUpperCase();

    if (oldS != newS && (newS == "APPROVED" || newS == "REJECTED")) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.status.toUpperCase();
    late final Color bg;
    late final Color fg;

    switch (s) {
      case "APPROVED":
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        break;
      case "REJECTED":
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
        break;
      case "COLLECTED":
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
        break;
      default:
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade900;
    }

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        s,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );

    if (!_shouldAnimate) return chip;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeOutBack.transform(_controller.value);
        final fade = Curves.easeOut.transform(_controller.value);
        final rot = (1 - _controller.value) * (s == "REJECTED" ? -0.08 : 0.08);

        return Opacity(
          opacity: fade,
          child: Transform.rotate(
            angle: rot,
            child: Transform.scale(
              scale: 0.92 + (0.08 * t),
              child: chip,
            ),
          ),
        );
      },
    );
  }
}

class GlassAnimatedBackground extends StatefulWidget {
  const GlassAnimatedBackground({super.key});

  @override
  State<GlassAnimatedBackground> createState() =>
      _GlassAnimatedBackgroundState();
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