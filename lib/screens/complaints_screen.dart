import 'dart:async';
import 'dart:convert';
// ignore: unused_import
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  // ✅ Base URL (Web vs Android Emulator)
  String get _baseUrl {
    if (kIsWeb) return "http://localhost:5000";
    return "http://10.0.2.2:5000";
  }

  // ✅ TODO: Replace with real logged-in user id
  final String _userId = "TEMP_USER_ID";

  final _nameController = TextEditingController();
  final _complaintController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _picked;

  bool _submitting = false;
  String _errorText = "";

  late Future<List<dynamic>> _recentFuture;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _recentFuture = _fetchMyComplaints();

    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) _reloadRecents();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _nameController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  // =========================================================
  // ✅ FETCH USER COMPLAINT HISTORY
  // GET /api/complaints/user/:userId
  // =========================================================
  Future<List<dynamic>> _fetchMyComplaints() async {
    final url = Uri.parse("$_baseUrl/api/complaints/user/$_userId");
    final res = await http.get(url).timeout(const Duration(seconds: 12));

    final bodyTrim = res.body.trimLeft();
    if (bodyTrim.startsWith("<!DOCTYPE") || bodyTrim.startsWith("<html")) {
      throw Exception("Wrong API route. Server returned HTML.");
    }

    final json = jsonDecode(res.body);
    if (res.statusCode != 200 || json["success"] != true) {
      throw Exception(json["message"] ?? "Failed to load complaints");
    }

    return (json["data"] as List<dynamic>);
  }

  void _reloadRecents() {
    setState(() {
      _recentFuture = _fetchMyComplaints();
    });
  }

  // =========================================================
  // ✅ PICK IMAGE
  // =========================================================
  Future<void> _pickImage() async {
    final img =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) {
      setState(() => _picked = img);
    }
  }

  // =========================================================
  // ✅ SUBMIT COMPLAINT WITH IMAGE
  // POST /api/complaints
  // =========================================================
  Future<void> _submitComplaint() async {
    if (_submitting) return;

    final name = _nameController.text.trim();
    final complaint = _complaintController.text.trim();

    if (name.isEmpty || complaint.isEmpty) {
      setState(() => _errorText = "Please enter name and complaint");
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = "";
    });

    try {
      final url = Uri.parse("$_baseUrl/api/complaints");

      final request = http.MultipartRequest("POST", url);

      // ✅ MUST MATCH BACKEND controller keys
      request.fields["userId"] = _userId;
      request.fields["name"] = name;
      request.fields["complaint"] = complaint;

      // ✅ attach image (optional)
      if (_picked != null) {
        if (kIsWeb) {
          final bytes = await _picked!.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              "image",
              bytes,
              filename: _picked!.name,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              "image",
              _picked!.path,
            ),
          );
        }
      }

      final streamed = await request.send().timeout(const Duration(seconds: 20));
      final resBody = await streamed.stream.bytesToString();

      if (!mounted) return;

      if (streamed.statusCode == 201 || streamed.statusCode == 200) {
        _nameController.clear();
        _complaintController.clear();
        setState(() => _picked = null);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Complaint submitted successfully")),
        );

        _reloadRecents();
      } else {
        setState(() => _errorText = "Server rejected complaint: $resBody");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = "Error: $e");
    } finally {
      if (!mounted) return;
      setState(() => _submitting = false);
    }
  }

  // =========================================================
  // UI
  // =========================================================
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
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                    ),
                    child: const Text(
                      "Complaints",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ===================== CREATE CARD =====================
                  _glassSection(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Create a Complaint",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: "Your Name",
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.90),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _complaintController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "Write your complaint",
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.90),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Upload",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 50,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _picked?.name ?? "No image selected",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (_picked != null)
                                      IconButton(
                                        onPressed: () =>
                                            setState(() => _picked = null),
                                        icon: const Icon(Icons.close),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _nameController.clear();
                                  _complaintController.clear();
                                  setState(() {
                                    _picked = null;
                                    _errorText = "";
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.55),
                                ),
                                child: const Text("Cancel"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    _submitting ? null : _submitComplaint,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: _submitting
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text("Submit"),
                              ),
                            ),
                          ],
                        ),
                        if (_errorText.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: Colors.red.shade300),
                            ),
                            child: Text(
                              _errorText,
                              style:
                                  TextStyle(color: Colors.red.shade900),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===================== RECENTS HEADER =====================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Complaints",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: _reloadRecents,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),

                  // ===================== RECENTS LIST =====================
                  FutureBuilder<List<dynamic>>(
                    future: _recentFuture,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Padding(
                          padding: EdgeInsets.all(18),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snap.hasError) {
                        return _glassSection(
                          child: Text("Error: ${snap.error}"),
                        );
                      }

                      final items = snap.data ?? [];
                      if (items.isEmpty) {
                        return _glassSection(
                          child: const Text("No complaints yet."),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final c = items[i] as Map<String, dynamic>;
                          final status =
                              (c["status"] ?? "PENDING").toString().toUpperCase();

                          final isViewed = c["isViewed"] == true;
                          final viewMsg = (c["viewMessage"] ?? "").toString();

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        "Complaint",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _StatusChip(status: status),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text("Name: ${c["name"] ?? "-"}"),
                                Text(
                                  "Message: ${c["complaint"] ?? "-"}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                if (isViewed)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.green.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      viewMsg.isNotEmpty
                                          ? viewMsg
                                          : "Your complaint is viewed",
                                      style: TextStyle(
                                        color: Colors.green.shade900,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
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
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toUpperCase();
    Color bg, fg;

    switch (s) {
      case "APPROVED":
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        break;
      case "REJECTED":
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
        break;
      case "RESOLVED":
        bg = Colors.teal.shade100;
        fg = Colors.teal.shade900;
        break;
      default:
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade900;
    }

    return Container(
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