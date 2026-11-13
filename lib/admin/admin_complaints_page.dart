import 'package:flutter/material.dart';
import 'admin_api.dart';

class AdminComplaintsPage extends StatefulWidget {
  final AdminApi api;
  final String token;

  const AdminComplaintsPage({
    super.key,
    required this.api,
    required this.token,
  });

  @override
  State<AdminComplaintsPage> createState() => _AdminComplaintsPageState();
}

class _AdminComplaintsPageState extends State<AdminComplaintsPage> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.getComplaints(widget.token);
  }

  void _reload() {
    setState(() {
      _future = widget.api.getComplaints(widget.token);
    });
  }

  Future<void> _updateStatus(String id, String status) async {
    await widget.api.updateComplaintStatus(widget.token, id, status);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Complaint updated: $status")),
    );
    _reload();
  }

  Color _statusColor(String s) {
    final v = s.toUpperCase();
    if (v == "APPROVED") return Colors.green;
    if (v == "REJECTED") return Colors.red;
    if (v == "RESOLVED") return Colors.teal;
    return Colors.orange; // PENDING
  }

  String _absImageUrl(String imageUrl) {
    // imageUrl from backend like: /uploads/complaints/xxx.jpg
    // widget.api.baseUrl like: http://10.0.2.2:5000
    if (imageUrl.startsWith("http")) return imageUrl;
    return "${widget.api.baseUrl}$imageUrl";
  }

  void _showComplaintDialog({
    required String name,
    required String complaint,
    required String? imageUrl,
    required String status,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(name.isEmpty ? "Complaint" : name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complaint,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                if (imageUrl != null && imageUrl.trim().isNotEmpty) ...[
                  const Text(
                    "Image:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _absImageUrl(imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Text("Image not found"),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          height: 140,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("Status: "),
                    Text(
                      status,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _statusColor(status),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complaints"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }

          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text("No complaints"));
          }

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final c = items[i] as Map<String, dynamic>;

                final id = (c["_id"] ?? "").toString();

                // ✅ Your backend fields: name, complaint, imageUrl
                final name = (c["name"] ?? "Complaint").toString();
                final complaint = (c["complaint"] ?? "").toString();
                final imageUrl = (c["imageUrl"] ?? "").toString();

                final status = (c["status"] ?? "PENDING").toString().toUpperCase();

                return Card(
                  child: ListTile(
                    onTap: () => _showComplaintDialog(
                      name: name,
                      complaint: complaint,
                      imageUrl: imageUrl,
                      status: status,
                    ),

                    // ✅ Image preview (if exists), else icon
                    leading: (imageUrl.trim().isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _absImageUrl(imageUrl),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => CircleAvatar(
                                backgroundColor:
                                    _statusColor(status).withOpacity(0.15),
                                child: Icon(Icons.report,
                                    color: _statusColor(status)),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor:
                                _statusColor(status).withOpacity(0.15),
                            child:
                                Icon(Icons.report, color: _statusColor(status)),
                          ),

                    title: Text(name),
                    subtitle: Text(
                      complaint,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // ✅ Keep your dropdown action (approved/rejected)
                    trailing: _StatusMenu(
                      value: status,
                      items: const ["APPROVED", "REJECTED"], // ✅ only these two
                      onChanged: (s) => _updateStatus(id, s),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _StatusMenu extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _StatusMenu({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: null, // ✅ always show hint only
      hint: const Text("Action"),
      underline: const SizedBox(),
      items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}